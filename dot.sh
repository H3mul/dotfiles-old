#!/usr/bin/env bash

set -Eu

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
    -v | --verbose)
      DEBUG=1
      ;;
    -vv)
      DEBUG=2
      ;;
    -vvv)
      DEBUG=3
      set -x
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
  level="${2:-1}"
  if [ "$DEBUG" -ge "$level" ]; then
    msg "${GRAY}# ${1:-}${NOCOLOR}"
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

sub_msg () {
  msg "${BLUE}    ==> ${NOCOLOR}${*-}"
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

contains_element () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

########################
# INSTALL DEPENDENCIES

DEPS_FILE="dependencies.txt"

install_deps () {
  notify_msg "Installing dependencies ..."
  msg

  [ ! -f "$DEPS_FILE" ] && die "$DEPS_FILE doesnt exist."
  [ ! -s "$DEPS_FILE" ] && die "$DEPS_FILE is empty."

  if ! command -v pacman &> /dev/null; then
    msg "  Looks like this is not Arch (pacman is missing)."
    msg "  Please install the following packages manually:\n"
    msg "  ${YELLOW}$(cat "$DEPS_FILE" | tr '\n' ' ' | sed 's/ $/\n/')${NOCOLOR}"
    die
  else
    cat "$DEPS_FILE" | xargs sudo pacman -S --noconfirm --needed \
      || die "Failed to install dependencies"

    deploy_apps yay stow
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

  [ -d "$appdir" ] || mkdir "$appdir"
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

dotapp_method_all () {
  method="${1:-}"
  shift
  appdirs=("$@")

  for appdir in "${appdirs[@]}"; do
    load_app_vars "$appdir"
    dotapp_method "$method"
  done
}

install_packages () {
  local packages=("$@")
  [ ${#packages[@]} -eq 0 ] && return
  [ "$SKIP_DEPS_INSTALL" -eq 1 ] && debug "Skipping dependency install" && return

  ! command -v yay &> /dev/null && \
    warn_msg "yay is not found. Deploy it first, or install the following packages manually and run again with --skip-pkg-install.\n" && \
    msg "${YELLOW}${packages[*]}${NOCOLOR}" && \
    return

  debug "Installing apps: ${packages[*]}"
  yay -S --noconfirm --needed ${packages[@]} || die "Aborting due to errors while installing packages."
}

stow_app () {
  [ ! -d "$appdir/apphome" ] && debug "Skipping stow, app has no apphome dir..." && return

  result=$(stow --orig -t "${HOME}" -d ${appdir} apphome 2>&1)
  [ "$?" -ne 0 ] && err_msg "Stow failed:\n${result}"
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

# Set all vars associated with an app
load_app_vars () {
  appdir="${1-}"
  appfile="${appdir}DOTAPP"
  apphome="${appdir}apphome"
  appdconf="${appdir}dconf"

  [ ! -f "$appfile" ] && return 1

  load_blank_dotapp_vars
  source "$appfile" || die "Failed to source '$appfile' DOTAPP file."
}

# Deploys an app currently set up ( see load_app_vars() )
deploy_app () {
  appdir="${1:-}"
  load_app_vars "$appdir"

  notify_msg "Deploying $appname"

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

gather_matching_apps () {
  local targets=(${1:-})
  local exclusions=(${2:-})
  # Add the fake "all" tag to search vals for the "all" target to grab all apps
  local search_vals=($appname "${tags[@]}" "all")

  for exclusion in "${exclusions[@]}"; do
    contains_element "$exclusion" "${search_vals[@]}"
    # Matches an exclusion tag, skip this app
    [ "$?" -eq 0 ] && return
  done

  for target in "${targets[@]}"; do
    contains_element "$target" "${search_vals[@]}"
    # Matches a target tag, add the app
    if [ "$?" -eq 0 ]; then
      all_appdirs=("${all_appdirs[@]}" $appdir)
      all_pkg_depends=("${all_pkg_depends[@]}" "${pkg_depends[@]}")
    fi
  done
}

deploy_apps () {
  local selection=("$@")
  local targets=()
  local exclusions=()

  for sel in "${selection[@]}"; do
    if [[ $sel == ^* ]]; then
      exclusions=("${exclusions[@]}" ${sel:1})
    else
      targets=("${targets[@]}" $sel)
    fi
  done

  # If the targets are empty, but we have exclusions, make the target "all"
  [ ${#targets[@]} -eq 0 ] && [ ${#exclusions[@]} -gt 0 ] && targets=("all")

  all_appdirs=()
  all_pkg_depends=()

  map_apps_list "gather_matching_apps" "${targets[*]}" "${exclusions[*]}"

  [ ${#all_appdirs[@]} -eq 0 ] && die "No matching apps found."

  # Run the pre method of all apps
  dotapp_method_all "pre" "${all_appdirs[@]}"

  notify_msg "Installing prerequisite packages..."

  # Install all the collected dependencies at once
  install_packages "${all_pkg_depends[@]}"

  # Proceed to install each app individually
  for appdir in "${all_appdirs[@]}"; do
    deploy_app $appdir
  done
}


########################
# DUMP AN APP

dconf_dump_app () {
  [ -d $appdconf ] && rm -rf $dconfdir
  dotapp_method "dconf_load_all"
}

dconf_dump_apps () {
  DCONF_DUMP=1
  map_apps_list "dconf_dump_app"
  DCONF_DUMP=0
}


########################
# COLLECT APP INFO

# Print general info about the app in one line
# Needs the app vars to be loaded (eg, use in map_apps_list()
print_app () {
  app_string="$appname"

  if [ "${#tags[@]}" -ne 0 ]; then
    printf -v tags_string '%s,' "${tags[@]}"
    tags_string="${tags_string%,}"
    app_string=$(printf "%-*s ${YELLOW}[ %s ]${NOCOLOR}\n" 15 $app_string $tags_string)
  fi

  msg "$app_string"
}

# Simluates a "map" action. Pass a function to call on every valid app with app
# vars loaded. If the function returns a -1, we stop loop execution.
map_apps_list () {
  func="${1:-}"
  [ -z "$func" ] && return
  shift

  for dir in $APPS_DIR/*/; do
    load_app_vars $dir

    if [ "$?" -eq 1 ]; then
      debug "Skipping $dir, not a valid app..." 2
      continue
    fi

    # If the function returns a -1, we stop loop execution.
    $func "$@"
    [ "$?" -eq -1 ] && break

  done
}

# Print a list of apps
print_apps () {
  notify_msg "Available apps:"
  map_apps_list "print_app"
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
  list)
    print_apps
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
