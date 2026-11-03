#!/usr/bin/env bash
#
# collect-all-symbolic.sh – verzamel alle iconen uit de mappen 16, 22, 24 en
# symbolic van het Hatter-thema in één platte map genaamd all-symbolic.
#
# Gebruik:
#   ./collect-all-symbolic.sh <Hatter-map> [doelmap]
#
# De doelmap is optioneel (standaard: naast dit script); daarin wordt
# all-symbolic aangemaakt. Een bestaande all-symbolic wordt eerst leeggemaakt.
#
# Bij dubbele bestandsnamen wint de eerste, in de volgorde:
#   symbolic, 16, 22, 24
# De overige dubbelen worden overgeslagen en geteld.

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Gebruik: $0 <Hatter-map> [doelmap]" >&2
    exit 1
fi

HATTER=$(realpath "$1")
OUT=$(realpath -m "${2:-$(dirname "$(realpath "$0")")}")/all-symbolic

[[ -d $HATTER ]] || { echo "Geen map: $HATTER" >&2; exit 1; }

rm -rf "$OUT"
mkdir -p "$OUT"

copied=0
dupes=0
broken=0

for size in symbolic 16 22 24; do
    src="$HATTER/$size"
    if [[ ! -d $src || -L $src ]]; then
        echo "Overgeslagen (niet gevonden): $src" >&2
        continue
    fi
    while IFS= read -r -d '' f; do
        if [[ ! -e $f ]]; then          # kapotte symlink
            broken=$((broken + 1))
            continue
        fi
        dest="$OUT/$(basename "$f")"
        if [[ -e $dest ]]; then
            dupes=$((dupes + 1))
            continue
        fi
        cp -L -- "$f" "$dest"           # symlinks worden echte bestanden
        copied=$((copied + 1))
    done < <(find "$src" \( -type f -o -type l \) -print0 | sort -z)
done

echo "Klaar: $copied iconen in $OUT"
echo "  dubbele namen overgeslagen: $dupes"
echo "  kapotte symlinks overgeslagen: $broken"
