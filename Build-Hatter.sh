# Build-Hatter
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

#!/usr/bin/env bash
set -Eeuo pipefail

# --------------------------------------------------
# Work from the directory containing this script, regardless of
# the directory from which the script is launched.
# --------------------------------------------------

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

rm -rf Build

#!/usr/bin/env bash

set -euo pipefail

# --------------------------------------------------
# Common functions
# --------------------------------------------------

colorize() {
    local source_file="$1"
    local output_file="$2"
    shift 2

    mkdir -p -- "$(dirname -- "$output_file")"
    cp -- "$source_file" "$output_file"

    while (($#)); do
        local old_color="$1"
        local new_color="$2"
        shift 2

        sed -i "s|${old_color}|${new_color}|g" "$output_file"
    done
}

copy_link() {
    local source_link="$1"
    local output_link="$2"

    mkdir -p -- "$(dirname -- "$output_link")"
    cp -P -- "$source_link" "$output_link"
}

# --------------------------------------------------
# Part 1 Create colour variants
# --------------------------------------------------

create_color_variants() {

    local INPUT_DIR="$1"
    local PREFIX="$2"

    local folders=(
        "${PREFIX}Blue"
        "${PREFIX}Green"
        "${PREFIX}Orange"
        "${PREFIX}Pink"
        "${PREFIX}Purple"
        "${PREFIX}Red"
        "${PREFIX}Slate"
        "${PREFIX}Teal"
        "${PREFIX}Yellow"
    )

    for folder in "${folders[@]}"; do
        mkdir -p -- "$folder"
    done

    mapfile -d '' files < <(
        find "$INPUT_DIR" \( -type f -o -type l \) -name '*.svg' -print0
    )

    if ((${#files[@]} == 0)); then
        printf 'No SVG files found in %s\n' "$INPUT_DIR" >&2
        return
    fi

    for source_file in "${files[@]}"; do

        relative_path="${source_file#"$INPUT_DIR"/}"

        if [[ -L "$source_file" ]]; then

            for color in Blue Green Orange Pink Purple Red Slate Teal Yellow; do
                copy_link \
                    "$source_file" \
                    "${PREFIX}${color}/${relative_path}"
            done

            continue
        fi

        mkdir -p -- "${PREFIX}Blue/$(dirname -- "$relative_path")"
        cp -- "$source_file" "${PREFIX}Blue/$relative_path"

        colorize "$source_file" "${PREFIX}Green/$relative_path" \
          '#a4caee' '#8ff0a4' '#73abea' '#57e389' '#428ce6' '#33d17a' \
          '#225590' '#2ec27e' '#2d68ae' '#26a269' \
          '#99c1f1' '#8ff0a4' '#62a0ea' '#57e389' '#3584e4' '#33d17a' \
          '#1c71d8' '#2ec27e' '#1a5fb4' '#26a269' '#438de6' '#2ec27e'

        colorize "$source_file" "${PREFIX}Orange/$relative_path" \
          '#a4caee' '#ffbe6f' '#73abea' '#ffa348' '#428ce6' '#ff7800' \
          '#225590' '#e66100' '#2d68ae' '#c64600' \
          '#99c1f1' '#ffbe6f' '#62a0ea' '#ffa348' '#3584e4' '#ff7800' \
          '#1c71d8' '#e66100' '#1a5fb4' '#c64600' '#438de6' '#e66100'

        colorize "$source_file" "${PREFIX}Pink/$relative_path" \
          '#a4caee' '#dd8aba' '#73abea' '#cb619f' '#428ce6' '#ac417f' \
          '#225590' '#9c3d74' '#2d68ae' '#833562' \
          '#99c1f1' '#dd8aba' '#62a0ea' '#cb619f' '#3584e4' '#ac417f' \
          '#1c71d8' '#9c3d74' '#1a5fb4' '#a51d2d' '#438de6' '#9c3d74'

        colorize "$source_file" "${PREFIX}Purple/$relative_path" \
          '#a4caee' '#dc8add' '#73abea' '#c061cb' '#428ce6' '#9141ac' \
          '#225590' '#813d9c' '#2d68ae' '#613583' \
          '#99c1f1' '#dc8add' '#62a0ea' '#c061cb' '#3584e4' '#9141ac' \
          '#1c71d8' '#813d9c' '#1a5fb4' '#613583' '#438de6' '#813d9c'

        colorize "$source_file" "${PREFIX}Red/$relative_path" \
          '#a4caee' '#f66151' '#73abea' '#ed333b' '#428ce6' '#e01b24' \
          '#225590' '#c01c28' '#2d68ae' '#a51d2d' \
          '#99c1f1' '#f66151' '#62a0ea' '#ed333b' '#3584e4' '#e01b24' \
          '#1c71d8' '#c01c28' '#1a5fb4' '#a51d2d' '#438de6' '#c01c28'

        colorize "$source_file" "${PREFIX}Slate/$relative_path" \
          '#a4caee' '#daddde' '#73abea' '#bcbfc0' '#428ce6' '#96999a' \
          '#225590' '#76797b' '#2d68ae' '#5c6164' \
          '#99c1f1' '#daddde' '#62a0ea' '#bcbfc0' '#3584e4' '#96999a' \
          '#1c71d8' '#76797b' '#1a5fb4' '#5c6164' '#438de6' '#76797b'

        colorize "$source_file" "${PREFIX}Teal/$relative_path" \
          '#a4caee' '#99f1f1' '#73abea' '#62eaea' '#428ce6' '#35e4e4' \
          '#225590' '#1cd8d8' '#2d68ae' '#1ab4b4' \
          '#99c1f1' '#99f1f1' '#62a0ea' '#62eaea' '#3584e4' '#35e4e4' \
          '#1c71d8' '#1cd8d8' '#1a5fb4' '#1ab4b4' '#438de6' '#1cd8d8'

        colorize "$source_file" "${PREFIX}Yellow/$relative_path" \
          '#a4caee' '#f9f06b' '#73abea' '#f8e45c' '#428ce6' '#f6d32d' \
          '#225590' '#f5c211' '#2d68ae' '#c64600' \
          '#99c1f1' '#f9f06b' '#62a0ea' '#f8e45c' '#3584e4' '#f6d32d' \
          '#1c71d8' '#f5c211' '#1a5fb4' '#c64600' '#438de6' '#f5c211'
    done

    printf 'Created colorized copies for %d SVG file(s) from %s\n' \
        "${#files[@]}" "$INPUT_DIR"
}

create_color_variants "Building-blocks/Colour-icon" "Hatter-"

# --------------------------------------------------
# PART 2 - Create YARU source folder
# --------------------------------------------------

INPUT_DIR="Building-blocks/Colour-icon"
OUTPUT_DIR="YARU-FOLDERS"

SEARCH_TEXT='9.7975636,60 17.000454,60 H 46.999547 C 54.132931,60'

mkdir -p -- "$OUTPUT_DIR"

if [[ ! -d "$INPUT_DIR" ]]; then
    printf 'Input folder not found: %s\n' "$INPUT_DIR" >&2
    exit 1
fi

while IFS= read -r -d '' source_file; do

    if grep -Fq -- "$SEARCH_TEXT" "$source_file"; then

        relative_path="${source_file#"$INPUT_DIR"/}"
        destination="$OUTPUT_DIR/$relative_path"

        mkdir -p -- "$(dirname -- "$destination")"

        cp -- "$source_file" "$destination"

        sed -i \
            -e 's/#a4caee/#696969/g' \
            -e 's/#62a0ea/#7d7d7d/g' \
            -e 's/fill:#1a5fb4/fill:#d4d4d4/g' \
            "$destination"
    fi

done < <(find "$INPUT_DIR" -type f -print0)

rsync -a --ignore-existing "$INPUT_DIR"/ "$OUTPUT_DIR"/

printf 'Yaru folder created or updated: %s\n' "$OUTPUT_DIR"

# --------------------------------------------------
# PART 3 Yaru variant
# --------------------------------------------------

create_color_variants "YARU-FOLDERS" "Hatter-Yaru-"

rm -rf -- YARU-FOLDERS

#-------------------------------
# PART 4 index.theme
#-------------------------------
  
  for folder in \
  Hatter-Pink Hatter-Slate Hatter-Yaru-Green Hatter-Yaru-Purple \
  Hatter-Yaru-Teal Hatter-Green Hatter-Purple Hatter-Teal \
  Hatter-Yaru-Orange Hatter-Yaru-Red Hatter-Yaru-Yellow Hatter-Blue \
  Hatter-Orange Hatter-Red Hatter-Yaru-Blue Hatter-Yaru-Pink \
  Hatter-Yaru-Slate Hatter-Yellow
do
  cp -- Building-blocks/index.theme "$folder/index.theme"
  sed -i "s/\[insert-name\]/$folder/g" "$folder/index.theme"
done

#-------------------------------
# PART 5 move the files to Build
#-------------------------------

mkdir -p -- Build

for folder in \
  Hatter-Pink Hatter-Slate Hatter-Yaru-Green Hatter-Yaru-Purple \
  Hatter-Yaru-Teal Hatter-Green Hatter-Purple Hatter-Teal \
  Hatter-Yaru-Orange Hatter-Yaru-Red Hatter-Yaru-Yellow Hatter-Blue \
  Hatter-Orange Hatter-Red Hatter-Yaru-Blue Hatter-Yaru-Pink \
  Hatter-Yaru-Slate Hatter-Yellow
do
  rsync -a --delete -- "$folder/" "Build/$folder/"
  rm -rf -- "$folder"
done

cp -a Hatter  Build/
cp -a Building-blocks/Hatter-kde Build/
cp -a Building-blocks/Hatter-kde-dark Build/
cp -r Build/Hatter/scalable/apps/*.svg  Build/Hatter-kde/apps/scalable  
    
#-------------------------------
# PART 6 check cache
#-------------------------------

theme="${1:-Build}"

if [[ ! -d "$theme" ]]; then
    printf 'Error: theme directory not found: %s\n' "$theme" >&2
    exit 1
fi

# --------------------------------------------------
# Check for index.theme in each immediate subdirectory of the theme directory.
# --------------------------------------------------

shopt -s nullglob
subdirectories=("$theme"/*/)

if ((${#subdirectories[@]} == 0)); then
    printf 'No subdirectories found in %s\n' "$theme"
fi

for subdirectory in "${subdirectories[@]}"; do
    subdirectory="${subdirectory%/}"

    if [[ -f "$subdirectory/index.theme" ]]; then
        printf 'Found theme index: %s/index.theme\n' "$subdirectory"
    else
        printf 'Warning: index.theme was not found in %s\n' "$subdirectory"
    fi
done

# --------------------------------------------------
# Find files whose names contain whitespace.
# --------------------------------------------------

mapfile -d '' files_with_whitespace < <(
    find "$theme" -type f -print0 |
    while IFS= read -r -d '' file; do
        name="${file##*/}"
        if [[ "$name" =~ [[:space:]] ]]; then
            printf '%s\0' "$file"
        fi
    done
)

if ((${#files_with_whitespace[@]} == 0)); then
    printf 'No files with whitespace in their names were found in %s\n' "$theme"
    exit 0
fi

printf '\nFiles with whitespace in their names:\n'
for file in "${files_with_whitespace[@]}"; do
    printf '  %q\n' "$file"
done

printf '\nChoose an option:\n'
printf '  1) Replace spaces in filenames with hyphens\n'
printf '  2) Skip renaming\n'
read -r -p 'Your choice [1/2]: ' choice

case "$choice" in
    1)
        for file in "${files_with_whitespace[@]}"; do
            # This option replaces regular spaces; other whitespace is left unchanged.
            if [[ "$file" != *" "* ]]; then
                printf 'Skipped (no regular spaces to replace): %q\n' "$file"
                continue
            fi

            new_file="${file// /-}"

            if [[ -e "$new_file" ]]; then
                printf 'Skipped (destination already exists): %q\n' "$new_file"
                continue
            fi

            mv -- "$file" "$new_file"
            printf 'Renamed: %q -> %q\n' "$file" "$new_file"
        done

        printf '\nUpdating icon cache...\n'
        gtk-update-icon-cache -f "$theme"
        ;;
    2)
        printf 'No files were renamed.\n'
        ;;
    *)
        printf 'Invalid choice. No files were renamed.\n' >&2
        exit 1
        ;;
esac