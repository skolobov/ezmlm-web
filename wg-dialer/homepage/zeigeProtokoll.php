<?PHP require_once("definitionen.php"); ?>

<HTML>
<HEAD>
	<TITLE>WG-Netzverwaltung - Protokolle</TITLE>
	<META HTTP-EQUIV="expires" content="0">
	<META HTTP-EQUIV="cache-control" content="no-cache">
</HEAD>

<BODY>

<BR><H2><DIV ALIGN="CENTER"><A HREF="index.php">zur&uuml;ck zur Startseite</A></DIV></H2><BR>
<HR><BR>
<DIV ALIGN="CENTER">
<TABLE BORDER="0"><COLGROUP WIDTH="15%" SPAN="5"></COLGROUP>

<TR><TD><DIV ALIGN="CENTER"><A HREF="<?PHP print $PHP_SELF; ?>?prot=nutzer">pers&ouml;nlich</A></DIV></TD>
<TD><DIV ALIGN="CENTER"><A HREF="<?PHP print $PHP_SELF; ?>?prot=meldungen">Meldungen</A></DIV></TD>
<TD><DIV ALIGN="CENTER"><A HREF="<?PHP print $PHP_SELF; ?>?prot=fehler">Fehler</A></DIV></TD>
<TD><DIV ALIGN="CENTER"><A HREF="<?PHP print $PHP_SELF; ?>?prot=dialer">Einwahlprogramm</A></DIV></TD>
<TD><DIV ALIGN="CENTER"><A HREF="<?PHP print $PHP_SELF; ?>?prot=script">Programmausgabe</A></DIV></TD></TR>

</TABLE>
</DIV>

<?PHP

if (isset($HTTP_GET_VARS["prot"]))
{
	$prot=$HTTP_GET_VARS["prot"];
	print '<BR><HR><BR>';
	if ($prot=="nutzer") print zeigeNutzerLog($NUTZER);
	  else print zeigeProtokoll($prot);
}

?>

</BODY>
</HTML>



