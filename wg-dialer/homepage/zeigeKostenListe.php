<?PHP // erfordert $von und $bis in Form von 20041231 ?>

<TABLE BORDER="1">
<TR><TH>wer?</TH><TH>wieviel?</TH></TR>

<?PHP

foreach ($ALLENUTZER as $nutzer)
{
	print '<TR><TD>' . $nutzer . '</TD><TD><DIV ALIGN="CENTER">';
	$erg = holeKostenDesNutzers($nutzer, $von, $bis);
	$cent = $erg % 100;
	if ($cent<10) $cent="0$cent"; 
	$euro = $erg/100;
	settype($euro,"integer");
	print  $euro . ',' . $cent;
	print "</DIV></TD></TR>";
}

?>

</TABLE>
