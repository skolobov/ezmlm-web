<BR>

<DIV ALIGN="CENTER">

<TABLE BORDER="0">

<TR><TH>Name</TH>
    <TH>IP</TH>
    <TH>Status</TH></TR>

<?PHP

foreach($ALLENUTZER as $nutzer)
{
	$ip=holeIPdesNutzers($nutzer);
	$status=holeNutzerStatus($nutzer);
	print "<TR><TD>$nutzer</TD>";
	print "<TD>$ip</TD>";
	print "<TD>$status</TD></TR>";
}

?>

</TABLE>

</DIV>
<BR>
