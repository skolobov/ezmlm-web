#!/bin/sh

DEV="ippp0"

test -n "$2" && DEV=$2



function setzeNormaleParameter()
{
	isdnctrl hangup $DEV
	sleep 1
	# ifconfig $DEV down
	isdnctrl delif $DEV
	isdnctrl addif $DEV
	isdnctrl dialmode $DEV manual
	isdnctrl eaz $DEV 4007523
	isdnctrl huptimeout $DEV 300 
	isdnctrl dialmax $DEV 50
	isdnctrl secure $DEV on
	isdnctrl callback $DEV off
	isdnctrl encap $DEV syncppp
	isdnctrl l2_prot $DEV hdlc
	isdnctrl l3_prot $DEV trans
	isdnctrl pppbind $DEV
	nums=`isdnctrl list $DEV | grep Outgoing: | cut -d " " -f 16-`
	for num in $nums;
		do	isdnctrl delphone $DEV out $num
	  done
}

case "$1" in
	FreeNet-Super | normal )
		setzeNormaleParameter
		isdnctrl addphone $DEV out 01019019231760
		#isdnctrl addphone $DEV out 0101901929
		;;
	FreeNet-XXL | xxl )
		setzeNormaleParameter
		isdnctrl addphone $DEV out 030221600707
		isdnctrl addphone $DEV out 089890900707
		isdnctrl addphone $DEV out 022126090707
		isdnctrl addphone $DEV out 023122620707
		isdnctrl addphone $DEV out 069698600707
		isdnctrl addphone $DEV out 071122670707
		# korrekt? isdnctrl addphone $DEV out 04035070707
		isdnctrl addphone $DEV out 034123890707
		isdnctrl addphone $DEV out 091121000707
		isdnctrl huptimeout $DEV 1200 
		;;
	status )
		isdnctrl list $DEV
		;;
	tarif )
		telNormal=`isdnctrl list $DEV | grep 01019019231760`
		telXXL=`isdnctrl list $DEV | grep 030221600707`
		if test -n "$telNormal" -a -n "$telXXL"; then
			echo "Warnung: ungueltige Einstellungen!"
		  elif test -n "$telNormal"; then
			echo "FreeNet-Super: 0,99/1,45c (Mo-Sa)"
		  elif test -n "$telXXL"; then
			echo "XXL-kostenloser Sonntag"
		  else
			echo "unbekannter Tarif!"
		  fi
		;;
	* )
		echo "Syntax: { normal | xxl | status | tarif }"
		;;
  esac

exit 0



