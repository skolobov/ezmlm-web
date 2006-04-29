<div class="title">
	<h1><?cs var:html_escape(Lang.Title.GnupgSecret) ?></h1>
</div>

<div class="introduction">
	<p><?cs var:html_escape(Lang.Introduction.GnupgSecret) ?></p>
</div>

<?cs include:TemplateDir + '/gnupg_import.cs' ?>

<fieldset class="form">
	<legend><?cs var:html_escape(Lang.Legend.GnupgSecretKeys) ?> </legend>

	<?cs if:subcount(Data.List.gnupg_keys.secret) > 0 ?>

		<form method="post" action="<?cs call:link("","","","","","") ?>"
			enctype="application/x-www-form-urlencoded">
		<input type="hidden" name="gnupg_subset" value="secret" />

		<table class="gnupg_keys">
			<?cs each:key = Data.List.gnupg_keys.secret
				?><tr><td><input type="checkbox" name="gnupg_key_<?cs var:key.id ?>"
					id="gnupg_key_<?cs var:key.id ?>" /></td>
					<td><label for="gnupg_key_<?cs var:key.id ?>"><?cs
						var:html_escape(key.name) ?></label></td>
					<td><label for="gnupg_key_<?cs var:key.id ?>"><?cs
						var:html_escape(key.email) ?></label></td>
					<td><label for="gnupg_key_<?cs var:key.id ?>"><?cs
						var:html_escape(key.expires) ?></label></td>
					<td><a href="<?cs call:link("action", "gnupg_export",
									"list", Data.List.Name,
									"gnupg_keyid", key.id) ?>"
							title="<?cs var:html_escape(Lang.Buttons.GnupgExportKey)
								?>"><?cs var:html_escape(Lang.Buttons.GnupgExportKey)
								?></a></td>
					</tr>
			<?cs /each ?>
		</table>

		<!-- include default form values -->
		<?cs include:TemplateDir + '/form_common.cs' ?>

		<input type="hidden" name="action" value="gnupg_do" />
		<button type="submit" name="send" value="do"><?cs var:html_escape(Lang.Buttons.DeleteSecretKey) ?></button>

	</form>
	<?cs else ?>
		<p><?cs var:html_escape(Lang.Misc.GnupgNoSecretKeys) ?></p>
	<?cs /if ?>

</fieldset>