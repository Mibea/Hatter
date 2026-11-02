#!/usr/bin/env bash
# Build-Hatter - interactive installer
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
# Thin interactive wrapper around build.sh: asks what to install, builds
# directly into the icon directory and updates the icon caches.
#
# Usage: ./install.sh [1-6]
# Passing the number as an argument skips the interactive menu.

set -Eeuo pipefail

# Work from the directory containing this script, regardless of
# the directory from which the script is launched.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BUILD_SCRIPT="$SCRIPT_DIR/build.sh"
[[ -x "$BUILD_SCRIPT" ]] || {
    printf 'build.sh not found or not executable: %s\n' "$BUILD_SCRIPT" >&2
    exit 1
}

# --------------------------------------------------
# Installation menu
# --------------------------------------------------

choice="${1:-}"

if [[ -z "$choice" ]]; then
    printf 'Hatter icon themes - choose what to install:\n\n'
    printf '  1) Hatter only\n'
    printf '  2) Hatter + colour variants\n'
    printf '  3) Hatter + Yaru colour variants\n'
    printf '  4) Hatter + colour variants + Yaru colour variants\n'
    printf '  5) Everything\n\n'

    while true; do
        read -r -p 'Your choice [1-6]: ' choice || {
            printf '\nNo input received. Aborting.\n' >&2
            exit 1
        }
        [[ "$choice" =~ ^[1-6]$ ]] && break
        printf 'Invalid choice, please enter a number from 1 to 6.\n' >&2
    done
elif [[ ! "$choice" =~ ^[1-6]$ ]]; then
    printf 'Invalid argument: %s (expected a number from 1 to 6)\n' "$choice" >&2
    exit 1
fi

case "$choice" in
    1) targets=(Hatter) ;;
    2) targets=(Hatter colours) ;;
    3) targets=(Hatter yaru) ;;
    4) targets=(Hatter colours yaru) ;;
    5) targets=(all) ;;
esac

# --------------------------------------------------
# Destination
# --------------------------------------------------

if [[ "$EUID" -eq 0 ]]; then
    DEST_DIR="/usr/share/icons"
else
    DEST_DIR="$HOME/.local/share/icons"
fi

# --------------------------------------------------
# Build: removes ALL old Hatter themes first, then generates the
# selected ones. Whitespace handling is done below, interactively.
# --------------------------------------------------

"$BUILD_SCRIPT" --dest "$DEST_DIR" --clean-all --whitespace=ignore "${targets[@]}"

SELECTED_THEMES=()
mapfile -t SELECTED_THEMES < <("$BUILD_SCRIPT" --list "${targets[@]}")

# --------------------------------------------------
# Files whose names contain whitespace (only inside our own themes)
# --------------------------------------------------

theme_paths=()
for theme_name in "${SELECTED_THEMES[@]}"; do
    theme_paths+=("$DEST_DIR/$theme_name")
done

mapfile -d '' files_with_whitespace < <(
    find "${theme_paths[@]}" -type f -name '*[[:space:]]*' -print0
)

if ((${#files_with_whitespace[@]} == 0)); then
    printf 'No files with whitespace in their names were found\n'
else
    printf '\nFiles with whitespace in their names:\n'
    for file in "${files_with_whitespace[@]}"; do
        printf '  %q\n' "$file"
    done

    printf '\nChoose an option:\n'
    printf '  1) Replace spaces in filenames with hyphens\n'
    printf '  2) Skip renaming\n'
    read -r -p 'Your choice [1/2]: ' rename_choice || rename_choice=''

    case "$rename_choice" in
        1)
            for file in "${files_with_whitespace[@]}"; do
                # This option replaces regular spaces; other whitespace is left unchanged.
                if [[ "$file" != *" "* ]]; then
                    printf 'Skipped (no regular spaces to replace): %q\n' "$file"
                    continue
                fi

                dir_part="$(dirname -- "$file")"
                base_part="$(basename -- "$file")"
                new_file="$dir_part/${base_part// /-}"

                if [[ -e "$new_file" ]]; then
                    printf 'Skipped (destination already exists): %q\n' "$new_file"
                    continue
                fi

                mv -- "$file" "$new_file"
                printf 'Renamed: %q -> %q\n' "$file" "$new_file"
            done
            ;;
        2)
            printf 'No files were renamed.\n'
            ;;
        *)
            printf 'Invalid choice. No files were renamed.\n' >&2
            exit 1
            ;;
    esac
fi

printf '\nSelected Hatter themes installed in %s\n' "$DEST_DIR"
