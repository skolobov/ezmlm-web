<?PHP

require_once("definitionen.php");

$tarif=holeTarif();

if (substr_count($tarif,"XXL") > 0)
	setzeTarif("normal");
  else	setzeTarif("xxl");

include("index.php");

?>
