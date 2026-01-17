#!/usr/bin/env bash

set -eo pipefail

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
fi

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

rm -rf "${DEST_DIR}"/Hatter
rm -rf "${DEST_DIR}"/Hatter-Blue
rm -rf "${DEST_DIR}"/Hatter-Green
rm -rf "${DEST_DIR}"/Hatter-Orange
rm -rf "${DEST_DIR}"/Hatter-Pink
rm -rf "${DEST_DIR}"/Hatter-Purple
rm -rf "${DEST_DIR}"/Hatter-Red
rm -rf "${DEST_DIR}"/Hatter-Slate
rm -rf "${DEST_DIR}"/Hatter-Teal
rm -rf "${DEST_DIR}"/Hatter-Yellow
rm -rf "${DEST_DIR}"/Hatter-Yaru
rm -rf "${DEST_DIR}"/Hatter-png
rm -rf "${DEST_DIR}"/Hatter-kde
rm -rf "${DEST_DIR}"/Hatter-kde-dark
rm -rf "${DEST_DIR}"/Hatter-kde-light

    cp -r "${SRC_DIR}"/Hatter                                                   "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-Blue                                              "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-Green                                             "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-Orange                                            "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-Pink                                              "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-Purple                                            "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-Red                                               "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-Slate                                             "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-Teal                                              "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-Yellow                                            "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-Yaru                                              "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-png                                              "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-kde                                              "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-kde-dark                                              "${DEST_DIR}"
    cp -r "${SRC_DIR}"/Hatter-kde-light                                              "${DEST_DIR}"

  
	gtk-update-icon-cache "${DEST_DIR}"/Hatter
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-Blue
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-Green
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-Orange
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-Pink
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-Purple
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-Red
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-Slate
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-Teal
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-Yellow
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-Yaru
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-png
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-kde
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-kde-dark
	gtk-update-icon-cache "${DEST_DIR}"/Hatter-kde-light

  

