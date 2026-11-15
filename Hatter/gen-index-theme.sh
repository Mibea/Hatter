#!/usr/bin/env bash

#
# KDE-kleurschema (-f / -k):
#   Voegt FollowsColorScheme=true toe. 
#
# Gebruik:
#   gen-index-theme.sh [opties] [themamap]
#
# Standaard is de themamap ../Hatter, relatief aan dit script.

set -euo pipefail

# --- Instellingen die je hier kunt aanpassen -------------------------------
NAME=""                          # leeg = naam van de themamap
COMMENT="Not The Only One"
EXAMPLE="folder"
INHERITS="Adwaita,hicolor"
FOLLOWS_COLOR_SCHEME=0           # 1 = FollowsColorScheme=true toevoegen (KDE)
HIDPI=1                          # 1 = @2x-links aanmaken en opnemen (Scale=2)
HIDPI_SUFFIX="@2x"
HIDPI_SCALE=2
OUT=""                           # leeg = <themamap>/index.theme, "-" = stdout

SCALABLE_SIZE=128; SCALABLE_MIN=8; SCALABLE_MAX=512
SYMBOLIC_SIZE=16;  SYMBOLIC_MIN=8; SYMBOLIC_MAX=512
ICON_PATTERNS=(-name '*.svg' -o -name '*.svgz' -o -name '*.png' -o -name '*.xpm')
# ---------------------------------------------------------------------------

usage() {
  cat <<EOF
Gebruik: ${0##*/} [opties] [themamap]

Opties:
  -n NAAM      Themanaam (standaard: naam van de themamap)
  -c TEKST     Comment
  -i LIJST     Inherits, komma-gescheiden (standaard: $INHERITS)
  -e ICOON     Example-icoon (standaard: $EXAMPLE)
  -f | -k      Voeg FollowsColorScheme=true toe (voor KDE)
  -H           Geen Hi-DPI: geen @2x-links aanmaken of opnemen
  -o BESTAND   Uitvoerbestand, "-" voor stdout (standaard: <themamap>/index.theme)
  -h           Deze hulp
EOF
}

while getopts ":n:c:i:e:fkHo:h" opt; do
  case $opt in
    n) NAME=$OPTARG ;;
    c) COMMENT=$OPTARG ;;
    i) INHERITS=$OPTARG ;;
    e) EXAMPLE=$OPTARG ;;
    f|k) FOLLOWS_COLOR_SCHEME=1 ;;
    H) HIDPI=0 ;;
    o) OUT=$OPTARG ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DIR="${1:-$script_dir/../Hatter}"
[[ -d $THEME_DIR ]] || { echo "Themamap niet gevonden: $THEME_DIR" >&2; exit 1; }
THEME_DIR="$(cd "$THEME_DIR" && pwd)"

[[ -n $NAME ]] || NAME="$(basename "$THEME_DIR")"
[[ -n $OUT ]] || OUT="$THEME_DIR/index.theme"

# --- Hulpfuncties ----------------------------------------------------------

has_icons() {
  [[ -n "$(find -L "$1" -maxdepth 1 -type f \( "${ICON_PATTERNS[@]}" \) -print -quit)" ]]
}

context_name() {
  case $1 in
    apps)       echo "Applications" ;;
    mimetypes)  echo "MimeTypes" ;;
    ui)         echo "UI" ;;
    intl)       echo "International" ;;
    *)          echo "${1^}" ;;     # actions -> Actions, status -> Status, ...
  esac
}

DIRS=()
SECTIONS=""

# add_group <map> <Fixed|Scalable> <size> <min> <max> <schaal>
# <map> is de (eventueel symbolische) groepsmap, bv. "16" of "16@2x".
add_group() {
  local group=$1 kind=$2 size=$3 min=$4 max=$5 scale=$6 c ctx path
  [[ -d $THEME_DIR/$group ]] || return 0
  for c in "$THEME_DIR/$group"/*/; do
    [[ -d $c ]] || continue
    ctx=${c%/}; ctx=${ctx##*/}
    has_icons "$c" || continue
    path="$group/$ctx"
    DIRS+=("$path")
    SECTIONS+="[$path]"$'\n'
    SECTIONS+="Context=$(context_name "$ctx")"$'\n'
    SECTIONS+="Size=$size"$'\n'
    ((scale > 1)) && SECTIONS+="Scale=$scale"$'\n'
    SECTIONS+="Type=$kind"$'\n'
    if [[ $kind == Scalable ]]; then
      SECTIONS+="MinSize=$min"$'\n'
      SECTIONS+="MaxSize=$max"$'\n'
    fi
    SECTIONS+=$'\n'
  done
}

# add_with_hidpi <groepsmap> <Fixed|Scalable> <size> <min> <max>
# Voegt de groep toe (schaal 1) en, indien HIDPI=1, ook de @2x-link (schaal 2).
add_with_hidpi() {
  local group=$1 link
  shift
  [[ -d $THEME_DIR/$group ]] || return 0
  add_group "$group" "$@" 1

  ((HIDPI)) || return 0
  link="$group$HIDPI_SUFFIX"
  if [[ -e $THEME_DIR/$link && ! -L $THEME_DIR/$link ]]; then
    echo "Waarschuwing: $link bestaat al en is geen symlink; overgeslagen." >&2
    return 0
  fi
  ln -sfn "$group" "$THEME_DIR/$link"     # relatieve link, blijft werken na verplaatsen
  add_group "$link" "$@" "$HIDPI_SCALE"
}

# Controleer of de symbolische SVG's het KDE-kleurschema-stylesheet bevatten.
check_color_scheme() {
  [[ -d $THEME_DIR/symbolic ]] || return 0
  if ! grep -rqs --include='*.svg' 'current-color-scheme' "$THEME_DIR/symbolic/"; then
    echo "Waarschuwing: geen enkele SVG in symbolic/ bevat <style id=\"current-color-scheme\">;" >&2
    echo "  KDE kan de iconen dan niet omkleuren, ondanks FollowsColorScheme=true." >&2
  fi
}

# --- Mappen verzamelen -----------------------------------------------------

sizes=()
for d in "$THEME_DIR"/*/; do
  base=${d%/}; base=${base##*/}
  [[ $base =~ ^[0-9]+$ ]] && sizes+=("$base")     # "16@2x" valt hier bewust buiten
done

if ((${#sizes[@]})); then
  while read -r s; do
    add_with_hidpi "$s" Fixed "$s" "" ""
  done < <(printf '%s\n' "${sizes[@]}" | sort -n)
fi

add_with_hidpi scalable Scalable "$SCALABLE_SIZE" "$SCALABLE_MIN" "$SCALABLE_MAX"
add_with_hidpi symbolic Scalable "$SYMBOLIC_SIZE" "$SYMBOLIC_MIN" "$SYMBOLIC_MAX"

if ((${#DIRS[@]} == 0)); then
  echo "Geen mappen met iconen gevonden in $THEME_DIR" >&2
  exit 1
fi

((FOLLOWS_COLOR_SCHEME)) && check_color_scheme

# --- Schrijven -------------------------------------------------------------

directories=$(IFS=,; echo "${DIRS[*]}")

generate() {
  echo "# Automatisch gegenereerd door ${0##*/} - niet handmatig bewerken."
  echo
  echo "[Icon Theme]"
  echo "Name=$NAME"
  echo "Comment=$COMMENT"
  echo "Example=$EXAMPLE"
  echo "Inherits=$INHERITS"
  ((FOLLOWS_COLOR_SCHEME)) && echo "FollowsColorScheme=true"
  echo
  echo "Directories=$directories"
  echo
  printf '%s' "$SECTIONS"
}

if [[ $OUT == - ]]; then
  generate
else
  tmp="$(mktemp "${OUT}.XXXXXX")"
  generate > "$tmp"
  chmod 644 "$tmp"
  mv "$tmp" "$OUT"
  echo "Geschreven: $OUT (${#DIRS[@]} mappen)" >&2
fi
