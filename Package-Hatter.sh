#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/Build"
PARENT_DIR="$(dirname -- "$BUILD_DIR")"

if [[ ! -d "$BUILD_DIR" ]]; then
    printf 'Error: Build directory not found: %s\n' "$BUILD_DIR" >&2
    exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
    printf 'Error: the zip command is not installed.\n' >&2
    exit 1
fi

kde_dirs=()
other_dirs=()

shopt -s nullglob
for path in "$BUILD_DIR"/*/; do
    name="$(basename -- "${path%/}")"

    if [[ "${name,,}" == *kde* ]]; then
        kde_dirs+=("$name")
    else
        other_dirs+=("$name")
    fi
done

if ((${#kde_dirs[@]} == 0 || ${#other_dirs[@]} == 0)); then
    printf 'Error: Build must contain at least one KDE-named directory and one other directory.\n' >&2
    printf 'Build was not deleted.\n' >&2
    exit 1
fi

# Build archives in a temporary directory so Build is preserved if compression fails.
TEMP_DIR="$(mktemp -d "$PARENT_DIR/.hatter-zips.XXXXXX")"
trap 'rm -rf -- "$TEMP_DIR"' EXIT

(
    cd -- "$BUILD_DIR"
    zip -r "$TEMP_DIR/Hatter-kde.zip" -- "${kde_dirs[@]}"
    zip -r "$TEMP_DIR/Hatter.zip" -- "${other_dirs[@]}"
)

DOWNLOAD_DIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
mkdir -p -- "$DOWNLOAD_DIR"

# Move completed archives to the user's Downloads folder, replacing existing files.
mv -f -- "$TEMP_DIR/Hatter-kde.zip" "$DOWNLOAD_DIR/Hatter-kde.zip"
mv -f -- "$TEMP_DIR/Hatter.zip" "$DOWNLOAD_DIR/Hatter.zip"

rm -rf -- "$BUILD_DIR"

printf 'Created the ZIP files in %s\n' "$DOWNLOAD_DIR"

printf 'Deleted %s\n' "$BUILD_DIR"
