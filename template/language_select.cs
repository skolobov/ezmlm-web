<!-- allows the user to change the interface language (not of the list!) -->
<?cs if:subcount(Config.UI.Languages) > 0 ?>

	<?cs call:form_header("select_language") ?>

		<?cs if:Data.List.Name ?><input type="hidden" name="action"
				value="subscribers" /><?cs /if ?>

		<font class="no_link"><?cs
			var:html_escape(Lang.Menue.Language) ?>:</font><br/>
		<select name="web_lang" size="0">
			<?cs each: tlang = Config.UI.Languages
				?><option value="<?cs var:name(tlang) ?>"<?cs
					if:name(tlang) == Config.UI.LinkAttrs.web_lang
					?> selected="selected"<?cs /if?>><?cs
				var:html_escape(tlang) ?></option>
				<?cs /each ?>
		</select>&nbsp;<button type="submit" name="send" value="do"><?cs var:html_escape(Lang.Buttons.LanguageSet) ?></button>
	</form>

<?cs /if ?>