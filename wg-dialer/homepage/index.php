<?PHP require_once("definitionen.php"); ?>

<HTML>
<HEAD>
	<HTTP-EQUIV="refresh" CONTENT="5; URL=http://io/index.php">
	<META HTTP-EQUIV="expires" content="0">
	<META HTTP-EQUIV="cache-control" content="no-cache">
	<TITLE>WG-Netzverwaltung</TITLE>
</HEAD>

<BODY>

<?PHP

error_reporting(E_ALL);

include("verbindungsStatus.php");
print "<HR>";

//include("nutzerStatus.php");
//print "<HR>";

include("aktiveNutzer.php");
print "<HR>";

include("aktionen.php");
print "<HR>";

zeigeStatusMeldung();

?>


</BODY>
</HTML>
