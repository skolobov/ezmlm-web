<BR>
<DIV ALIGN="CENTER">


<?PHP
$nutzer=holeNutzerDerIP($IP);
$status=holeNutzerStatus($nutzer);
$prefixFett='<H1><DIV ALIGN="CENTER">';
$suffixFett='</DIV></H1>';
$prefixNormal='<H2><DIV ALIGN="CENTER">';
$suffixNormal='</DIV></H2>';
$linkVerbindung='<A HREF="verbindeNutzer.php">verbinden</A>';
$linkTrennung='<A HREF="trenneNutzer.php">trenne Verbindung</A>';

if ($status == "getrennt") 
{
	print $prefixFett . $linkVerbindung . $suffixFett;
	print $prefixNormal . $linkTrennung . $prefixNormal;
}	
elseif (($status == "bei der Einwahl") || ($status == "verbunden"))
{
	print $prefixNormal . $linkVerbindung . $suffixNormal;
	print $prefixFett . $linkTrennung . $prefixFett;
}	
else	print '<H2><DIV ALIGN="CENTER">Zugriff verweigert</DIV></H2>';

print "</TR><TABLE>";

?>

<HR><BR>

<TABLE BORDER="0">
<COLGROUP WIDTH="180" SPAN="4"></COLGROUP>
<TR>
<TD><DIV ALIGN="CENTER"><A HREF="zeigeKosten.php">Kostenaufstellung</A></DIV></TD>
<TD><DIV ALIGN="CENTER"><A HREF="zeigeProtokoll.php">Protokoll anzeigen</A></DIV></TD>
<TD><DIV ALIGN="CENTER"><A HREF="http://io.wg">io-Startseite</A></DIV></TD>
<TD><DIV ALIGN="CENTER"><A HREF="ausschalten.php">io abschalten</A></DIV></TD>
</TR>
</TABLE>
</DIV>
<BR>
