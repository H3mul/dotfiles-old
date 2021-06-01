#!/usr/bin/env bash

set -Eeuo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1

trap cleanup SIGINT SIGTERM ERR EXIT


########################
# HELPER FUNCS

usage() {
  cat <<EOF
Usage: $(basename "$0") COMMAND [global opts] 

Symlink dotfiles, install packages, load dconf, run custom commands and
otherwise deploy your setup to a new linux box.

Global Options:

-h, --help              Print this help and exit
-v, --verbose           Print script debug info
-t, --test                  Use mock paths instead or "real" ones
-S, --skip-pkg-install      Skip installing pkg dependencies listed in DOTAPP

COMMAND options:

install-deps          Install the dependencies required to run $(basename "$0")
deploy       APPNAME  Deploy an app
new          APPNAME  Create a new app and populate it with a DOTFILE
dconf-dump   APPNAME  Dump the dconf of an app to its app dir (basically the reverse of dconf_load_all())
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
  SKIP_DEPS_INSTALL=0
  DCONF_DUMP=0

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
    -t|--test)
      TEST=1
      ;;
    -S|--skip-pkg-install)
      SKIP_DEPS_INSTALL=1
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


  [ "${#PARAMS[@]}" -eq 0 ] && usage
  COMMAND="${PARAMS[0]}"
  PARAMS=("${PARAMS[@]:1}")

  return 0
}
parse_params "$@"

debug () {
  if [ "$DEBUG" -eq 1 ]; then
    msg "${GRAY}# ${*-}${NOCOLOR}"
  fi
}

notify_msg () {
  msg "${GREEN}[+] ${*-}${NOCOLOR}"
}

warn_msg () {
  msg "${YELLOW}[!] ${*-}${NOCOLOR}"
}

err_msg () {
  msg "${RED}[-] ${*-}${NOCOLOR}"
}

msg () {
  echo >&2 -e "${1-}"
}

die () {
  local msg=$1
  local code=${2-1} # default exit status 1
  err_msg "$msg"
  exit "$code"
}


########################
# INSTALL DEPENDENCIES

DEPS_FILE="dependencies.txt"

install_deps () {
  notify_msg "Installing dependencies ..."
  msg

  [ ! -f "$DEPS_FILE" ] && die "${RED}$DEPS_FILE doesnt exist.${NOCOLOR}"
  [ ! -s "$DEPS_FILE" ] && die ${RED}"$DEPS_FILE is empty.${NOCOLOR}"

  if ! command -v pacman &> /dev/null; then
    msg "  Looks like this is not Arch (pacman is missing)."
    msg "  Please install the following packages manually:\n"
    msg "  ${YELLOW}$(cat "$DEPS_FILE" | tr '\n' ' ' | sed 's/ $/\n/')${NOCOLOR}"
    die
  else
    cat "$DEPS_FILE" | xargs sudo pacman -S --noconfirm --needed \
      || die "${RED}Failed to install dependencies${NOCOLOR}"
  fi
}

[[ "$TEST" -eq 1 ]] && APPS_DIR="./apps-test" || APPS_DIR="./apps"
[[ -d $APPS_DIR ]] || mkdir -p "$APPS_DIR"
debug "Using app dir: $APPS_DIR"


########################
# SET UP A NEW APP

DOTAPP_SAMPLE="./DOTAPP.sample"

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
  apphome="$appdir/apphome"

  [ -d "$appdir" ] && rm -rf "$appdir"; mkdir "$appdir"
  [ -d "$apphome" ] && rm -rf "$apphome"; mkdir "$apphome"
  cp $DOTAPP_SAMPLE $appfile

  set_dotapp_file_var $appfile "appname" "$appname"
  notify_msg "New app added: ${appfile}"
}

create_new_apps () {
  if [ ${#@} -ne 0 ]; then
    for app in $@; do
      create_new_app "$app"
    done
  fi
}


########################
# DEPLOY AN APP

# Clean out variables/functions
unset_dotapp_vars () {
  for var in appname tag pkg_depends pre install_post stow_post dconf_load_all post; do
    unset $var
  done
}

# Populate all vars with empties
load_blank_dotapp_vars () {
  source "$DOTAPP_SAMPLE" || die "Failed to source $DOTAPP_SAMPLE."
}

ensure_app_exists () {
  [ -d "$appdir" ] || die "App '$appname' not found."
  [ -f "$appfile" ] || die "App '$appname' is missing a DOTAPP file."
}

dotapp_method () {
  method="${1-}"

  debug "running $method()"
  $method || die "Failed running $method."
}

# Install pkg_depends from DOTAPP
install_dotapp_pkg_depends () {
  if [ "${#pkg_depends[@]}" -ne 0 ]; then
    [ "$SKIP_DEPS_INSTALL" -eq 1 ] && debug "Skipping dependency install" && return

    ! command -v yay &> /dev/null && \
      warn_msg "yay is not found. Deploy it first, or install the following packages manually and run again with --skip-pkg-install.\n" && \
      msg "${YELLOW}${pkg_depends[*]}${NOCOLOR}" && \
      return

    debug "Installing apps: ${pkg_depends[@]}"
    yay -S --noconfirm --needed "${pkg_depends[@]}"
  fi
}

stow_app () {
  [ ! -d "$appdir/apphome" ] && debug "Skipping stow, app has no apphome dir..." && return

  debug "Stowing $appdir/apphome..."

  set +e
  result=$(stow --orig -t "${HOME}" -d ${appdir} apphome 2>&1)
  [ "$?" -ne 0 ] && "${RED}[-] Stow failed:\n${result}${NOCOLOR}"
  set -e
}

dconf_load () {
  path=${1:-}
  dumpfilename=${2:-}
  dumpfile="$appdconf/$dumpfilename" 
  dump=$DCONF_DUMP

  debug "dconf_load dump:$dump path:$path dumpfile:$dumpfile"

  if [ "$dump" -eq 1 ]; then
    dconf dump "$path" > $dumpfile
  else
    [ ! -f "$dumpfile" ] && (fail_msg "dconf load failed - file missing: $dumpfile" && return)
    dconf load "$path" < $dumpfile
  fi
}

deploy_app () {
  appname="${1-}"
  appdir="$APPS_DIR/$appname"
  appfile="$appdir/DOTAPP"
  apphome="$appdir/apphome"
  appdconf="$appdir/dconf"

  notify_msg "Deploying $appname"
  ensure_app_exists

  # Load DOTAPP vars
  debug "Sourcing $appfile"
  load_blank_dotapp_vars
  source "$appfile" || die "Failed to source '$appname' DOTAPP file."

  # Deploy process:
  # 1. run pre()
  dotapp_method "pre"

  # 2. install dependency packages
  install_dotapp_pkg_depends

  # 3. run install_post()
  dotapp_method "install_post"

  # 4. stow config
  stow_app
  
  # 5. run stow_post()
  dotapp_method "stow_post"

  # 6. deploy dconf
  dotapp_method "dconf_load_all"

  # 7. run post()
  dotapp_method "post"
}

deploy_apps () {
  if [ ${#@} -ne 0 ]; then
    for app in $@; do
      deploy_app "$app"
    done
  fi
}


########################
# DUMP AN APP

dconf_dump_app () {
  appname="${1-}"
  appdir="$APPS_DIR/$appname"
  dconfdir="$appdir/dconf"

  [ -d $dconfdir ] && rm -rf $dconfdir
  dotapp_method "dconf_load_all"
}

dconf_dump_apps () {
  DCONF_DUMP=1
  if [ ${#@} -ne 0 ]; then
    for app in $@; do
      dconf_dump_app "$app"
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
    ;;
  deploy)
    deploy_apps ${PARAMS[@]} 
    ;;
  dconf-dump)
    dconf_dump_apps ${PARAMS[@]} 
    ;;
  *)
    usage
    ;;
esac
