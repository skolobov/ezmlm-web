<?PHP

require_once("definitionen.php");

$nutzer=holeNutzerDerIP($IP);

if (holeNutzerStatus($nutzer) == "getrennt")
	StatusMeldung(verbindeNutzer($nutzer));
  else	StatusMeldung("Nutzer $nutzer bereits verbunden!");

include("index.php");

?>
