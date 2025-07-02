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

THEME_NAME=Hatter
COLOR_VARIANTS=('')
THEME_VARIANTS=('' '-yellow' '-green' '-orange' '-pink' '-purple' '-red' '-slate' '-teal')

themes=('-yellow' '-green' '-orange' '-pink' '-purple' '-red' '-slate' '-teal')
colors=()



usage() {
cat << EOF
  Usage: $0 [OPTION]...

  OPTIONS:
    -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)
    -n, --name NAME         Specify theme name (Default: $THEME_NAME)
    -t , --theme COLOR   Gives you folders in colors
    -r, --remove, -u, --uninstall         Uninstall (remove) icon themes
    -h, --help              Show help
    -u, --updatetool        Install the update tool
EOF
}
install() {
  local dest=${1}
  local name=${2}
  local theme=${3}
  local color=${4}
  local THEME_DIR=${dest}/${name}${theme}${color}
  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"
  echo "Installing '${THEME_DIR}'..."
  mkdir -p                                                                                   "${THEME_DIR}"
  cp -r "${SRC_DIR}"/{COPYING,AUTHORS}                                                       "${THEME_DIR}"
  cp -r "${SRC_DIR}"/src/index.theme                                                         "${THEME_DIR}"

  #cd "${THEME_DIR}"
  sed -i "s/${name}/${name}${theme}${color}/g" "${THEME_DIR}"/index.theme
   sed -i "s/hicolor/Hatter,hicolor/g" "${THEME_DIR}"/index.theme 
if [[ ${theme} != '' ]]; then
    mkdir -p                                                                            "${THEME_DIR}"/places
	cp -r "${SRC_DIR}"/src/places/{16,22,24,scalable,symbolic}                               "${THEME_DIR}"/places   
       	cd ${dest}
	cp -r "${SRC_DIR}"/colors/color${theme}/*.svg  					"${THEME_DIR}"/places/scalable
	cp -r "${SRC_DIR}"/colors/color${theme}/*.svg  					"${THEME_DIR}"/places/24
	cp -r "${SRC_DIR}"/colors/color${theme}/*.svg  					"${THEME_DIR}"/places/22
	cp -r "${SRC_DIR}"/colors/color${theme}/*.svg  					"${THEME_DIR}"/places/16
   fi
  (
    cd "${THEME_DIR}"
    ln -sf places places@2x
  )
  gtk-update-icon-cache "${THEME_DIR}"
}
while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -t|--theme)
      shift
      for theme in "${@}"; do
        case "${theme}" in
          default)
            themes+=("${THEME_VARIANTS[0]}")
            shift
            ;;
          yaru)
            themes+=("${THEME_VARIANTS[1]}")
            shift
            ;;
          yellow)
            themes+=("${THEME_VARIANTS[2]}")
            shift
            ;;
            green)
            themes+=("${THEME_VARIANTS[3]}")
            shift
            ;;
            orange)
            themes+=("${THEME_VARIANTS[4]}")
            shift
            ;;
            pink)
            themes+=("${THEME_VARIANTS[5]}")
            shift
            ;;
            purple)
            themes+=("${THEME_VARIANTS[6]}")
            shift
            ;;
            red)
            themes+=("${THEME_VARIANTS[7]}")
            shift
            ;;
            slate)
            themes+=("${THEME_VARIANTS[8]}")
            shift
            ;;
            teal)
            themes+=("${THEME_VARIANTS[9]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized theme variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
        # echo "Installing '${theme}' folder version..."
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [[ "${#themes[@]}" -eq 0 ]]; then
  themes=("${THEME_VARIANTS[0]}")
fi

if [[ "${#colors[@]}" -eq 0 ]]; then
  colors=("${COLOR_VARIANTS[@]}")
fi
install_theme() {
  for theme in "${themes[@]}"; do
    for color in "${colors[@]}"; do
      install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${theme}" "${color}"
    done
  done
}

uninstall_theme() {
  for theme in "${THEME_VARIANTS[@]}"; do
    for color in "${COLOR_VARIANTS[@]}"; do
      uninstall "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${theme}" "${color}"
    done
  done
}




if [[ "${remove}" == 'true' ]]; then
  uninstall_theme
else
  install_theme
fi

if [[ "${update}" == 'true' ]]; then
  cp -r "${SRC_DIR}"/update-tool/Hatter-update.sh "$HOME/.local/share/icons"
  cp -r "${SRC_DIR}"/update-tool/Hatter.desktop "$HOME/.local/share/applications"
fi
      	
#exit 0
