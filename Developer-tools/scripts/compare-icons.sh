#!/usr/bin/env bash
#
# compare-icons.sh – vergelijk het Hatter- en het Breeze-icoonthema.
#
# Gebruik:
#   ./compare-icons.sh <Hatter-map> <Breeze-map> [doelmap]
#
# Resultaat in <doelmap> (standaard: naast dit script):
#   Common/   iconen van Hatter die ook in Breeze voorkomen  (Hatter-structuur)
#   missing/  iconen van Breeze die niet in Hatter voorkomen (Hatter-structuur)
#
# Hatter-structuur:  <grootte>/<context>/<icoon>
# Breeze-structuur:  <context>/<grootte>/<icoon>
#
# Grootte-koppeling Breeze -> Hatter:
#   16 -> 16, 22 -> 22, 24 -> 24, 48 en groter -> scalable
#   andere groottes (bv. 8, 12, 32) hebben geen tegenhanger en worden overgeslagen
#   (pas map_size() aan als je dat anders wilt).
#
# Vergelijking: op (grootte, context, bestandsnaam zonder extensie).

set -euo pipefail

if [[ $# -lt 2 || $# -gt 3 ]]; then
    echo "Gebruik: $0 <Hatter-map> <Breeze-map> [doelmap]" >&2
    exit 1
fi

HATTER=$(realpath "$1")
BREEZE=$(realpath "$2")
OUT=$(realpath -m "${3:-$(dirname "$(realpath "$0")")}")
COMMON_DIR="$OUT/Common"
MISSING_DIR="$OUT/missing"

[[ -d $HATTER ]] || { echo "Geen map: $HATTER" >&2; exit 1; }
[[ -d $BREEZE ]] || { echo "Geen map: $BREEZE" >&2; exit 1; }

# Breeze-grootte -> Hatter-grootte-map (geen uitvoer + returncode 1 = overslaan)
map_size() {
    case $1 in
        16|22|24) echo "$1" ;;
        ''|*[!0-9]*) return 1 ;;
        *) if (( $1 >= 48 )); then echo scalable; else return 1; fi ;;
    esac
}

# Kopieert een bestand (symlinks worden opgelost); slaat kapotte links over
copy_icon() {
    local src=$1 dest_dir=$2
    [[ -e $src ]] || return 1
    mkdir -p "$dest_dir"
    cp -L -n -- "$src" "$dest_dir/"
}

declare -A BRZ        # sleutel -> pad van Breeze-icoon
declare -A SEEN       # sleutels die ook in Hatter bestaan
skipped=0

# ---------- Stap 1: Breeze inlezen (grootste maten eerst, zodat die voor 'scalable' winnen)
while IFS= read -r ctx_path; do
    ctx=$(basename "$ctx_path")
    mapfile -t sizes < <(find "$ctx_path" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort -rn)
    for size in "${sizes[@]}"; do
        if ! target=$(map_size "$size"); then
            skipped=$((skipped + 1))
            continue
        fi
        while IFS= read -r f; do
            [[ -e $f ]] || continue                    # kapotte symlink
            name=$(basename "$f")
            key="$target/$ctx/${name%.*}"
            [[ -n ${BRZ[$key]:-} ]] || BRZ[$key]=$f    # eerste (grootste) wint
        done < <(find "$ctx_path/$size" -mindepth 1 -maxdepth 1 \( -type f -o -type l \) | sort)
    done
done < <(find "$BREEZE" -mindepth 1 -maxdepth 1 -type d | sort)

# ---------- Stap 2: Hatter doorlopen -> Common
rm -rf "$COMMON_DIR" "$MISSING_DIR"
mkdir -p "$COMMON_DIR" "$MISSING_DIR"

n_common=0
for size in 16 22 24 scalable; do
    [[ -d $HATTER/$size && ! -L $HATTER/$size ]] || continue
    while IFS= read -r ctx_path; do
        ctx=$(basename "$ctx_path")
        while IFS= read -r f; do
            [[ -e $f ]] || continue
            name=$(basename "$f")
            key="$size/$ctx/${name%.*}"
            if [[ -n ${BRZ[$key]:-} ]]; then
                copy_icon "$f" "$COMMON_DIR/$size/$ctx" && n_common=$((n_common + 1))
                SEEN[$key]=1
            fi
        done < <(find "$ctx_path" -mindepth 1 -maxdepth 1 \( -type f -o -type l \) | sort)
    done < <(find "$HATTER/$size" -mindepth 1 -maxdepth 1 -type d | sort)
done

# ---------- Stap 3: wat Breeze heeft en Hatter niet -> missing
n_missing=0
for key in "${!BRZ[@]}"; do
    [[ -n ${SEEN[$key]:-} ]] && continue
    size=${key%%/*}
    rest=${key#*/}
    ctx=${rest%%/*}
    copy_icon "${BRZ[$key]}" "$MISSING_DIR/$size/$ctx" && n_missing=$((n_missing + 1))
done

# ---------- Stap 4: @2x-links zoals in Hatter
for base in "$COMMON_DIR" "$MISSING_DIR"; do
    for size in 16 22 24 scalable; do
        [[ -d $base/$size ]] && ln -sfn "$size" "$base/$size@2x"
    done
done

echo "Klaar."
echo "  Common : $n_common iconen   -> $COMMON_DIR"
echo "  missing: $n_missing iconen  -> $MISSING_DIR"
echo "  Breeze-groottemappen zonder tegenhanger overgeslagen: $skipped"
