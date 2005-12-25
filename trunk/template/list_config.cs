<div id="config" class="container">

    <div class="title">
	<h2><?cs var:Lang.Misc.EditConfiguration ?></h2>
	<hr>
    </div>

  <form method="post" action="<?cs var:ScriptName ?>" enctype="application/x-www-form-urlencoded">
    <input type="hidden" name="state" value="configuration">
    <input type="hidden" name="list" value="<?cs var:Data.List.Name ?>">
    <div class="info">
	<p><?cs var:Lang.Misc.ListName ?>: <em><?cs var:Data.List.Name ?></em></p>
	<p><?cs var:Lang.Misc.ListAddress ?>: <em><?cs var:Data.List.Address ?></em></p>
    </div>

    <div class="input">
	<h2><?cs var:Lang.Misc.ListOptions ?> :</h2>

	<?cs include:TemplateDir + "display_options.cs" ?>

	<?cs if:Data.List.Prefix ?>
	  <div class="formfield"><?cs var:Lang.Misc.Prefix ?>: <input type="text" name="prefix"
	    value="<?cs var:Data.List.Prefix ?>" size="12"><?cs call:help_icon("Prefix") ?></div>
	<?cs /if ?>
	<div class="formfield"><?cs var:Lang.Misc.HeaderRemove ?>:<?cs call:help_icon("HeaderRemove") ?>
	  <br/><textarea name="headerremove" rows="5" cols="70"><?cs var:Data.List.HeaderRemove ?></textarea></div>
	<div class="formfield"><?cs var:Lang.Misc.HeaderAdd ?>:<?cs call:help_icon("HeaderAdd") ?>
	  <br/><textarea name="headeradd" rows="5" cols="70"><?cs var:Data.List.HeaderAdd ?></textarea></div>
	<?cs if:Data.List.MimeRemove ?>
	  <div class="formfield"><?cs var:Lang.Misc.MimeRemove ?>:<?cs call:help_icon("MimeRemove") ?>
	    <br/><textarea name="mimeremove" rows="5" cols="70"><?cs var:Data.List.MimeRemove ?></textarea></div>
	<?cs /if ?>

	<?cs if:Data.List.WebUsers ?>
	  <div>
	    <span class="formfield"><?cs var:Lang.Misc.AllowedToEdit ?>: <input type="text"
	      name="webusers" value="<?cs var:Data.List.WebUsers ?>" size="30">
	      <cs call:help_icon("WebUsers") ?></span>
	    <span class="help"><?cs var:Lang.Helper.AllowEdit ?></span>
	  </div>
	<?cs /if ?>
    </div>

    <div class="question">
	<span class="button"><input type="submit" name="action"
	  value="<?cs var:Lang.Buttons.UpdateConfiguration ?>"></span>
	<span class="button"><input type="reset" name="action"
	  value="<?cs var:Lang.Buttons.ResetForm ?>"></span>
	<span class="button"><input type="submit" name="action"
	  value="<?cs var:Lang.Buttons.Cancel ?>"></span>
	<span class="button"><input type="submit" name="action"
	  value="<?cs var:Lang.Buttons.EditTexts ?>"></span>
    </div>

  </form>

</div>