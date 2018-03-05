
# Note: Bash compatible

# Defining colors
_NO_COLOR="\033[0m"
_BLUE="\033[1;34m"
_GREEN="\033[1;32m"
_YELLOW="\033[1;33m"
_RED="\033[1;31m"

alias errcho=">&2 echo"

echo_info () {
    msg="$1"
    echo -e "${_BLUE}INFO: $msg${_NO_COLOR}"
}

echo_succ () {
    msg="$1"
    echo -e "${_GREEN}SUCCESS: $msg${_NO_COLOR}"
}

echo_warn () {
    msg="$1"
    errcho -e "${_YELLOW}WARNING: $msg${_NO_COLOR}"
}

on_error () {
    msg="$1"
    # Default error code is 1
    err_code=${2-1}
    errcho -e "${_RED}ERROR: $msg${_NO_COLOR}"
    exit $err_code
}
