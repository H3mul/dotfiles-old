#!/usr/bin/env bash

set -Eeuo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1

trap cleanup SIGINT SIGTERM ERR EXIT


########################
# HELPER FUNCS

usage() {
  cat <<EOF
Usage: $(basename "$0") COMMAND [global opts] 

Deploy dotfiles, install packages and otherwise deploy your setup to a new linux
box

Global Options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-i              Install packages (requires pacman)
--test          Use mock paths instead or "real" ones

COMMAND options:

install-deps    Install the dependencies required to run $(basename "$0")
new APPNAME     Create a new app and populate it with a DOTFILE
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
setup_colors

parse_params() {
  # default values of variables set from params
  DEBUG=0
  TEST=0

  # positional params
  PARAMS=()

  # Parse flags
  while :; do
    case "${1-}" in
    -h | --help)
      usage
      ;;
    -v* | --verbose)
      DEBUG=1
      [[ "${1-}" == "-vv" ]] && set -x
      ;;
    --no-color)
      NO_COLOR=1
      ;;
    --test)
      TEST=1
      ;;
    -?*)
      die "Unknown option: $1"
      ;;
    [^-]*)
      PARAMS=(${PARAMS[@]} "${1-}")
      ;;
    *)
      break
      ;;
    esac
    shift
  done

  COMMAND="${PARAMS[0]}"
  PARAMS=("${PARAMS[@]:1}")

  return 0
}
parse_params "$@"

debug() {
  [[ $DEBUG -eq 1 ]] && msg "${GRAY}${*-}${NOCOLOR}"
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


########################
# INSTALL DEPENDENCIES

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

[[ "$TEST" -eq 1 ]] && APPS_DIR="./apps-test" || APPS_DIR="./apps"
[[ -d $APPS_DIR ]] || mkdir -p "$APPS_DIR"
debug "[*] Using app dir: $APPS_DIR"


########################
# SET UP A NEW APP

DOTAPP_SAMPLE="./DOTAPP.sample"

# Clean out variables/functions
unset_dotapp_vars () {
  for var in appname tag pre stow_post dconf_load_all post; do
    unset $var
  done
}

# Populate all vars with empties
load_blank_dotapp_vars () {
  source "$DOTAPP_SAMPLE"
}

# Edit the DOTFILE and set a variable
set_dotapp_file_var () {
  file="${1-}"
  varname="${2-}"
  varval="${3-}"
  vartype="${4-string}"
  
  # Format value based on type
  case $vartype in
    string)
      varval="\"$varval\""
      ;;
    array)
      varval="(\"$varval\")"
      ;;
  esac

  sed -i "s/^$varname=.*$/$varname=$varval/" "$file"
}

# Create the app dir, copy over the sample DOTAPP and initialize it somewhat
create_new_app () {
  appname="${1-}"
  appdir="$APPS_DIR/$appname"
  appfile="$appdir/DOTAPP"

  [[ -d "$appdir" ]] || mkdir "$appdir"
  cp $DOTAPP_SAMPLE $appfile

  set_dotapp_file_var $appfile "appname" "$appname"
  msg "${GREEN}[+] New app added: ${appfile}"
}

create_new_apps () {
  if [ ${#@} -ne 0 ]; then
    for app in $@; do
      create_new_app "$app"
    done
  fi
}


########################
# MAIN ACTION LOOP

case "$COMMAND" in
  install-deps)
    install_deps
    ;;
  new)
    create_new_apps ${PARAMS[@]} 
esac
