#!/bin/sh

CONFIG_FILE="/etc/mailbot.conf"

# initialization

set -e
set -u

if which "$0" | grep -q "^/"
	then	BIN_DIR="`dirname '$0'`"
	else	BIN_DIR="`dirname \"\`pwd\`/$0\"`"
  fi

# load configuration
[ ! -e "$CONFIG_FILE" ] && echo "error: configuration file ($CONFIG_FILE) is not available" >&2 && exit 255
. "$CONFIG_FILE"

# load public functions
FUNCTIONS_FILE="$BIN_DIR/functions.sh"
[ ! -e "$FUNCTIONS_FILE" ] && echo "error: include file ($FUNCTIONS_FILE) is not available" >&2 && exit 254
. "$FUNCTIONS_FILE"

############ main ##############

[ $# -ne 1 ] && error_msg 1
ACTION="$1"

case "$ACTION" in
	request)
		echo request
		;;
	auth)
		echo request
		;;
	help)
		echo "syntax: $0 { request | auth | help }"
		;;
	*)
		error 2 "$ACTION"
		;;
  esac
