#!/bin/sh

warteZeit=200
nutzer=`ls /home/WGDialer/data/nutzer`
alteDatei=/home/WGDialer/data/letzterVerkehr
neueDatei=/home/WGDialer/data/aktuellerVerkehr
holeName="/home/WGDialer/scripts/WGDialer.sh ip2nutzer "
trenneVerbindung="/home/WGDialer/scripts/WGDialer.sh trenne "
logDatei=/home/WGDialer/data/verkehr.log


exec >>$logDatei
exec 2>>$logDatei
echo -e "\n`date` - Ueberwachung wurde gestartet ..." >>$logDatei

while true
do 
iptables --numeric -vL FORWARD | grep "\-\-" >$neueDatei
nutzerWahl=`cat $neueDatei | cut -c 69-87 | grep 192`

test -n "$nutzerWahl" -a -s "$alteDatei" && for n in "$nutzerWahl" 
	do	alt=`cat $alteDatei | grep $n`
		neu=`cat $neueDatei | grep $n`
		if test -n "$alt" -a "$alt" = "$neu";
			then	name=`$holeName $n`
				$trenneVerbindung $name
				echo "`date` - Nutzer $name wurde abgemeldet wegen Untaetigkeit" >> $logDatei 
		  fi
	done

iptables --numeric -vL FORWARD | grep "\-\-" >$alteDatei
rm $neueDatei
sleep $warteZeit
done
