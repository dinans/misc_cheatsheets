#####################################################################################################
#                                       BASIC SCRIPT TEMPLATE                                       #
#               source: https://betterdev.blog/minimal-safe-bash-script-template/                   #
#####################################################################################################

#!/usr/bin/env bash
# Preferred way of shebang. Reason: bash can be in different directories, not neccessarily in /bin

# Change shell behavior for script execution:

## -E fire ERR trap when encountered
## -e exit immediately when command fails, 
## -u treat unset variables as an error and exit  
## -o pipefail - exit code of a pipeline with an error of a rightmost failed command
## -x good option for debugging, pring each command before executing
# NB: In some cases it can be a bad idea to set these variables (-u and -e can give fatal error in some cases, especially in older versions of bash, 
#                                                                -o can produce unexpected error, since in some pipelines non-zero exit code of left commands is expected and normal

set -Eeuox pipefail



# No matter how script ended and where error might have happened -- clean up in the end
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

# This gets script's path, no matter where it has been called from. Useful when script has relative paths in it (which is a terrible idea)
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

# Script's usage doc
usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.


Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-f, --flag      Some flag description
-p, --param     Some param description
EOF

EOF
  exit
}

# Setup colors in case if script will produce a lot of logs (works with msg only, not with echo)
setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

# Nicely formatted script's die
die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

# Parse script's params

parse_params() {
  # default values of variables set from params
  flag=0
  param=''

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -f | --flag) flag=1 ;; # example flag
    -p | --param) # example named parameter
      param="${2-}"
      shift
      ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  [[ -z "${param-}" ]] && die "Missing required parameter: param"
  [[ ${#args[@]} -eq 0 ]] && die "Missing script arguments"

  return 0
}

parse_params "$@"
setup_colors


msg "${RED}Read parameters:${NOFORMAT}"
msg "- flag: ${flag}"
msg "- param: ${param}"
msg "- arguments: ${args[*]-}"

# Here goes the script logic itself ...

