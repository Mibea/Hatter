# Install-Hatter
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
set -euo pipefail

ROOT_UID=0

# Bepaal de map waarin dit script staat en gebruik de Build-map ernaast.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/Build"

if [[ "$UID" -eq "$ROOT_UID" ]]; then
    DEST_DIR="/usr/share/icons"
else
    DEST_DIR="$HOME/.local/share/icons"
fi

if [[ ! -d "$BUILD_DIR" ]]; then
    printf 'Fout: Build-map not found, build hatter first: %s\n' "$BUILD_DIR" >&2
    exit 1
fi

mkdir -p -- "$DEST_DIR"

shopt -s nullglob
for source_dir in "$BUILD_DIR"/*/; do
    [[ -d "$source_dir" ]] || continue

    theme_name="$(basename -- "${source_dir%/}")"
    destination_dir="$DEST_DIR/$theme_name"

    if [[ -d "$destination_dir" ]]; then
        printf 'Remove old icon folders: %s\n' "$destination_dir"
        rm -rf -- "$destination_dir"
    fi

    printf 'Kopieer %s naar %s\n' "$theme_name" "$DEST_DIR"
    cp -a -- "$source_dir" "$DEST_DIR/"

    printf 'update icon-cache for %s\n' "$theme_name"
    gtk-update-icon-cache "$destination_dir"
done

rm -rf -- "$BUILD_DIR"

printf 'Deleted %s\n' "$BUILD_DIR"