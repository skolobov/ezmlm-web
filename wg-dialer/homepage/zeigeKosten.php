<?PHP require_once("definitionen.php"); ?>

<HTML>
<HEAD>
	<TITLE>Kosten&uuml;bersicht</TITLE>
</HEAD>

<BODY>

<BR><H2><DIV ALIGN="CENTER"><A HREF="index.php">zur&uuml;ck zur Startseite</A></DIV></H2><BR>
<HR><BR>
<DIV ALIGN="CENTER">

<?PHP

include("zeigeKostenFormular.php");
if (isset($HTTP_POST_VARS["Anzeige"]))
{
	$von=$HTTP_POST_VARS["vJahr"]*10000+$HTTP_POST_VARS["vMonat"]*100+$HTTP_POST_VARS["vTag"];
	$bis=$HTTP_POST_VARS["bJahr"]*10000+$HTTP_POST_VARS["bMonat"]*100+$HTTP_POST_VARS["bTag"];
	print '<BR><HR><BR>';
	include("zeigeKostenListe.php");
}

?>

</DIV>


</BODY>
</HTML>