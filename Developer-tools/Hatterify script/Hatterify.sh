#!/bin/bash
#
# Hatterify-script
# Written by Emmanuel Aerssens
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#
# Vereisten:
#   heif-convert
#   ImageMagick (magick)
#   base64
#   cmp (diffutils)
#   rsvg-convert (optioneel, geeft betere SVG-rendering dan ImageMagick)
#

set -euo pipefail

# Helderheidsdrempel (0-255): dominante kleur >= drempel geldt als "licht"
LUMA_THRESHOLD=128

# Mappenstructuur
mkdir -p IN OUT DONE

shopt -s nullglob nocaseglob

#
# Stap 1: bestanden in IN die al identiek in DONE staan, gewoon wissen
#
for source_file in IN/*; do

    [ -f "$source_file" ] || continue

    filename=$(basename "$source_file")

    if [ -f "DONE/$filename" ] && cmp -s "$source_file" "DONE/$filename"; then
        echo "Reeds verwerkt (identiek in DONE), verwijderd uit IN: $filename"
        rm -f "$source_file"
    fi

done

#
# Stap 2: conversie
#
for source_file in IN/*.{avif,png,webp,jpg,jpeg,svg,ico}; do

    [ -f "$source_file" ] || continue

    filename=$(basename "$source_file")
    base="${filename%.*}"
    ext="${filename##*.}"
    ext="${ext,,}"

    echo "Verwerken: $filename"

    tmp_png=$(mktemp --suffix=.png)

    #
    # Bronbestand omzetten naar PNG
    #
    case "$ext" in

        avif)
            heif-convert "$source_file" "$tmp_png" >/dev/null 2>&1 || {
                echo "Fout bij converteren van $filename"
                rm -f "$tmp_png"
                continue
            }
            ;;

        svg)
            # Vectorbron op hoge resolutie rasteriseren (transparantie blijft behouden)
            if command -v rsvg-convert >/dev/null 2>&1; then
                rsvg-convert -a -w 512 -h 512 -f png -o "$tmp_png" "$source_file" || {
                    echo "Fout bij converteren van $filename"
                    rm -f "$tmp_png"
                    continue
                }
            else
                magick -background none -density 384 "$source_file" "$tmp_png" || {
                    echo "Fout bij converteren van $filename"
                    rm -f "$tmp_png"
                    continue
                }
            fi
            ;;

        ico)
            # Een .ico bevat meestal meerdere formaten: de grootste frame kiezen
            ico_idx=$(magick identify -format '%p %w\n' "$source_file" 2>/dev/null \
                | awk '$2 > max { max = $2; idx = $1 } END { print idx + 0 }') || ico_idx=0
            magick "${source_file}[${ico_idx:-0}]" "$tmp_png" || {
                echo "Fout bij converteren van $filename"
                rm -f "$tmp_png"
                continue
            }
            ;;

        png|webp|jpg|jpeg)
            magick "${source_file}[0]" "$tmp_png" || {
                echo "Fout bij converteren van $filename"
                rm -f "$tmp_png"
                continue
            }
            ;;

        *)
            echo "Onbekend formaat: $filename"
            rm -f "$tmp_png"
            continue
            ;;

    esac

    #
    # Dominante kleur bepalen
    #
    dominant=$(magick "$tmp_png" \
        -background none \
        -trim \
        +repage \
        -resize 32x32 \
        -scale 1x1\! \
        -format '#%[hex:p{0,0}]' \
        info:)

    [ -z "$dominant" ] && dominant="#808080"

    #
    # Gradientkleuren berekenen
    #
    r=$((16#${dominant:1:2}))
    g=$((16#${dominant:3:2}))
    b=$((16#${dominant:5:2}))

    # Waargenomen helderheid (0-255, gewichten volgens ITU-R BT.601)
    luma=$(( (299*r + 587*g + 114*b) / 1000 ))

    if [ "$luma" -ge "$LUMA_THRESHOLD" ]; then

        echo "  -> overwegend lichte kleur: donkere gradient"

        # Bovenaan 45%, onderaan 25% van de oorspronkelijke kleur
        lr=$(( r*45/100 ));  lg=$(( g*45/100 ));  lb=$(( b*45/100 ))
        dr=$(( r*25/100 ));  dg=$(( g*25/100 ));  db=$(( b*25/100 ))

    else

        echo "  -> overwegend donkere kleur: lichte gradient"

        # Bovenaan 80%, onderaan 55% richting wit
        lr=$(( r + (255-r)*80/100 ));  lg=$(( g + (255-g)*80/100 ));  lb=$(( b + (255-b)*80/100 ))
        dr=$(( r + (255-r)*55/100 ));  dg=$(( g + (255-g)*55/100 ));  db=$(( b + (255-b)*55/100 ))

    fi

    # "light" = bovenste gradientkleur, "dark" = onderste (namen behouden voor de SVG-template)
    light=$(printf "#%02X%02X%02X" $lr $lg $lb)
    dark=$(printf "#%02X%02X%02X" $dr $dg $db)

    #
    # Detecteren of afbeelding transparantie bevat
    #
    alpha_mean=$(magick "$tmp_png" \
        -alpha extract \
        -format "%[fx:mean]" \
        info:)

    #
    # Transparant icoon
    #
    if awk "BEGIN {exit !($alpha_mean < 0.85)}"; then

        echo "  -> transparant icoon"

        b64=$(magick "$tmp_png" \
            -resize 128x128 \
            -background none \
            -gravity center \
            -extent 128x128 \
            png:- | base64 -w0)

        BACKGROUND_RECT='
  <rect
      x="8"
      y="8"
      width="112"
      height="112"
      rx="26"
      ry="26"
      fill="url(#bg)"/>'

        IMAGE_ELEMENT="
  <image
      x=\"10\"
      y=\"10\"
      width=\"108\"
      height=\"108\"
      preserveAspectRatio=\"xMidYMid meet\"
      xlink:href=\"data:image/png;base64,$b64\"/>"

    #
    # Niet-transparant icoon
    #
    else
    

        echo "  -> niet-transparant icoon"

        b64=$(magick "$tmp_png" \
            -resize 128x128^ \
            -gravity center \
            -extent 128x128 \
            png:- | base64 -w0)

        BACKGROUND_RECT=''

        IMAGE_ELEMENT="

  <image
      x=\"6\"
      y=\"6\"
      width=\"116\"
      height=\"116\"
      preserveAspectRatio=\"xMidYMid slice\"
      clip-path=\"url(#roundedClip)\"
      xlink:href=\"data:image/png;base64,$b64\"/>"

    fi

    svg="OUT/${base}.svg"

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

    <linearGradient
        id="bg"
        x1="0%"
        y1="0%"
        x2="0%"
        y2="100%">
      <stop offset="0%" stop-color="$light"/>
      <stop offset="100%" stop-color="$dark"/>
    </linearGradient>

    <filter
        id="shadow"
        x="-0.1"
        y="-0.1"
        width="1.2"
        height="1.2">
      <feGaussianBlur stdDeviation="2.24"/>
    </filter>

    <clipPath id="roundedClip">
      <rect
          x="8"
          y="8"
          width="112"
          height="112"
          rx="26"
          ry="26"/>
    </clipPath>

  </defs>

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

$BACKGROUND_RECT

$IMAGE_ELEMENT

</svg>
EOF

    echo "  SVG aangemaakt: $svg"

    #
    # Symlink maken op basis van laatste deel na punt
    #
    target="${base##*.}"

    if [ "$target" != "$base" ]; then
        (
            cd OUT
            ln -sf "${base}.svg" "${target}.svg"
        )
    fi

    #
    # Bronbestand verplaatsen naar DONE
    #
    mv "$source_file" "DONE/$filename"

    rm -f "$tmp_png"

done

echo
echo "Klaar."
echo "Bronbestanden : IN/"
echo "SVG iconen    : OUT/"
echo "Verwerkt      : DONE/"
