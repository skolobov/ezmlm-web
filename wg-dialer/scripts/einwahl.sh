#!/bin/sh

OUTDEV="ippp0"
HOMEDIR="/home/WGDialer/"
DialerModem="/usr/bin/wvdial"
DialerISDN="/usr/sbin/isdnctrl"
DialerISDNWahlHilfe=${HOMEDIR}scripts/waehleISDN.sh
DialPIDDatei=${HOMEDIR}data/dialer.pid
DialerLog=${HOMEDIR}data/dialer.log
DialerStatus=${HOMEDIR}data/dialer.info	
# enthaelt Namen des Verbindungsaufbauenden / Einwahltarif
# Format der Dialer-Status-Datei:
# "Kosten" folgende Zeilen: "Name der/s Einwaehlenden"

if test 0 -lt `echo $OUTDEV | grep ippp | wc -l`;
	then	Anschkuss=isdn
	else	Anschluss=analog
  fi


function istDialerGestartet()
{
}



function beendeDialer()
{
	if istDialerGestartet; then
		AdminNachricht "Der Dialer wird beendet ..."
		if test "$Geraet" = "analog"; then
			kill `cat $DialPIDDatei`
		  else
			$DialerISDN hangup $OUTDEV
		  fi
		# jetzt sollte die Aufraeumaktion gestartet werden
		test -e $DialPIDDatei && rm $DialerStatus
		DialerIstBeendet
		test -n "X"
	  else	
		AdminFehler "beendeDialer: nicht gestartet"
		test -z "X"
	  fi
}


function starteDialer()
{
	if istDialerGestartet; then
		AdminFehler "Dialer lief bereits ohne aktive Nutzer!"
		test -n "X"
	  fi
	holeProviderInfo Preis
	local preis=$ERG
	holeProviderInfo Name
	local name=$ERG
	AdminNachricht "Aufbau der Verbindung"
	echo -e "$preis\t$name" >$DialerStatus
	if test -e $VerbindungsWunschDatei; then
		cat $VerbindungsWunschDatei >>$DialerStatus
		test -n "X"
	  else
		AdminFehler "sD: keine Verb.-Anforderungen!"
		test -z "X"
	  fi
	echo -e "\n`date` - ######## Start des Waehlprogramms #########" >>$DialerLog
	$0 rufe-dialer-raw &
	local pid=$!
	echo $pid >$DialPIDDatei
	istDialerGestartet
	# damit der Rueckgabestatus stimmt
}

function rufeDialerRaw()
{
	if test $Geraet = "analog"; then
		$DialerModem $name >>$DialerLog 2>>$DialerLog &
		local pid=$!
		trap "kill $pid" 0
		wait $pid
	  else
		holeProviderInfo Name
		$DialerISDNWahlHilfe $ERG $OUTDEV 2>>$DialerLog >>$DialerLog
		$DialerISDN dial $OUTDEV
		sleep 60
		
	  fi
}


# Aufraeumarbeiten
function DialerIstBeendet()
{
	holeAnzahlNutzer
	local anz=$ERG
	test $anz -gt 0 && AdminFehler "Dialer beendet trotz aktiver Nutzer"
	trenneAlleVerbindungen
	test $Geraet = "analog" -a -e "$DialPIDDatei" && rm $DialPIDDatei
	test -e "$DialerStatus" && rm $DialerStatus
	test -e "$VerbindungsWunschDatei" && rm $VerbindungsWunschDatei
	test $anz -eq 0
}



# liefert "Preis" oder "Name (Dialer-Parameter)"
function holeProviderInfo()  # gewuenschte Information
# WICHTIG: Aenderung, damit angewaehlter Tarif bezahlt wird
{
	# Provider: 0 - Freenet-Super (Nebenzeit)
	#           1 - Freenet-Super (Hauptzeit)
	#           2 - Freenet-XXL (Sonntags)
	local prov
	local jetzt="`date +%H%M`"	# liefert die aktuelle Stunde
	if test $jetzt -lt 730; then
		prov=0
	  elif test $jetzt -lt 1730; then
		prov=1
	  elif test $jetzt -lt 2130; then
		prov=0
	  else
		prov=0
	  fi
	local tag="`date +%w`"
	test $tag -eq 0 -o $tag -eq 6 && prov=0
	test $tag -eq 0 && prov=2
	local preis
	local name
	case $prov in
		0 ) preis=99; name="FreeNet-Super";;
		1 ) preis=145; name="FreeNet-Super";;
		2 ) preis=0; name="FreeNet-XXL";;
	  esac
	if test "$1" = "Preis"; then ERG=$preis
	  elif test "$1" = "Name"; then ERG="$name"
	  else AdminFehler "ProviderInfo: fehlerhafte Anfrage"
	  fi
	test -n "X"
}


case "$1" in
	starte-einwahl )
		starteDialer
	einwahl-ist-beendet )
		DialerIstBeendet
		;;
	hole-kosten-satz )
		holeProviderInfo Preis
		echo $ERG
		;;
	hole-tarif-name )
		holeProviderInfo Name
		echo $ERG
		;;
	* )
		echo "einwahl.sh { einwahl-ist-beendet | hole-kosten-satz }
		;;
  esac











