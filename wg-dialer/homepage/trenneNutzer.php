<?PHP

require_once("definitionen.php");

$nutzer=holeNutzerDerIP($IP);

if (holeNutzerStatus($nutzer) != "getrennt")
	StatusMeldung(trenneNutzer($nutzer));
  else	StatusMeldung("Nutzer $nutzer war nicht verbunden!");

include("index.php");

?>
