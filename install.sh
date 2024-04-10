#!/usr/bin/env bash

set -eo pipefail

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
  SHELL_DIR="/usr/share/themes"
else
  DEST_DIR="$HOME/.local/share/icons"
  SHELL_DIR="$HOME/.themes"
fi

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

THEME_NAME=Hatter
COLOR_VARIANTS=('')
THEME_VARIANTS=('')

themes=()
colors=()

usage() {
cat << EOF
  Usage: $0 [OPTION]...

  OPTIONS:
    -d, --dest DIR          Specify destination directory (Default: $DEST_DIR)
    -n, --name NAME         Specify theme name (Default: $THEME_NAME)
    -r, --remove
    -u, --uninstall         Uninstall (remove) icon themes
    -h, --help              Show help
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

echo "Installing '${SHELL_DIR}'..."

  mkdir -p                                                                                   "${SHELL_DIR}"
  cp -r "${SRC_DIR}"/shell/Hatter                             		                     "${SHELL_DIR}"
  cp -r "${SRC_DIR}"/shell/Hatter-dark                             		             "${SHELL_DIR}"

  cd "${THEME_DIR}"
  sed -i "s/${name}/${name}${theme}${color}/g" "${THEME_DIR}"/index.theme

  if [[ ${color} == '' ]]; then
    mkdir -p                                                                                 "${THEME_DIR}"/status
    cp -r "${SRC_DIR}"/src/{actions,animations,apps,categories,devices,emblems,mimes,places,preferences} "${THEME_DIR}"
    cp -r "${SRC_DIR}"/src/status/{16,22,24,32,symbolic}                                     "${THEME_DIR}"/status

    rm -rf "${THEME_DIR}"/places/scalable/user-trash{'','-full'}-dark.svg

    if [[ ${black:-} == 'true' ]]; then
      sed -i "s/#ffffff/#363636/g" "${THEME_DIR}"/status/{16,22,24}/*
    fi

 
    if [[ $DESKTOP_SESSION == '/usr/share/xsessions/budgie-desktop' ]]; then
      cp -r "${SRC_DIR}"/src/status/symbolic-budgie/*.svg                                    "${THEME_DIR}"/status/symbolic
    fi


    if [[ ${theme} != '' ]]; then
      cp -r "${SRC_DIR}"/colors/color${theme}/*.svg                                          "${THEME_DIR}"/places/scalable
    fi

    cp -r "${SRC_DIR}"/links/{actions,apps,categories,devices,emblems,mimes,places,status,preferences} "${THEME_DIR}"
  fi

  (
    cd "${THEME_DIR}"
    ln -sf actions actions@2x
    ln -sf animations animations@2x
    ln -sf apps apps@2x
    ln -sf categories categories@2x
    ln -sf devices devices@2x
    ln -sf emblems emblems@2x
    ln -sf mimes mimes@2x
    ln -sf places places@2x
    ln -sf preferences preferences@2x
    ln -sf status status@2x
  )

  gtk-update-icon-cache "${THEME_DIR}"
}

uninstall() {
  local dest=${1}
  local name=${2}
  local theme=${3}
  local color=${4}

  local THEME_DIR=${dest}/${name}${theme}${color}

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"

  echo "Uninstalling '"${THEME_DIR}"'..."
}

while [[ "$#" -gt 0 ]]; do
  case "${1:-}" in
    -d|--dest)
      dest="$2"
      mkdir -p "$dest"
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
   # -a|--alternative)
   #   alternative='true'
   #   echo "Installing 'alternative' version..."
   #   shift
   #   ;;
  #  -b|--bold)
  #    bold='true'
  #    echo "Installing 'bold' version..."
  #    shift
  #    ;;
    -r|--remove|-u|--uninstall)
      remove='true'
      shift
      ;;
    -t|--theme)
      shift
      for theme in "${@}"; do
        case "${theme}" in
          default)
            themes+=("${THEME_VARIANTS[0]}")
            shift
            ;;
          purple)
            themes+=("${THEME_VARIANTS[1]}")
            shift
            ;;
          pink)
            themes+=("${THEME_VARIANTS[2]}")
            shift
            ;;
          red)
            themes+=("${THEME_VARIANTS[3]}")
            shift
            ;;
          orange)
            themes+=("${THEME_VARIANTS[4]}")
            shift
            ;;
          yellow)
            themes+=("${THEME_VARIANTS[5]}")
            shift
            ;;
          green)
            themes+=("${THEME_VARIANTS[6]}")
            shift
            ;;
          grey)
            themes+=("${THEME_VARIANTS[7]}")
            shift
            ;;
          nord)
            themes+=("${THEME_VARIANTS[8]}")
            shift
            ;;
          all)
            themes+=("${THEME_VARIANTS[@]}")
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

if [[ "${#themes[@]}" -eq 0 ]] ; then
  themes=("${THEME_VARIANTS[0]}")
fi

if [[ "${#colors[@]}" -eq 0 ]] ; then
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

#exit 0
