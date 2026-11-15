#!/usr/bin/env bash
#
# dedupe-symlink.sh – zoek inhoudelijk identieke bestanden in alle submappen
# (ook binnen dezelfde map, de bestandsnaam speelt geen rol), behoud één
# origineel en vervang de rest door relatieve symlinks.
#
# Gebruik:
#   ./dedupe-symlink.sh [-n] [-f] [-s] <map>
#
#   -n   dry-run: toon alleen wat er zou gebeuren, wijzig niets
#   -f   mapvoorrang gaat vóór bestandsnaamlengte (zie hieronder)
#   -s   SVG's vergelijken na normalisatie: commentaar, <metadata>, de
#        XML-declaratie en verschillen in witruimte/regeleinden tellen niet mee.
#        Zonder -s moeten bestanden byte-voor-byte identiek zijn.
#
# Keuze van het origineel binnen een groep identieke bestanden:
#   standaard: 1) kortste bestandsnaam
#              2) bij gelijke lengte: map symbolic, dan 22, dan 16, dan de rest
#              3) daarna alfabetisch op pad
#   met -f   : 1) map symbolic, dan 22, dan 16, dan de rest
#              2) kortste bestandsnaam
#              3) alfabetisch op pad
#
# Bestaande symlinks en lege bestanden worden genegeerd.

set -euo pipefail

DRY=0
FOLDER_FIRST=0
NORMALIZE=0
USAGE="Gebruik: $0 [-n] [-f] [-s] <map>"
while getopts "nfs" opt; do
    case $opt in
        n) DRY=1 ;;
        f) FOLDER_FIRST=1 ;;
        s) NORMALIZE=1 ;;
        *) echo "$USAGE" >&2; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

[[ $# -eq 1 && -d $1 ]] || { echo "$USAGE" >&2; exit 1; }
ROOT=$(realpath "$1")

if (( NORMALIZE )); then
    command -v perl >/dev/null || { echo "perl is nodig voor -s" >&2; exit 1; }
fi

# Rang van de map: symbolic = 0, 22 = 1, 16 = 2, rest = 3
folder_rank() {
    local rel=${1#"$ROOT"/} part
    local IFS=/
    for part in $rel; do
        [[ $part == symbolic ]] && { echo 0; return; }
    done
    for part in $rel; do
        [[ $part == 22 ]] && { echo 1; return; }
    done
    for part in $rel; do
        [[ $part == 16 ]] && { echo 2; return; }
    done
    echo 3
}

# Normaliseert een SVG naar een vergelijkbare vorm
normalize_svg() {
    perl -0777 -pe '
        s/<\?xml.*?\?>//gs;          # XML-declaratie
        s/<!--.*?-->//gs;            # commentaar
        s/<metadata\b.*?<\/metadata>//gs;
        s/\s+/ /g;                   # witruimte samenvouwen
        s/>\s+</></g;                # witruimte tussen tags
        s/^\s+|\s+$//g;
    ' -- "$1"
}

# Schrijft "hash  pad" records (NUL-gescheiden) voor alle te vergelijken bestanden
emit_hashes() {
    if (( NORMALIZE )); then
        # Niet-SVG's: gewone hash
        find "$ROOT" -type f -size +0 ! -iname '*.svg' -print0 \
            | xargs -0 -r sha256sum --zero
        # SVG's: hash van de genormaliseerde inhoud
        local f h
        while IFS= read -r -d '' f; do
            h=$(normalize_svg "$f" | sha256sum | cut -d' ' -f1)
            printf '%s  %s\0' "$h" "$f"
        done < <(find "$ROOT" -type f -size +0 -iname '*.svg' -print0)
    else
        find "$ROOT" -type f -size +0 -print0 | xargs -0 -r sha256sum --zero
    fi
}

groups=0
linked=0
group=()

process_group() {
    (( ${#group[@]} > 1 )) || return 0

    local p base len rank key orig
    orig=$(
        for p in "${group[@]}"; do
            base=$(basename "$p")
            len=${#base}
            rank=$(folder_rank "$p")
            if (( FOLDER_FIRST )); then
                key=$(printf '%d %05d' "$rank" "$len")
            else
                key=$(printf '%05d %d' "$len" "$rank")
            fi
            printf '%s\t%s\n' "$key" "$p"
        done | LC_ALL=C sort | head -n 1 | cut -f2-
    )

    groups=$((groups + 1))

    for p in "${group[@]}"; do
        [[ $p == "$orig" ]] && continue
        local target
        target=$(realpath --relative-to="$(dirname "$p")" "$orig")
        if (( DRY )); then
            echo "LINK  ${p#"$ROOT"/}  ->  $target"
        else
            ln -sf -- "$target" "$p"
        fi
        linked=$((linked + 1))
    done
}

prev=""
while IFS= read -r -d '' rec; do
    hash=${rec%%  *}
    path=${rec#*  }
    if [[ $hash != "$prev" ]]; then
        process_group
        group=()
        prev=$hash
    fi
    group+=("$path")
done < <(emit_hashes | LC_ALL=C sort -z)
process_group

if (( DRY )); then
    echo "Dry-run: $groups groepen identieke bestanden, $linked bestanden zouden een symlink worden."
else
    echo "Klaar: $groups groepen, $linked bestanden vervangen door symlinks."
fi
