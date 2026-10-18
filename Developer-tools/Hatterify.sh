#!/bin/bash

# Vereist:
#   heif-convert
#   ImageMagick (magick)
#   base64

for avif in *.avif; do
    [ -f "$avif" ] || continue

    base="${avif%.avif}"
    svg="${base}.svg"

    echo "Verwerken: $avif"

    tmp_png=$(mktemp --suffix=.png)

    # AVIF -> PNG
    heif-convert "$avif" "$tmp_png" >/dev/null 2>&1 || {
        echo "Fout bij converteren van $avif"
        rm -f "$tmp_png"
        continue
    }

    #
    # Meest voorkomende kleur bepalen
    #
dominant=$(magick "$tmp_png" \
    -background none \
    -trim \
    +repage \
    -resize 32x32 \
    -scale 1x1! \
    -format '#%[hex:p{0,0}]' \
    info:)


    # Fallback indien geen kleur gevonden
    [ -z "$dominant" ] && dominant="#808080"

    #
    # Lichtere en donkerdere tint van dezelfde kleur
    #
r=$((16#${dominant:1:2}))
g=$((16#${dominant:3:2}))
b=$((16#${dominant:5:2}))
 
# 25% lichter
lr=$(( r + (255-r)*25/100 ))
lg=$(( g + (255-g)*25/100 ))
lb=$(( b + (255-b)*25/100 ))
 
# 30% donkerder
dr=$(( r*70/100 ))
dg=$(( g*70/100 ))
db=$(( b*70/100 ))
 
light=$(printf "#%02X%02X%02X" $lr $lg $lb)
dark=$(printf "#%02X%02X%02X" $dr $dg $db)



    #
    # Afbeelding voorbereiden voor embedding
    #
    b64=$(magick "$tmp_png" \
        -resize 96x96 \
        -background none \
        -gravity center \
        -extent 96x96 \
        png:- | base64 -w 0)

    rm -f "$tmp_png"

    cat > "$svg" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg
    width="128"
    height="128"
    viewBox="0 0 128 128"
    version="1.1"
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink">

  <defs>

    <!-- Achtergrondgradient -->
    <linearGradient
        id="bg"
        x1="0%"
        y1="0%"
        x2="0%"
        y2="100%">
      <stop offset="0%" stop-color="$light"/>
      <stop offset="100%" stop-color="$dark"/>
    </linearGradient>

    <!-- Schaduw -->
    <filter
        id="shadow"
        x="-0.1"
        y="-0.1"
        width="1.2"
        height="1.2">
      <feGaussianBlur stdDeviation="2.24"/>
    </filter>

  </defs>

  <!-- Schaduw -->
  <rect
      x="8"
      y="10.624"
      width="112"
      height="112"
      rx="26"
      ry="26"
      fill="#000000"
      opacity="0.25"
      filter="url(#shadow)"/>

  <!-- Achtergrond -->
  <rect
      x="8"
      y="8"
      width="112"
      height="112"
      rx="26"
      ry="26"
      fill="url(#bg)"/>

  <!-- Ingebedde afbeelding -->
  <image
      x="16"
      y="16"
      width="96"
      height="96"
      preserveAspectRatio="xMidYMid meet"
      xlink:href="data:image/png;base64,$b64"/>

</svg>
EOF

    echo "Aangemaakt: $svg (dominante kleur: $dominant)"
done