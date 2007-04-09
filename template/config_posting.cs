<div class="title">
	<h1><?cs var:html_escape(Lang.Title.ConfigPosting) ?></h1>
</div>

<div class="introduction">
	<p><?cs var:html_escape(Lang.Introduction.ConfigPosting) ?></p>
</div>

<fieldset>
	<legend><?cs var:html_escape(Lang.Legend.ConfigPosting) ?> </legend>

	<?cs call:form_header("config_posting", "") ?>
		<input type="hidden" name="config_subset" value="posting" />

		<?cs call:show_options(UI.Options.Config.Posting) ?>

		<input type="hidden" name="action" value="config_do" />
		<button type="submit" name="send" value="do"><?cs var:html_escape(Lang.Buttons.UpdateConfiguration) ?></button>

	</form>

</fieldset>

