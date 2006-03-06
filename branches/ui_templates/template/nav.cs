<!-- $Id$ -->

<div id="nav_bar">
<ul>
	<?cs if:(subcount(Data.Lists) > 0)  && (UI.Navigation.ListSelect == 1) ?>
		<li><a <?cs if:(Data.Action == "list_select") ?> class="nav_active"<?cs /if ?>
			href="<?cs var:ScriptName ?>?action=list_select"
			title="<?cs var:html_escape(Lang.Menue.ListSelect) ?>"><?cs var:html_escape(Lang.Menue.ListSelect) ?></a>
		</li>
		<?cs /if ?>
	<?cs if:Data.Permissions.Create  && (UI.Navigation.ListCreate == 1) ?>
		<li><a <?cs if:(Data.Action == "list_create") ?> class="nav_active"<?cs /if ?>
			href="<?cs var:ScriptName ?>?action=list_create_ask"
			title="<?cs var:html_escape(Lang.Menue.ListCreate) ?>"><?cs var:html_escape(Lang.Menue.ListCreate) ?></a>
		</li>
		<?cs /if ?>


<?cs if:Data.List.Name ?>

	<li><font class="no_link"><?cs var:html_escape(Lang.Menue.Properties) ?> <?cs call:limit_string_len(html_escape(Data.List.Name),25) ?></font><ul><li>
		<?cs if:UI.Navigation.Subscribers.Subscribers == 1
				?><a <?cs if:((Data.Action == "subscribers")
						&& ((Data.List.PartType == "") || !Data.List.PartType))
					?>class="nav_active"<?cs /if ?>
			href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
				?>&amp;action=subscribers" title="<?cs
				var:html_escape(Lang.Menue.Subscribers) ?>"><?cs
			else ?><font class="no_link"><?cs /if ?><?cs
				var:html_escape(Lang.Menue.Subscribers) ?><?cs
			if:UI.Navigation.Subscribers.Subscribers == 1 ?></a><?cs else ?></font><?cs
				/if ?>
			<ul>
				<?cs if:UI.Navigation.Subscribers.Allow == 1
					?><li><a <?cs if:((Data.Action == "subscribers") &&
						(Data.List.PartType == "allow")) ?>class="nav_active"<?cs /if ?>
					href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
						?>&amp;action=subscribers&amp;part=allow"><?cs
						var:html_escape(Lang.Menue.AllowList) ?></a></li><?cs /if ?>
				<?cs if:UI.Navigation.Subscribers.Deny == 1
					?><li><a <?cs if:((Data.Action == "subscribers") &&
						(Data.List.PartType == "deny")) ?> class="nav_active"<?cs /if ?>
					href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
						?>&amp;action=subscribers&amp;part=deny"><?cs
						var:html_escape(Lang.Menue.DenyList) ?></a></li><?cs /if ?>
				<?cs if:UI.Navigation.Subscribers.Digest == 1
					?><li><a <?cs if:((Data.Action == "subscribers") &&
						(Data.List.PartType == "digest")) ?> class="nav_active"<?cs /if ?>
					href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
						?>&amp;action=subscribers&amp;part=digest"><?cs
						var:html_escape(Lang.Menue.DigestList) ?></a></li><?cs /if ?>
				<?cs if:UI.Navigation.Subscribers.Moderators == 1
					?><li><a <?cs if:((Data.Action == "subscribers") &&
						(Data.List.PartType == "mod")) ?> class="nav_active"<?cs /if ?>
					href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
						?>&amp;action=subscribers&amp;part=mod"><?cs
						var:html_escape(Lang.Menue.ModList) ?></a></li><?cs /if ?>
			</ul>
		</li>

		<li><?cs if:UI.Navigation.Config.Main == 1
			?><a <?cs if:(Data.Action == "config_main") ?> class="nav_active"<?cs /if ?>
				href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
				?>&amp;action=config_ask&amp;config_subset=main" title="<?cs
				var:html_escape(Lang.Menue.ConfigMain) ?>"><?cs
			else ?><font class="no_link"><?cs /if ?><?cs
			var:html_escape(Lang.Menue.ConfigMain) ?><?cs
				if UI.Navigation.Config.Main == 1 ?></a><?cs else ?></font><?cs /if ?>
		<ul>
			<?cs if:UI.Navigation.Config.Subscription == 1
				?><li><a <?cs if:(Data.Action == "config_subscription")
					?> class="nav_active"<?cs /if ?>
				href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
					?>&amp;action=config_ask&amp;config_subset=subscription"
					title="<?cs var:html_escape(Lang.Menue.ConfigSub) ?>"><?cs
					var:html_escape(Lang.Menue.ConfigSub) ?></a></li><?cs /if ?>
			<?cs if:UI.Navigation.Config.Posting == 1
				?><li><a <?cs if:(Data.Action == "config_posting")
					?> class="nav_active"<?cs /if ?>
				href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
					?>&amp;action=config_ask&amp;config_subset=posting"
					title="<?cs var:html_escape(Lang.Menue.ConfigPost) ?>"><?cs
					var:html_escape(Lang.Menue.ConfigPost) ?></a></li><?cs /if ?>
			<?cs if:UI.Navigation.Config.Processing == 1
				?><li><a <?cs if:(Data.Action == "config_processing")
					?> class="nav_active"<?cs /if ?>
				href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
					?>&amp;action=config_ask&amp;config_subset=processing"
					title="<?cs var:html_escape(Lang.Menue.ConfigProcess) ?>"><?cs
					var:html_escape(Lang.Menue.ConfigProcess) ?></a></li><?cs /if ?>
			<?cs if:UI.Navigation.Config.Archive == 1
				?><li><a <?cs if:(Data.Action == "config_archive") ?>
					class="nav_active"<?cs /if ?>
				href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
					?>&amp;action=config_ask&amp;config_subset=archive"
					title="<?cs var:html_escape(Lang.Menue.ConfigArchive) ?>"><?cs
					var:html_escape(Lang.Menue.ConfigArchive) ?></a></li><?cs /if ?>
			<?cs if:UI.Navigation.Config.Admin == 1
				?><li><a <?cs if:(Data.Action == "config_admin") ?>
					class="nav_active"<?cs /if ?>
				href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
					?>&amp;action=config_ask&amp;config_subset=admin"
					title="<?cs var:html_escape(Lang.Menue.ConfigAdmin) ?>"><?cs
					var:html_escape(Lang.Menue.ConfigAdmin) ?></a></li><?cs /if ?>
			<?cs if:UI.Navigation.Config.All == 1
				?><li><a <?cs if:(Data.Action == "config_all") ?>
					class="nav_active"<?cs /if ?>
				href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
					?>&amp;action=config_ask&amp;config_subset=all"
					title="<?cs var:html_escape(Lang.Menue.ConfigAll) ?>"><?cs
					var:html_escape(Lang.Menue.ConfigAll) ?></a></li><?cs /if ?>
		</ul></li>

		<?cs if:UI.Navigation.TextEdit == 1
			?><li><a <?cs if:((Data.Action == "textfiles")
					|| (Data.Action == "textfile_edit")) ?> class="nav_active"<?cs /if ?>
				href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
					?>&amp;action=textfiles" title="<?cs
					var:html_escape(Lang.Menue.TextFiles) ?>"><?cs
					var:html_escape(Lang.Menue.TextFiles) ?></a></li><?cs /if ?>

		<?cs if:UI.Navigation.ListDelete == 1
			?><li><a <?cs if:(Data.Action == "list_delete") ?> class="nav_active"<?cs /if ?>
			href="<?cs var:ScriptName ?>?list=<?cs var:url_escape(Data.List.Name)
				?>&amp;action=list_delete_ask" title="<?cs
				var:html_escape(Lang.Menue.ListDelete) ?>"><?cs
				var:html_escape(Lang.Menue.ListDelete) ?></a></li><?cs /if ?>
		
	</ul></li>

<?cs /if ?>

	<?cs if:UI.Navigation.Help
		?><li><a href="http://www.ezmlm.org/ezman/index.html#toc1" target="_blank"
		title="<?cs var:html_escape(Lang.Misc.HelpLink) ?>"><?cs
		var:html_escape(Lang.Menue.Help) ?></a></li><?cs /if ?>

</ul>

<!-- end of navbar div -->
</div>
