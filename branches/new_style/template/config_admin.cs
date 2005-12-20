<div id="config" class="container">

    <div class="title">
		<h1><?cs var:Lang.Title.ConfigAdmin ?></h1>
    </div>

  <form method="post" action="<?cs var:ScriptName ?>" enctype="application/x-www-form-urlencoded">
    <input type="hidden" name="config_subset" value="admin" />

    <div class="input"><ul>

		<li><?cs call:checkbox("r") ?></li>
		<li><?cs call:checkbox("l") ?></li>
		<li><?cs call:checkbox("n") ?></li>
		<li><?cs call:setting("8") ?></li>
	
		<!-- include default form values -->
		<?cs include:TemplateDir + '/form_common.cs' ?>

	<button type="submit" name="action" value="config_do"><?cs var:Lang.Buttons.UpdateConfiguration ?></button>
	</ul></div>

  </form>

</div>
