error_msg()
# print the according error message and exit
# error messages are take from etc/error-messages.txt
# params:
#	NUM		- error number
#	ERROR_INFO	- additional information
{
	NUM="$1"; shift
	SUBST="$*"
	sed -rn "/^$NUM:/p; s/^$NUM:[:spaces:]*//; s/_INFO_/$SUBST/" "$ERR_MSG_FILE"
	# extract lines, that are prefixed with "NUM:", remove this part and replace _INFO_ by ERROR_INFO
	exit "$NUM"
}


