<div class="title">
	<h1><?cs var:Lang.Title.ConfigSub ?></h1>
</div>

<div class="introduction">
	<p><?cs var:Lang.Introduction.ConfigSub ?></p>
</div>

<fieldset class="form">
	<legend><?cs var:Lang.Legend.ConfigSub ?></legend>

	<form method="post" action="<?cs var:ScriptName ?>" enctype="application/x-www-form-urlencoded">
		<input type="hidden" name="config_subset" value="subscription" />

		<ul>

			<li><?cs call:checkbox("p") ?></li>
			<li><?cs call:checkbox("h") ?></li>
			<li><?cs call:checkbox("j") ?></li>
			<li><?cs call:checkbox("s") ?></li>
			<li><?cs call:setting("8") ?></li>

			<!-- include default form values -->
			<?cs include:TemplateDir + '/form_common.cs' ?>

			<button type="submit" name="action" value="config_do"><?cs var:Lang.Buttons.UpdateConfiguration ?></button>
		</ul>

	</form>

</fieldset>
