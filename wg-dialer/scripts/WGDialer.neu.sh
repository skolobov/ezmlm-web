#!/bin/sh 


# Beginn des Scripts
HOMEDIR="/home/WGDialer/"
PIDDatei=${HOMEDIR}data/WGDialer.pid
WarteSekunden=2
WarteSchleifen=10
ScriptLog=${HOMEDIR}data/WGDialer.log
WGET="/usr/bin/wget --spider http://www.freenet.de &>${HOMEDIR}data/wget.log &"
IPTABLES="/usr/sbin/iptables"
SitzungsPrefix=${HOMEDIR}data/sitzung/
NutzerLogPrefix=${HOMEDIR}data/nutzer/
AdminFehlerLog=${HOMEDIR}data/fehler.log
AdminLog=${HOMEDIR}data/meldungen.log
NutzerListenDatei=${HOMEDIR}data/nutzer.liste
VerbindungsWunschDatei=${HOMEDIR}data/verbindungs.anforderung
EinwahlSkript=${HOMEDIR}scripts/einwahl.sh

# Format der Nutzerdateien:
# "Datum (lesbar)" "Datum (auswertbar)" "Kostensatz" "Anzahl der Teilnehmer" "Kosten der Teilverbindung" "Dauer"
# Format der Sitzungsdateien:
# "Beginn der/s Verbindung(-sabschnitts) in Sek. seit 1970" /
# "lesbares Datum"


# Format der Nutzerlistendatei:
# "Nutzername" "IP"


############ Protokollierung ##################

function aktiviereSkriptLog()
{
	exec 2>>$ScriptLog
	echo -e "\n\nSitzungsbeginn:" `date` >> ${HOMEDIR}data/WGDialer.log

	set -xu
	#set -u
}

function AdminNachricht()	# Para: Text
{
	echo -e "`date` - $1" >>$AdminLog
}


function AdminFehler()	# Para: Text
{
	AdminNachricht "Fehler: $1"
	echo -e "`date` - $1" >>$AdminFehlerLog
}


################ Konsistenz ################

function pruefeStatus()
{
	holeAktiveNutzer
	local nutzer=$ERG
	holeAnzahlNutzer
	local AnzahlNutzer=$ERG
	local t=
	test -e $VerbindungsWunschDatei && (istDialerGestartet || (t="? Verbindungswuensche ohne gestarteten Dialer" && rm $VerbindungsWunschDatei))
	if test 0 -lt $AnzahlNutzer; then
		istDialerGestartet || (t="? Nutzer ($nutzer) ohne Verbindung -> Trennung" && trenneAlleVerbindungen)
	  fi
	test 0 -eq $AnzahlNutzer -a ! -e $VerbindungsWunschDatei && istDialerGestartet && (beendeDialer; t="? Verbindung ohne Nutzer")
	test -e $NutzerListenDatei || t="? keine Nutzerlistendatei vorhanden!"
	test -n "$t" && AdminFehler "$t"
	test -z "$t"
}


# pruefe, ob Skript bereits aktiv, falls ja, dann bis zu sechs Sekunden auf
# Ende des Parallelprozesses warten, sonst Abbruch
function pruefeWeitereInstanz()
{
	local count=0
	local PID
	local COMMAND
	while test "$1" != "reset" -a -e $PIDDatei -a $WarteSchleifen -gt $count; do
		PID=`cat $PIDDatei`
		if test -z "$PID"; then
			rm $PIDDatei
		  else
			COMMAND=`ps -p $PID -o comm |tail -1`
			if test `echo $0 | grep $COMMAND | wc -l` -eq 0; then
				test -e $PIDDatei && rm $PIDDatei
			  else
				let count=count+1
				sleep $WarteSekunden
			  fi
		  fi
	  done

	test -e $PIDDatei && AdminFehler "p-w-I: Wartezeit ueberschritten" && exit 1
	trap "rm $PIDDatei" 0
	echo $$ > $PIDDatei
}


################### Sitzungsverwaltung ####################

# sollte nur von "aktualisiereAlleSitzungen" aufgerufen werden
function verarbeiteSitzungsDatei()	# Para: Nutzername
{
	function holeSitzungsDauer()	# Para: Nutzername
	{
		local jetzt=`date +%s`
		local beginn=`tail -1 $SitzungsPrefix$1 | cut -f 1`
		let ERG=jetzt-beginn
	}
	# liefert die Pro-Minute-Kosten der atuell gewaehlten Verbindung
	function holeAktuellenKostenSatz()
	{
		ERG="`$EinwahlSkript hole-kosten-satz`"
		test -n "X"
	}


	function holeSitzungsKosten()	# Para: Nutzername
	{
		holeAktuellenKostenSatz
		local pro=$ERG
		holeSitzungsDauer $1
		local dauer
		local gesamtKosten
		let dauer=ERG+45
		  # "45" als Korrektur wegen der Minutenabrechnung
		let gesamtKosten=pro*dauer/60
		holeAnzahlNutzer
		local anz=$ERG
		let ERG=gesamtKosten/anz
		test 0 -eq $ERG && AdminFehler "hSK: kostenfrei ($pro/$dauer/$anz)?"
		test -n "X"
	}
	
	holeSitzungsKosten $1
	local kosten=$ERG
	holeSitzungsDauer $1
	local dauer=$ERG
	holeAnzahlNutzer
	local anz=$ERG
	holeAktuellenKostenSatz
	local kostenSatz
	let kostenSatz=ERG/anz
	echo -e "`date`\t`date +%Y%m%d`\t$kostenSatz\t$anz\t$kosten\t$dauer" >>$NutzerLogPrefix$1
}




function aktualisiereAlleSitzungen()
{
	local SITZUNG
	holeAktiveNutzer
	local aktiveNutzer="$ERG"
	if test -n "$aktiveNutzer"; then
		for SITZUNG in $aktiveNutzer; do
			verarbeiteSitzungsDatei $SITZUNG
			erstelleSitzungsDatei $SITZUNG
		  done
	  fi
	test -n "X"
}


function loescheSitzungsDatei()    # Para: Nutzername
{
    rm $SitzungsPrefix$1
}


function erstelleSitzungsDatei()	# Para: Nutzername
{
	echo -e "`date +%s`" >$SitzungsPrefix$1
}


################# Nutzerverwaltung ####################

function holeAktiveNutzer()
{
	ERG=`ls $SitzungsPrefix`
}


function holeAnzahlNutzer()
{
	ERG=`ls $SitzungsPrefix|wc -l`
	local aN=`ls $SitzungsPrefix`
	test -z "$aN" && ERG=0
	test -n "X"
}


function verbindeNutzer()	# Parameter: Nutzername
{
	holeAnzahlNutzer
	local anz=$ERG
	if test 0 -eq $anz; then
		meldeVerbindungsWunschAn $1		
		istDialerGestartet || starteDialer
	  elif istNutzerAktiv $1; then
		AdminFehler "$1 versucht sich mehrfach anzumelden"
	  else
		test 0 -lt $anz && NutzerVerbindungenHergestellt $1
	  fi
}


function NutzerVerbindungenHergestellt()       # Para: Nutzernamen
{
	holeAnzahlNutzer
	test 0 -lt $ERG && aktualisiereAlleSitzungen
	local nutzer
	for nutzer in $1; do
		if istNutzerOK "$nutzer"; then
			AdminNachricht "$nutzer oeffnet die Verbindung"
			erstelleSitzungsDatei $nutzer
		  else
			AdminFehler "ungueltiger Nutzer: $nutzer"
		  fi
	  done
	aktualisiereWeiterleitungen
}


function holeVerbindungsStatus()
{
	local zustand="unzulaessiger Status"
	holeAnzahlNutzer
	local anz=$ERG
	test 0 -lt $anz && zustand="verbunden"
	istDialerGestartet || zustand="getrennt"
	test -e $VerbindungsWunschDatei && zustand="Waehlvorgang"
	ERG=$zustand
}


function holeNutzerStatus()	# Para: Nutzername
{
	local status="unbekannter Nutzer"
	istNutzerOK $1 && status="getrennt"
	istNutzerAktiv $1 && status="verbunden"
	istNutzerBeiEinwahl $1 && status="bei der Einwahl"
	ERG=$status
}


function holeIPdesNutzers()	# Para: Nutzername
{
	local aNutzer="`cat $NutzerListenDatei`"
	local ip="unbekannt"
	local nutzer
	local tName
	local tIP
	for nutzer in $aNutzer; do
		if test -z "$tName"; then
			tName="`echo $nutzer|cut -f 1`"
		  else
			tIP="`echo $nutzer|cut -f 1`"
			test "$1" = "$tName" && ip=$tIP
			tName=
		  fi
	  done
	ERG=$ip
	test "$ip" != "unbekannt"
}


function holeNutzerDerIP()	# Para: IP
{
	local a5Nutzer="`cat $NutzerListenDatei`"
	local name="unbekannt"
	local nutzer
	local tName
	local tIP
	for nutzer in $a5Nutzer; do
		if test -z "$tName"; then
			tName="`echo $nutzer|cut -f 1`"
		  else
			tIP="`echo $nutzer|cut -f 1`"
			test "$1" = "$tIP" && name=$tName
			tName=
		  fi
	  done
	ERG=$name
}


function istNutzerAktiv()	# Para: Nutzername
{
	local gefunden=nein
	holeAktiveNutzer
	local a2Nutzer="$ERG"
	local nutzer
	for nutzer in $a2Nutzer; do
		test "$nutzer" = "$1" && gefunden=ja
	  done
	test "$gefunden" = "ja"
}


function istNutzerOK()	# Para: Nutzername
{
	local a3Nutzer="`cat $NutzerListenDatei|cut -f 1`"
	local gefunden="nein"
	local name
	for name in $a3Nutzer; do
	    test "$name" = "$1" && gefunden="ja"
	  done
	test "$gefunden" = "ja"
}


function istNutzerBeiEinwahl()	# Para: Nutzername
{
	local gefunden=nein
	if test -e "$VerbindungsWunschDatei"; then
		local nutzer
		for nutzer in `cat $VerbindungsWunschDatei`; do
			test "$nutzer" = "$1" && gefunden=ja
		  done
	  fi
	test "$gefunden" = "ja"
}


function meldeVerbindungsWunschAn()	# Para: Nutzername
{
	echo $1 >>$VerbindungsWunschDatei
	AdminNachricht "$1 meldet Verbindungswunsch an"
}


function holeAnzahlVerbindungsWuensche()
{
	local anz=0
	test -s "$VerbindungsWunschDatei" && anz=`cat $VerbindungsWunschDatei|wc -l`
	 # "test -s" -> pruefe ob Datei groesser Null ist
	test $anz -le 0 && AdminFehler "hAVW: ungueltige Anzahl von Verbindungswuenschen ($anz)!"
	test -s "$VerbindungsWunschDatei" || AdminFehler "hAVW: fehlende (oder leere) Verbindungswunschdatei!"
	ERG=$anz

}


function erfuelleVerbindungsWuensche()
{
	if test -f "$VerbindungsWunschDatei"; then
		local wuensche="`cat $VerbindungsWunschDatei`"
		NutzerVerbindungenHergestellt "$wuensche"
		rm "$VerbindungsWunschDatei"
	  else
		AdminFehler "keine Verbindungswuensche vorhanden!"
	  fi
}


function entferneNutzerAusWunschDatei()		# Para: Nutzername
{
	local alle="`cat $VerbindungsWunschDatei`"
	rm $VerbindungsWunschDatei
	local einer
	for einer in $alle; do
		test "$einer" != "$1" && echo $einer >>$VerbindungsWunschDatei
	  done
	test -e "$VerbindungsWunschDatei" || beendeDialer && AdminNachricht "Nutzer $1 trennt vor Verbindungsaufbau"
}


function trenneNutzer()  # Para: Nutzername
{
	if istNutzerBeiEinwahl $1; then
		entferneNutzerAusWunschDatei $1
		if istNutzerBeiEinwahl $1; then
			AdminFehler "Nutzer konnte nicht aus Wunschdatei entfernt werden: $1"
			test -z "X"
		  else	AdminNachricht "Nutzer widerruft Verbindungswunsch: $1"
			test -n "X"
		  fi
	  elif istNutzerAktiv $1; then
		aktualisiereAlleSitzungen
		loescheSitzungsDatei $1
		aktualisiereWeiterleitungen
		istNutzerAktiv $1 || AdminNachricht "$1 trennt die Verbindung"
		holeAnzahlNutzer
		test $ERG -eq 0 && beendeDialer && AdminNachricht "keine weiteren Nutzer nach $1 - Trennung"
		if istNutzerAktiv $1; then
			test -z "X"
		  else	test -n "X"
		  fi
	  else
		AdminFehler "trenneNutzer: Nutzer $1 nicht verbunden"
		test -z "X"
	  fi
}


function trenneAlleVerbindungen()
{
	local nutzer
	holeAktiveNutzer
	local a4Nutzer=$ERG
	if test -n "$a4Nutzer"; then
		aktualisiereAlleSitzungen
		for nutzer in "$a4Nutzer"; do
			loescheSitzungsDatei $nutzer
		  done
	  fi
	verbieteAlleWeiterleitungen
	holeAnzahlNutzer
	local anz=$ERG
	holeAktiveNutzer
	local namen=$ERG
	test $anz -gt 0 && AdminFehler "Verbindungstrennung: offene Verbindungen entdeckt ($namen)"
	holeAnzahlNutzer
	test $ERG -eq 0
}


############### Kostenermittlung ######################

function ermittleKosten()	# Para: Nutzer, von, bis (jeweils in Form von "20041231")
{
	local datumKosten
	test -e $NutzerLogPrefix$1 && datumKosten=`cat $NutzerLogPrefix$1 | cut -f 2,5`
	if test -n "$datumKosten"; then
		local t
		local was="datum"
		local gesamt=0
		local neuGesamt
		local datum
		local preis
		for t in $datumKosten; do
			if test "$was" = "datum"; then
				datum=$t
				was="preis"
			  else
				preis=$t
				test "$datum" -ge "$2" -a "$datum" -le "$3" && let neuGesamt=gesamt+preis
				gesamt=$neuGesamt
				was="datum"
			  fi
		  done
		let ERG=gesamt/100
		# Ergebnis in Cent
	  else
		ERG=0;
	  fi
}


############### Weiterleitungskontrolle ###############

function aktualisiereWeiterleitungen()
{
	holeAktiveNutzer
	local alle=$ERG
	local n
	$IPTABLES -F FORWARD	# die Forward-Regeln loeschen
	if test -n "$alle"; then
		for n in $alle; do
			holeIPdesNutzers $n && $IPTABLES -A FORWARD -i $OUTDEV -o eth0 -d $ERG -m state --state ESTABLISHED,RELATED -j ACCEPT && $IPTABLES -A FORWARD -i eth0 -o $OUTDEV -s $ERG -j ACCEPT
		  done
	  fi
}


function erlaubeAlleWeiterleitungen()
{
	$IPTABLES -A FORWARD -i $OUTDEV -o eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
	$IPTABLES -A FORWARD -i eth0 -o $OUTDEV -j ACCEPT
}


function verbieteAlleWeiterleitungen()
{
	$IPTABLES -F FORWARD
}


function entschaerfeProvider()
{
	$IPTABLES -A OUTPUT -o $OUTDEV --protocol tcp --dport 80 -j ACCEPT
	$IPTABLES -A INPUT -i $OUTDEV --protocol tcp --sport 80 -m state --state ESTABLISHED,RELATED -j ACCEPT
	$WGET
	sleep 2
	kill $!
	  # beende WGET, damit keine Firewall-Logs auftauchen
	$IPTABLES -D OUTPUT -o $OUTDEV --protocol tcp --dport 80 -j ACCEPT
	$IPTABLES -D INPUT -i $OUTDEV --protocol tcp --sport 80 -m state --state ESTABLISHED,RELATED -j ACCEPT
}

################## main ############################


pruefeWeitereInstanz	# sorgt dafuer, dass nur eine Instanz laeuft

aktiviereSkriptLog	# aktiviert die Log-Datei


set +u		# wegen "unbound"-Warnungen notwendig

case "$1" in
	verbinde ) # ein Nutzer moechte die Verbindung nutzen
		pruefeStatus
		if istNutzerOK $2; then 
			if verbindeNutzer $2; then
				echo "Verbindungsaufbau gestartet"
			  else	echo "Verbindungsaufbau fehlgeschlagen"
			  fi
		  else	AdminFehler "$2 - versuchte Anmeldung"
			echo "unzulaessiger Nutzer"
		  fi
		;;
	ip-up )	# der Dialer hat die Verbindung hergestellt
	        # wird von "if-up" aufgerufen
		pruefeStatus
		erfuelleVerbindungsWuensche
		entschaerfeProvider
		;;
	ip-down ) # Verbindung beendet (regulaer? / Wuensche zurueckziehen?)
		pruefeStatus
		holeAktiveNutzer
		dieANutzer=$ERG
		if test -n "$dieANutzer"; then
			AdminNachricht "Zeitueberschreitung der Verbindung fuer: $dieANutzer"
			trenneAlleVerbindungen
		  fi
		# der Dialer sollte sich gerade selbst beenden
		$EinwahlSkript einwahl-ist-beendet
		;;
	trenne ) # Nutzer moechte Verbindung fuer sich beenden
		pruefeStatus
		if istNutzerOK $2;then
			if trenneNutzer $2; then echo "Nutzer getrennt"
			  else echo "Trennung fehlerhaft"
			  fi
		  else	echo "unzulaessiger Nutzer"
		  fi
	        ;;
	status-verbindung ) # offen/waehlen/getrennt
		pruefeStatus
		holeVerbindungsStatus
		echo -e "$ERG"
		;;
	status-nutzer ) # Verbindungsstatus fuer einen Nutzer
		pruefeStatus
		istNutzerOK $2 || AdminFehler "s-n: unbekannter Nutzer: $2"
		holeNutzerStatus $2
		echo -e "$ERG"
		;;
	alle-nutzer ) # Namen der Nutzer
		pruefeStatus
		cat $NutzerListenDatei | cut -f 1
		;;
	alle-aktiven-nutzer ) # Namen aller aktiven Nutzer
		holeAktiveNutzer
		if test -z "$ERG";
			then	echo "kein aktiver Nutzer"
			else	echo $ERG
		  fi
		;;
	status ) # Gesamtuebersicht
		pruefeStatus
		holeVerbindungsStatus
		echo -e "Verbindungsstatus:\t$ERG"
		for n in `cat $NutzerListenDatei | cut -f 1`; do
			holeIPdesNutzers $n
			echo -en "$ERG\t\t"
			holeNutzerStatus $n
			echo -e "$ERG\t$n"
		  done
	        ;;
	kosten ) # Kosten fuer einen Nutzer in bestimmtem Zeitraum
		t=""
		istNutzerOK $2 || t1="kosten: ungueltiger Nutzer ($2)"
		test -n "$3" -a -n "$4" -a $3 -le $4 || t2="ungueltiger Datumsbereich ($3/$4)"
		test -z "$t1" && t=$t2;
		test -z "$t2" && t=$t1;
		test -n "$t1" -a -n "$t2" && t="$t1 / $t2";
		if test -z "$t"; then
			ermittleKosten $2 $3 $4
			echo $ERG
		  else
			AdminFehler $t
			echo $t
		  fi
	        ;;
	nutzer2ip ) #
		if istNutzerOK $2; then
			holeIPdesNutzers $2
			echo $ERG
		  else
			AdminFehler "n2i: unbekannter Nutzer: $2"
		  fi
		;;
	ip2nutzer ) # ermittle Nutzernamen fuer IP
		holeNutzerDerIP $2
		echo $ERG
		;;
	nutzer-log ) # zeigt das Verbindungsprotokoll des Nutzers
		if istNutzerOK $2; then
			if test -s $NutzerLogPrefix$2; then
				echo -e "Datum\tDatum (Comp)\tPreis je min\tAnzahl der Nutzer\tVerbindungskosten\tDauer (in Sek.)"
				cat $NutzerLogPrefix$2
			  else
				echo "keine Eintraege"
			  fi
		  else
			AdminFehler "n-l: unbekannter Nutzer: $2"
			echo "ungueltiger Nutzername"
		  fi
		;;
	protokoll ) # zeigt eine Log-Datei an
		datei=
		case $2 in
		  fehler )
			datei=$AdminFehlerLog
			prog="cat"
			;;
		  meldungen )
			datei=$AdminLog
			prog="tail -200"
			;;
		  script )
			datei=$ScriptLog
			prog="tail -300"
			;;
		  dialer )
			datei=$DialerLog
			prog="tail -70"
			;;
		  * )
			echo "ungueltige Auswahl der Protokoll-Datei"
			;;
		  esac
		if test -n "$datei"; then
			if test -s $datei; then
				$prog $datei
			  else
				echo "keine Eintraege"
			  fi
		  fi
		;;
	reset )
		trenneAlleVerbindungen
		# beenden geht leider nicht, wegen PID
		if test -e $DialPIDDatei; then
			ERG1=`cat $DialPIDDatei`
			ERG2=`ps --pid $ERG1 -o comm | tail -1`
			ERG3=`echo $0 | grep $ERG2`
			test -n "$ERG3" && kill $ERG1
			# beim Beenden sollte die PID-Datei geloescht werden, aber:
			test -e "$DialPIDDatei" && rm $DialPIDDatei
		  fi
		test -n "`ls $SitzungsPrefix`" && rm $SitzungsPrefix*
		test -e $DialerStatus && rm $DialerStatus
		test -e $VerbindungsWunschDatei && rm $VerbindungsWunschDatei
		# unnoetig die PIDDatei zu loeschen, da trap dies tut
		verbieteAlleWeiterleitungen
		AdminNachricht "Reset ausgeloest"
		;;
	* ) # Hilfe
		echo -e "Parameter:"
		echo -e "\t verbinde X\t\t- oeffne Verbindung fuer X"
		echo -e "\t trenne X\t\t- trenne die Verbindung fuer X"
		echo -e "\t status\t\t\t- allgemeine Informationen"
		echo -e "\t status-verbindung\t- Ausgabe der Info"
		echo -e "\t status-nutzer X\t- Ausgabe der Info"
		echo -e "\t alle-nutzer\t\t- Ausgabe aller Nutzernamen"
		echo -e "\t alle-aktiven-nutzer\t- Ausgabe der derzeit verbundenen Nutzer"
		echo -e "\t ip2nutzer X\t\t- liefert den Nutzernamen fuer eine IP"
		echo -e "\t nutzer2ip X\t\t- liefert die IP des Nutzers"
		echo -e "\t kosten X Y Z\t\t- Kosten fuer X von Y bis Z (z.B.: 20041231)"
		echo -e "\t nutzer-log X\t\t- Verbindungsprotokoll des Nutzers X"
		echo -e "\t protokoll X\t\t- Log-Datei (fehler,meldungen,script,dialer)"
		;;
  esac



