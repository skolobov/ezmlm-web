<!-- $opts -->
<p>
<!-- TODO: das sollte so etwas, wie eine Tabelle werden -->
	<?cs each:item = Data.ListOptions ?>
	    <span class="checkbox"><input type="checkbox" name="<?cs var:item.name ?>"
	      value="<?cs var:item.name ?>" label="<?cs var:item.label ?>"
	      on="<?cs var:item.state ?>"><?cs call:options_help(item.name) ?></span>
	<?cs /each ?>
</p>

<p>
	<?cs each:item = Data.ListSettings ?>
	    <span class="checkbox"><input type="checkbox" name="<?cs var:item.name ?>"
	      value="<?cs var:item.name ?>" label="<?cs var:item.label ?>"
	      on="<?cs var:item.state ?>"><?cs call:settings_help(item.name) ?>
	      <span class="formfield"><input type="textfield" name="<?cs var:item.name ?>-value"
	      value="<?cs var:item.value ?>" size="30"></span>
	      <!-- TODO: die indirekte Namensangabe des textfield is unsauber - sollte nicht
	        mit dem Code vermischt sein -->
	<?cs /each ?>
</p>
