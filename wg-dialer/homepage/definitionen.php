<?PHP

error_reporting(E_ALL);
session_cache_limiter("no-cache");

$DialSkript="sudo -u wgdialer /home/WGDialer/scripts/WGDialer.sh";
$TarifWahl="sudo -u root /home/WGDialer/scripts/waehleISDN-Tarif.sh";
$IP=$HTTP_SERVER_VARS["REMOTE_ADDR"];
$NUTZER=holeNutzerDerIP($IP);

exec("$DialSkript alle-nutzer",$ALLENUTZER);


function StatusMeldung($text)
{
	global $StatusText;
	$StatusText=$text;
}


function zeigeStatusMeldung()
{
	global $StatusText;
	if (isset($StatusText))
	{
		print '<H3><DIV ALIGN="CENTER">Statusmeldung: ';
		print $StatusText;
		print '</DIV></H3>';
		unset($StatusText);
	}
}


function holeIPdesNutzers($name)
{
	global $DialSkript;
	return exec("$DialSkript nutzer2ip $name");
}


function holeNutzerDerIP($ip)
{
	global $DialSkript;
	return exec("$DialSkript ip2nutzer $ip");
}


function holeAktiveNutzer()
{
	global $DialSkript;
	return exec("$DialSkript alle-aktiven-nutzer");
}


function holeVerbindungsStatus()
{
	global $DialSkript;
	return exec("$DialSkript status-verbindung");
}


function holeNutzerStatus($nutzer)
{
	global $DialSkript;
	return exec("$DialSkript status-nutzer $nutzer");
}


function verbindeNutzer($nutzer)
{
	global $DialSkript;
	return exec("$DialSkript verbinde $nutzer");
}


function trenneNutzer($nutzer)
{
	global $DialSkript;
	return exec("$DialSkript trenne $nutzer");
}


function notTrennung()
{
	global $DialSkript;
	return exec("$DialSkript not-aus");
}


function holeKostenDesNutzers($nutzer, $von, $bis)
{
	global $DialSkript;
	return exec("$DialSkript kosten $nutzer $von $bis");
}


function zeigeNutzerLog($nutzer)
{
	global $DialSkript;
	exec("$DialSkript nutzer-log $nutzer | cut -f 1,3-6 --output-delimiter=\"</TD><TD>\"",$out);
	if (count($out) > 1)
	{
		$kopf = str_replace("</TD><TD>","</TH><TH>",array_shift($out));
		$gesamt='<DIV ALIGN="CENTER"><TABLE BORDER="1"><TR><TH>' . $kopf . '</TH></TR>';
		foreach ($out as $z)
			$gesamt.='<TR><TD>' . $z . '</TD></TR>'; 
		$gesamt.='</TABLE></DIV>';
	} else $gesamt='<BR><DIV ALIGN="CENTER">keine Eintr&auml;ge</DIV>';
	return $gesamt;
}


function zeigeProtokoll($protokoll) // meldungen, fehler, dialer, script
{
	global $DialSkript;
	exec("$DialSkript protokoll $protokoll",$out);
	$gesamt="";
	foreach ($out as $z)
		$gesamt=$gesamt . $z . '<BR>';
	if (count($out)<=1) $gesamt='<BR><DIV ALIGN="CENTER">keine Eintr&auml;ge</DIV>';
	return $gesamt;
}


function holeTarif()
{
	global $TarifWahl;
	return exec("$TarifWahl tarif");
}


function setzeTarif($tarif)
{
	global $TarifWahl;
	exec("$TarifWahl $tarif");
}


function io_ausschalten()
{
	exec("/sbin/shutdown -h now");
}

?>
