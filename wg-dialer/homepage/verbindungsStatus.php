<?PHP

print '<BR><H1><DIV ALIGN="CENTER">';
print '<A HREF="index.php">';
print 'Status aktualisieren: ';
print '</A>';
print holeVerbindungsStatus();
print '</DIV></H1>';
print '<DIV ALIGN="CENTER">';
$tarif=holeTarif();
print "Aktueller Tarif: $tarif";
print '<BR>';
print '<TT>Vorsicht:</TT><BR>achte unbedingt darauf, dass der angezeigte Tarif <BR>';
print 'zum heutigen Wochentag passt - ansonsten klicke ';
print '<A HREF="tarifWechsel.php">hier</A> um den anderen Tarif zu aktivieren!<BR>';

print '</DIV>';


?>
