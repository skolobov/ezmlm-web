<div id="edit" class="container">

    <div class="title">

        <h2><?cs var:Lang.Misc.SubscribersTo ?> <i><?cs var:Data.ListName ?></i></h2>
        <h3><?cs var:Data.ListAddress ?></h3>
	<hr>
    </div>

    <div class="list">
	<form method="post" action="<?cs var:ScriptURL ?>" enctype="application/x-www-form-urlencoded">
	    <input type="submit" name="state" value="edit">
	    <input type="hidden" name="list" value="<?cs var:Data.ListName ?>">

	    <!-- scrollbox for list's subscribers -->
	    <!-- Keep selection box a reasonable size - suggested by Sebastian Andersson -->
	    <?cs if:(Data.SubscribersCount > 25) ?>
		<?cs set:Data.ScrollSize = 25 ?>
	      <?cs else ?>
		<?cs set:Data.ScrollSize = Data.SubscribersCount ?>
	    <?cs /if ?>
	    <select name="delsubscriber" tabindex="1" size="<?cs var:Data.ScrollSize ?>" multiple="yes">
		<?cs each:item = Data.Subscribers ?>
		    <option><?cs var:item ?></option>
		<?cs /each ?>
	    </select>
	
	    <div class="add_remove">
		<?cs if:(Data.SubscribersCount > 0) ?> 
		    <p><?cs var:Data.SubscribersCount ?> <?cs var:Lang.Misc.Subscribers ?></p>
		    <span class="button"><input type="submit" name="action" tabindex="2"
			value="<?cs var:Lang.Buttons.DeleteAddress ?>"></span>
		<?cs /if ?>
		<span class="formfield"><input type="text" name="addsubscriber"
			tabindex="3" size="40"/><?cs call:help_icon("AddAddress") ?></span>
		<!-- TODO: eventuell ein BR einfuegen -->
		<span class="formfield"><input type="file" name="addfile" size="20"
			maxlength="100" tabindex="4"/><?cs call:help_icon("AddAddressFile") ?></span>
		<span class="button"><input type="submit" tabindex="5" name="action"
		      value="<?cs var:Lang.Buttons.AddAddress ?>"/></span>
	    </div>
	    <div class="options">
		<?cs if:(Data.ConfigAvail.Extras == 1) ?>
		<!-- at least one extra config option is available -->
		    <h3><?cs Lang.Misc.AdditionalParts ?>:</h3>
		<?cs /if ?>
		<p>
		<?cs if:(Data.ConfigAvail.Moderation == 1) ?>
		<!-- moderation -->
		    <span class="button"><input type="submit" tabindex="6" name="action"
			value="<?cs var:Lang.Buttons.Moderators ?>"/>
		    <?cs call:help_icon("Moderator") ?></span>
		<?cs /if ?>

		<?cs if:(Data.ConfigAvail.DenyList == 1) ?>
		<!-- deny lists -->
		    <span class="button"><input type="submit" tabindex="7" name="action"
			value="<?cs var:Lang.Buttons.DenyList ?>"/>
		    <?cs call:help_icon("Deny") ?></span>
		<?cs /if ?>

		<?cs if:(Data.ConfigAvail.AllowList == 1) ?>
		<!-- allow lists -->
		    <span class="button"><input type="submit" tabindex="8" name="action"
			value="<?cs var:Lang.Buttons.AllowList ?>"/>
		    <?cs call:help_icon("Allow") ?></span>
		<?cs /if ?>

		<?cs if:(Data.ConfigAvail.Digest == 1) ?>
		<!-- digest subscribers -->
		    <span class="button"><input type="submit" tabindex="9" name="action"
			value="<?cs var:Lang.Buttons.DigestSubscribers ?>"/>
		    <?cs call:help_icon("Digest") ?></span>
		<?cs /if ?>
		</p>

		<p>
		<!-- web archive -->
		<?cs if:(Data.ConfigAvail.WebArch == 1) ?>
		    <span class="button"><input type="submit" tabindex="10" name="action"
			value="<?cs var:Lang.Buttons.WebArchive ?>"/>
		    <?cs call:help_icon("WebArch") ?></span>
		<?cs /if ?>

		<!-- extra config options -->
		<span class="button"><input type="submit" tabindex="11" name="action"
			value="<?cs var:Lang.Buttons.Configuration ?>"/>
		<?cs call:help_icon("Config") ?></span>

		<span class="button"><input type="submit" tabindex="12" name="action"
			value="<?cs var:Lang.Buttons.SelectList ?>"/></span>
		</p>
		
	    </div>
	</form>

    </div>

</div>
