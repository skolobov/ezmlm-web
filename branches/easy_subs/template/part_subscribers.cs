<div id="parts" class="container">
    <div class="title">
	<!-- TODO: einheitliche Formatierung fuer listaddress - span und css -->
	<h2><?cs var:Lang.Misc.For ?> <i><?cs var:Data.List.Name ?></i></h2>
	<h3><?cs var:Data.List.Address ?></h3>
	<hr>
    </div>

    <?cs if:Data.isModerated ?>
	    <!-- Moderation -->
	    <?cs include:TemplateDir + "modpath_info.cs" ?>
    <?cs /if ?>

    <!-- form -->
    <form method="post" action="<?cs var:ScriptName ?>" enctype="application/x-www-form-urlencoded">
	<input type="hidden" name="state" value="<?cs var:Data.Form.State ?>">
	<input type="hidden" name="list" value="<?cs var:Data.List.Name ?>">
	    <div class="list">
		

	<!-- TODO: the same as of "display_list.cs" -->
	<!-- list of moderators/administrators -->
	<?cs if:Data.ListCount >0 ?>
	    <!-- Keep selection box a resonable size - suggested by Sebastian Andersson -->
	    <?cs if:(Data.List.SubscribersCount > 25) ?>
		<?cs set:Data.ScrollSize = 25 ?>
	      <?cs else ?>
	 	<?cs set:Data.ScrollSize = Data.ListCount ?>
	    <?cs /if ?>
	    <select name="delsubscriber" tabindex="1" multiple="true" size="<?cs var:Data.ScrollSize ?>">
		<?cs each:item = Data.List.Subscribers ?>
		    <!-- TODO: pretty names sind notwendig -->
		    <option><?cs var:item ?></option>
		<?cs /each ?>
	    </select>
	<?cs /if ?>


	<div class="add_remove">

	  <?cs if:(Data.List.SubscribersCount > 0) ?>
	    <div class="button"><input type="submit"
		value="<?cs var:Lang.Buttons.DeleteAddress ?>" name="action"/></div>
	  <?cs /if ?>

	  <div class="formfield">
	    <input type="text" name="addsubscriber" size="40"/><?cs call:help_icon("AddAddress") ?>
	  </div>
	  <?cs if:Data.Permissions.FileUpload ?>
	    <div class="formfield">
	      <input type="filefield" name="addfile" size="20" maxlength="100"/> <?cs call:help_icon("AddAddressFile") ?>
	    </div>
	  <?cs /if ?>
	  <div class="button">
	    <input type="submit" name="action" value="<?cs var:Lang.Buttons.AddAddress ?>"/></div>
	  <div class="button">
	    <input type="submit" name="action" value="<?cs var:Lang.Buttons.Subscribers ?>"/></div>

	</div>

    </form>
</div>
