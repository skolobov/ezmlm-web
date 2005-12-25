<div class="title">
	<h1><?cs var:html_escape(Lang.Title.ConfigAdmin) ?></h1>
</div>

<div class="introduction">
	<p><?cs var:html_escape(Lang.Introduction.ConfigAdmin) ?></p>
</div>

<fieldset class="form">
	<legend><?cs var:html_escape(Lang.Legend.ConfigAdmin) ?> </legend>

	<form method="post" action="<?cs var:ScriptName ?>" enctype="application/x-www-form-urlencoded">
		<input type="hidden" name="config_subset" value="admin" />

		<ul>

			<li><?cs call:checkbox("r") ?></li>
			<li><?cs call:checkbox("l") ?></li>
			<li><?cs call:checkbox("n") ?></li>
			<li><?cs call:setting("8") ?></li>
		
			<li><!-- include default form values -->
			<?cs include:TemplateDir + '/form_common.cs' ?>

			<input type="hidden" name="action" value="config_do" />
			<button type="submit" name="send" value="do"><?cs var:html_escape(Lang.Buttons.UpdateConfiguration) ?></button></li>
		</ul>

	</form>
</fieldset>
