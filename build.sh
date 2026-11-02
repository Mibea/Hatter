#!/usr/bin/env bash
# Build-Hatter - non-interactive build script
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
# Generates the Hatter icon themes into a destination directory.
# Never asks questions, never touches system caches: suitable for CI,
# packaging (DESTDIR) and for the interactive install.sh wrapper.

set -Eeuo pipefail

# Remember where we were started, so a relative --dest is resolved
# against the caller's directory and not against the script directory.
ORIG_PWD="$PWD"

# Work from the directory containing this script, regardless of
# the directory from which the script is launched.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# --------------------------------------------------
# Source layout (relative to the script directory)
# --------------------------------------------------

readonly INPUT_DIR="Building-blocks/Colour-icon"
readonly INDEX_TEMPLATE="Building-blocks/index.theme"
readonly BASE_SRC="Hatter"


# Marker that identifies the icons which need a Yaru-specific recolour.
readonly YARU_SEARCH_TEXT='9.7975636,60 17.000454,60 H 46.999547 C 54.132931,60'

# --------------------------------------------------
# Theme names
# --------------------------------------------------

readonly COLOUR_NAMES=(Blue Green Orange Pink Purple Red Slate Teal Yellow)


COLOUR_THEMES=()
YARU_THEMES=()
for name in "${COLOUR_NAMES[@]}"; do
    COLOUR_THEMES+=("Hatter-$name")
    YARU_THEMES+=("Hatter-Yaru-$name")
done
readonly COLOUR_THEMES YARU_THEMES

# Every theme folder this script can ever generate.
readonly ALL_THEMES=(Hatter "${COLOUR_THEMES[@]}" "${YARU_THEMES[@]}")

# --------------------------------------------------
# Helpers
# --------------------------------------------------

usage() {
    cat <<'EOF'
Usage: build.sh [OPTIONS] [TARGET...]

Generates Hatter icon themes into a destination directory.

Targets (at least one target or --all is required, unless --list is used):
  Hatter          the base theme
  colours         all colour variants (Hatter-Blue ... Hatter-Yellow)
  yaru            all Yaru colour variants (Hatter-Yaru-Blue ... Hatter-Yaru-Yellow)
  all             everything (same as --all)
  <theme-name>    any single theme, e.g. Hatter-Red or Hatter-Yaru-Teal

Options:
  -d, --dest DIR        output directory (default: ./dist, relative to the
                        directory you run the script from)
  -a, --all             build everything
      --clean-all       first remove every known Hatter theme from DIR,
                        not only the ones that are about to be built
      --version VER     write a VERSION file with VER into every built theme
      --whitespace MODE what to do with file names containing whitespace:
                        warn (default), fail, or ignore
      --list            only print the theme names that the given targets
                        resolve to (all themes if no target is given), then exit
  -h, --help            show this help

Examples:
  ./build.sh --all --dest /tmp/out
  ./build.sh Hatter colours --dest "$HOME/.local/s/Downloadshare/icons"
  ./build.sh Hatter-Red Hatter-Yaru-Red --version 1.4.0
EOF
}

die() {
    printf 'Error: %s\n' "$*" >&2
    exit 1
}

in_array() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

# colorize SOURCE OUTPUT [SED_EXPR ...]
# Applies all substitutions in a single sed pass, writing the output
# file exactly once.
colorize() {
    local source_file="$1"
    local output_file="$2"
    shift 2

    mkdir -p -- "$(dirname -- "$output_file")"
    sed "$@" "$source_file" > "$output_file"
}

copy_link() {
    local source_link="$1"
    local output_link="$2"

    mkdir -p -- "$(dirname -- "$output_link")"
    cp -P -- "$source_link" "$output_link"
}

# --------------------------------------------------
# Colour palettes (sed expressions, applied in one pass per variant)
# --------------------------------------------------

readonly PALETTE_GREEN=(
    -e 's|#a4caee|#8ff0a4|g'
    -e 's|#73abea|#57e389|g'
    -e 's|#428ce6|#33d17a|g'
    -e 's|#225590|#2ec27e|g'
    -e 's|#2d68ae|#26a269|g'
    -e 's|#99c1f1|#8ff0a4|g'
    -e 's|#62a0ea|#57e389|g'
    -e 's|#3584e4|#33d17a|g'
    -e 's|#1c71d8|#2ec27e|g'
    -e 's|#1a5fb4|#26a269|g'
    -e 's|#438de6|#2ec27e|g'
)

readonly PALETTE_ORANGE=(
    -e 's|#a4caee|#ffbe6f|g'
    -e 's|#73abea|#ffa348|g'
    -e 's|#428ce6|#ff7800|g'
    -e 's|#225590|#e66100|g'
    -e 's|#2d68ae|#c64600|g'
    -e 's|#99c1f1|#ffbe6f|g'
    -e 's|#62a0ea|#ffa348|g'
    -e 's|#3584e4|#ff7800|g'
    -e 's|#1c71d8|#e66100|g'
    -e 's|#1a5fb4|#c64600|g'
    -e 's|#438de6|#e66100|g'
)

readonly PALETTE_PINK=(
    -e 's|#a4caee|#dd8aba|g'
    -e 's|#73abea|#cb619f|g'
    -e 's|#428ce6|#ac417f|g'
    -e 's|#225590|#9c3d74|g'
    -e 's|#2d68ae|#833562|g'
    -e 's|#99c1f1|#dd8aba|g'
    -e 's|#62a0ea|#cb619f|g'
    -e 's|#3584e4|#ac417f|g'
    -e 's|#1c71d8|#9c3d74|g'
    -e 's|#1a5fb4|#a51d2d|g'
    -e 's|#438de6|#9c3d74|g'
)

readonly PALETTE_PURPLE=(
    -e 's|#a4caee|#dc8add|g'
    -e 's|#73abea|#c061cb|g'
    -e 's|#428ce6|#9141ac|g'
    -e 's|#225590|#813d9c|g'
    -e 's|#2d68ae|#613583|g'
    -e 's|#99c1f1|#dc8add|g'
    -e 's|#62a0ea|#c061cb|g'
    -e 's|#3584e4|#9141ac|g'
    -e 's|#1c71d8|#813d9c|g'
    -e 's|#1a5fb4|#613583|g'
    -e 's|#438de6|#813d9c|g'
)

readonly PALETTE_RED=(
    -e 's|#a4caee|#f66151|g'
    -e 's|#73abea|#ed333b|g'
    -e 's|#428ce6|#e01b24|g'
    -e 's|#225590|#c01c28|g'
    -e 's|#2d68ae|#a51d2d|g'
    -e 's|#99c1f1|#f66151|g'
    -e 's|#62a0ea|#ed333b|g'
    -e 's|#3584e4|#e01b24|g'
    -e 's|#1c71d8|#c01c28|g'
    -e 's|#1a5fb4|#a51d2d|g'
    -e 's|#438de6|#c01c28|g'
)

readonly PALETTE_SLATE=(
    -e 's|#a4caee|#daddde|g'
    -e 's|#73abea|#bcbfc0|g'
    -e 's|#428ce6|#96999a|g'
    -e 's|#225590|#76797b|g'
    -e 's|#2d68ae|#5c6164|g'
    -e 's|#99c1f1|#daddde|g'
    -e 's|#62a0ea|#bcbfc0|g'
    -e 's|#3584e4|#96999a|g'
    -e 's|#1c71d8|#76797b|g'
    -e 's|#1a5fb4|#5c6164|g'
    -e 's|#438de6|#76797b|g'
)

readonly PALETTE_TEAL=(
    -e 's|#a4caee|#99f1f1|g'
    -e 's|#73abea|#62eaea|g'
    -e 's|#428ce6|#35e4e4|g'
    -e 's|#225590|#1cd8d8|g'
    -e 's|#2d68ae|#1ab4b4|g'
    -e 's|#99c1f1|#99f1f1|g'
    -e 's|#62a0ea|#62eaea|g'
    -e 's|#3584e4|#35e4e4|g'
    -e 's|#1c71d8|#1cd8d8|g'
    -e 's|#1a5fb4|#1ab4b4|g'
    -e 's|#438de6|#1cd8d8|g'
)

readonly PALETTE_YELLOW=(
    -e 's|#a4caee|#f9f06b|g'
    -e 's|#73abea|#f8e45c|g'
    -e 's|#428ce6|#f6d32d|g'
    -e 's|#225590|#f5c211|g'
    -e 's|#2d68ae|#c64600|g'
    -e 's|#99c1f1|#f9f06b|g'
    -e 's|#62a0ea|#f8e45c|g'
    -e 's|#3584e4|#f6d32d|g'
    -e 's|#1c71d8|#f5c211|g'
    -e 's|#1a5fb4|#c64600|g'
    -e 's|#438de6|#f5c211|g'
)

# Fills the global PALETTE array with the sed expressions of one colour.
PALETTE=()
select_palette() {
    case "$1" in
        Green)  PALETTE=("${PALETTE_GREEN[@]}") ;;
        Orange) PALETTE=("${PALETTE_ORANGE[@]}") ;;
        Pink)   PALETTE=("${PALETTE_PINK[@]}") ;;
        Purple) PALETTE=("${PALETTE_PURPLE[@]}") ;;
        Red)    PALETTE=("${PALETTE_RED[@]}") ;;
        Slate)  PALETTE=("${PALETTE_SLATE[@]}") ;;
        Teal)   PALETTE=("${PALETTE_TEAL[@]}") ;;
        Yellow) PALETTE=("${PALETTE_YELLOW[@]}") ;;
        *)      die "no palette defined for colour: $1" ;;
    esac
}

# --------------------------------------------------
# Build steps
# --------------------------------------------------

# build_colour_variants INPUT_DIR PREFIX OUTPUT_ROOT COLOUR...
# Blue is the original colour: its files are copied unchanged.
build_colour_variants() {
    local input_dir="$1"
    local prefix="$2"
    local output_root="$3"
    shift 3
    local -a colours=("$@")

    local -a files=()
    mapfile -d '' files < <(
        find "$input_dir" \( -type f -o -type l \) -name '*.svg' -print0
    )

    ((${#files[@]} > 0)) || die "no SVG files found in $input_dir"

    local colour folder source_file relative_path
    for colour in "${colours[@]}"; do
        folder="$output_root/${prefix}${colour}"
        mkdir -p -- "$folder"

        if [[ "$colour" != Blue ]]; then
            select_palette "$colour"
        fi

        for source_file in "${files[@]}"; do
            relative_path="${source_file#"$input_dir"/}"

            if [[ -L "$source_file" ]]; then
                copy_link "$source_file" "$folder/$relative_path"
            elif [[ "$colour" == Blue ]]; then
                mkdir -p -- "$(dirname -- "$folder/$relative_path")"
                cp -- "$source_file" "$folder/$relative_path"
            else
                colorize "$source_file" "$folder/$relative_path" "${PALETTE[@]}"
            fi
        done

        printf 'Built %s (%d SVG file(s))\n' "${prefix}${colour}" "${#files[@]}"
    done
}

# make_yaru_source TARGET_DIR
# Creates the Yaru-flavoured copy of the source icons.
make_yaru_source() {
    local yaru_dir="$1"
    local -a yaru_files=()
    local source_file relative_path destination

    command -v rsync >/dev/null 2>&1 || die "rsync is required to build the Yaru variants"

    mkdir -p -- "$yaru_dir"

    # One grep over all files (NUL-separated) instead of one grep per file.
    mapfile -d '' yaru_files < <(
        find "$INPUT_DIR" -type f -print0 |
        xargs -0 -r grep -lZ -- "$YARU_SEARCH_TEXT" || true
    )

    for source_file in "${yaru_files[@]}"; do
        relative_path="${source_file#"$INPUT_DIR"/}"
        destination="$yaru_dir/$relative_path"

        mkdir -p -- "$(dirname -- "$destination")"

        sed \
            -e 's/#a4caee/#696969/g' \
            -e 's/#62a0ea/#7d7d7d/g' \
            -e 's/fill:#1a5fb4/fill:#d4d4d4/g' \
            "$source_file" > "$destination"
    done

    rsync -a --ignore-existing "$INPUT_DIR"/ "$yaru_dir"/

    printf 'Yaru source created in temporary folder\n'
}

# --------------------------------------------------
# Argument parsing
# --------------------------------------------------

DEST_DIR=""
BUILD_ALL=0
CLEAN_ALL=0
LIST_ONLY=0
VERSION_TEXT=""
WHITESPACE_MODE="warn"
TARGETS=()

while (($# > 0)); do
    case "$1" in
        -d|--dest)
            (($# >= 2)) || die "$1 needs an argument"
            DEST_DIR="$2"
            shift 2
            ;;
        --dest=*)
            DEST_DIR="${1#*=}"
            shift
            ;;
        -a|--all)
            BUILD_ALL=1
            shift
            ;;
        --clean-all)
            CLEAN_ALL=1
            shift
            ;;
        --version)
            (($# >= 2)) || die "--version needs an argument"
            VERSION_TEXT="$2"
            shift 2
            ;;
        --version=*)
            VERSION_TEXT="${1#*=}"
            shift
            ;;
        --whitespace)
            (($# >= 2)) || die "--whitespace needs an argument"
            WHITESPACE_MODE="$2"
            shift 2
            ;;
        --whitespace=*)
            WHITESPACE_MODE="${1#*=}"
            shift
            ;;
        --list)
            LIST_ONLY=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        --)
            shift
            TARGETS+=("$@")
            break
            ;;
        -*)
            usage >&2
            die "unknown option: $1"
            ;;
        *)
            TARGETS+=("$1")
            shift
            ;;
    esac
done

case "$WHITESPACE_MODE" in
    warn|fail|ignore) ;;
    *) die "invalid --whitespace mode: $WHITESPACE_MODE (use warn, fail or ignore)" ;;
esac

# --------------------------------------------------
# Resolve targets into a list of theme names (no duplicates)
# --------------------------------------------------

SELECTED_THEMES=()

add_theme() {
    in_array "$1" "${SELECTED_THEMES[@]}" || SELECTED_THEMES+=("$1")
}

if ((BUILD_ALL)); then
    TARGETS+=(all)
fi

for target in "${TARGETS[@]}"; do
    case "$target" in
        all)
            for theme in "${ALL_THEMES[@]}"; do add_theme "$theme"; done
            ;;
        colours|colors)
            for theme in "${COLOUR_THEMES[@]}"; do add_theme "$theme"; done
            ;;
        yaru)
            for theme in "${YARU_THEMES[@]}"; do add_theme "$theme"; done
            ;;
        *)
            in_array "$target" "${ALL_THEMES[@]}" \
                || die "unknown target: $target (try --help or --list)"
            add_theme "$target"
            ;;
    esac
done

if ((LIST_ONLY)); then
    if ((${#SELECTED_THEMES[@]} == 0)); then
        printf '%s\n' "${ALL_THEMES[@]}"
    else
        printf '%s\n' "${SELECTED_THEMES[@]}"
    fi
    exit 0
fi

if ((${#SELECTED_THEMES[@]} == 0)); then
    usage >&2
    die "nothing to build: give at least one target or use --all"
fi

# --------------------------------------------------
# Destination
# --------------------------------------------------

if [[ -z "$DEST_DIR" ]]; then
    DEST_DIR="$ORIG_PWD/dist"
elif [[ "$DEST_DIR" != /* ]]; then
    DEST_DIR="$ORIG_PWD/$DEST_DIR"
fi

mkdir -p -- "$DEST_DIR"
DEST_DIR="$(cd -- "$DEST_DIR" && pwd)"

[[ "$DEST_DIR" != "/" ]] || die "refusing to use / as destination"

# --------------------------------------------------
# Work out which parts are needed
# --------------------------------------------------

BUILD_BASE=0
BUILD_COLOURS=()
BUILD_YARU_COLOURS=()
INDEX_THEMES=()

for theme in "${SELECTED_THEMES[@]}"; do
    if [[ "$theme" == "Hatter" ]]; then
        BUILD_BASE=1
    elif in_array "$theme" "${YARU_THEMES[@]}"; then
        BUILD_YARU_COLOURS+=("${theme#Hatter-Yaru-}")
        INDEX_THEMES+=("$theme")
    else
        BUILD_COLOURS+=("${theme#Hatter-}")
        INDEX_THEMES+=("$theme")
    fi
done

if ((${#BUILD_COLOURS[@]} > 0 || ${#BUILD_YARU_COLOURS[@]} > 0)); then
    [[ -d "$INPUT_DIR" ]] || die "input folder not found: $INPUT_DIR"
    [[ -f "$INDEX_TEMPLATE" ]] || die "index.theme template not found: $INDEX_TEMPLATE"
fi
if ((BUILD_BASE)); then
    [[ -d "$BASE_SRC" ]] || die "source folder not found: $BASE_SRC"
fi

# --------------------------------------------------
# Remove old versions
# --------------------------------------------------

if ((CLEAN_ALL)); then
    to_remove=("${ALL_THEMES[@]}")
else
    to_remove=("${SELECTED_THEMES[@]}")
fi

for theme in "${to_remove[@]}"; do
    if [[ -d "$DEST_DIR/$theme" ]]; then
        printf 'Remove old icon folder: %s\n' "$DEST_DIR/$theme"
        rm -rf -- "${DEST_DIR:?}/$theme"
    fi
done

# --------------------------------------------------
# Build
# --------------------------------------------------

TMP_DIR=""
cleanup() {
    if [[ -n "$TMP_DIR" ]]; then
        rm -rf -- "$TMP_DIR"
    fi
    return 0
}
trap cleanup EXIT

if ((BUILD_BASE)); then
    cp -a "$BASE_SRC" "$DEST_DIR/"
    printf 'Built Hatter\n'
fi

if ((${#BUILD_COLOURS[@]} > 0)); then
    build_colour_variants "$INPUT_DIR" "Hatter-" "$DEST_DIR" "${BUILD_COLOURS[@]}"
fi

if ((${#BUILD_YARU_COLOURS[@]} > 0)); then
    TMP_DIR="$(mktemp -d)"
    make_yaru_source "$TMP_DIR/YARU-FOLDERS"
    build_colour_variants "$TMP_DIR/YARU-FOLDERS" "Hatter-Yaru-" "$DEST_DIR" "${BUILD_YARU_COLOURS[@]}"
fi

for theme in "${INDEX_THEMES[@]}"; do
    sed "s/\[insert-name\]/$theme/g" "$INDEX_TEMPLATE" > "$DEST_DIR/$theme/index.theme"
done

if [[ -n "$VERSION_TEXT" ]]; then
    for theme in "${SELECTED_THEMES[@]}"; do
        printf '%s\n' "$VERSION_TEXT" > "$DEST_DIR/$theme/VERSION"
    done
fi

# --------------------------------------------------
# Checks
# --------------------------------------------------

for theme in "${INDEX_THEMES[@]}"; do
    [[ -f "$DEST_DIR/$theme/index.theme" ]] \
        || die "index.theme was not created in $DEST_DIR/$theme"
done

if [[ "$WHITESPACE_MODE" != "ignore" ]]; then
    theme_paths=()
    for theme in "${SELECTED_THEMES[@]}"; do
        theme_paths+=("$DEST_DIR/$theme")
    done

    files_with_whitespace=()
    mapfile -d '' files_with_whitespace < <(
        find "${theme_paths[@]}" -type f -name '*[[:space:]]*' -print0
    )

    if ((${#files_with_whitespace[@]} > 0)); then
        printf 'Files with whitespace in their names:\n' >&2
        for file in "${files_with_whitespace[@]}"; do
            printf '  %q\n' "$file" >&2
        done
        if [[ "$WHITESPACE_MODE" == "fail" ]]; then
            exit 2
        fi
    fi
fi

printf 'Done: %d theme(s) written to %s\n' "${#SELECTED_THEMES[@]}" "$DEST_DIR"

# --------------------------------------------------
# Update icon caches (once per theme, after all changes)
# --------------------------------------------------

if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    for theme_name in "${SELECTED_THEMES[@]}"; do
        printf 'update icon-cache for %s\n' "$theme_name"
        gtk-update-icon-cache -f "$DEST_DIR/$theme_name"
    done
else
    printf 'Warning: gtk-update-icon-cache not found, icon caches were not updated\n' >&2
fi