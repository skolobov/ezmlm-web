<div class="title">
	<h1><?cs var:html_escape(Lang.Title.ConfigProcess) ?></h1>
</div>

<div class="introduction">
	<p><?cs var:html_escape(Lang.Introduction.ConfigProcess) ?></p>
</div>

<fieldset class="form">
	<legend><?cs var:html_escape(Lang.Legend.ConfigProcess) ?> </legend>

	<form method="post" action="<?cs var:ScriptName ?>" enctype="application/x-www-form-urlencoded">
		<input type="hidden" name="config_subset" value="processing" />

		<?cs call:show_options(UI.Options.Config.Processing) ?>

		<!-- include default form values -->
		<?cs include:TemplateDir + '/form_common.cs' ?>

		<input type="hidden" name="action" value="config_do" />
		<button type="submit" name="send" value="do"><?cs var:html_escape(Lang.Buttons.UpdateConfiguration) ?></button>

	</form>
</fieldset>

<?cs include:TemplateDir + '/help_tag_susbtitution.cs' ?>
