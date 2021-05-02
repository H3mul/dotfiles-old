#!/usr/bin/env bash

set -Eeuo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1

trap cleanup SIGINT SIGTERM ERR EXIT

usage() {
  cat <<EOF
Usage: $(basename "$0") [-h] [-v] [-i] [app1 app2 ...]

Deploy dotfiles, install packages and otherwise deploy your setup to a new linux
box

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-i              Install packages (requires pacman)
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOCOLOR='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m' GRAY='\033[1;90m'
  else
    NOCOLOR='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW='' GRAY=''
  fi
}

debug() {
  [[ $DEBUG -eq 1 ]] && msg "${*-}"
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  # default values of variables set from params
  DEBUG=0
  INSTALL=0

  while :; do
    case "${1-}" in
    -h | --help)
      usage
      ;;
    -v* | --verbose)
      DEBUG=1
      [[ "${1-}" == "-vv" ]] && set -x
      ;;
    -i)
      INSTALL=1
      ;;
    --no-color)
      NO_COLOR=1
      ;;
    -?*)
      die "Unknown option: $1"
      ;;
    *)
      break
      ;;
    esac
    shift
  done

  args=("$@")
  return 0
}

parse_params "$@"
setup_colors

DEPS_FILE="dependencies.txt"

install_deps () {
  msg "${GREEN}[+] Installing dependencies ...${NOCOLOR}\n"

  [ ! -f "$DEPS_FILE" ] && die "${RED}$DEPS_FILE doesnt exist.${NOCOLOR}"
  [ ! -s "$DEPS_FILE" ] && die ${RED}"$DEPS_FILE is empty.${NOCOLOR}"

  if ! command -v pacman &> /dev/null; then
    msg "  Looks like this is not Arch (pacman is missing)."
    msg "  Please install the following packages manually:\n"
    msg "  ${YELLOW}$(cat "$DEPS_FILE" | tr '\n' ' ' | sed 's/ $/\n/')${NOCOLOR}"
  else
    cat "$DEPS_FILE" | xargs sudo pacman -Syu --noconfirm \
      || die "${RED}Failed to install dependencies${NOCOLOR}"
  fi
}

[[ "$INSTALL" -eq 1 ]] && install_deps
