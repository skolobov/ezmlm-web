<div id="config" class="container">

    <div class="title">
	<h2><?cs var:Lang.Misc.EditConfiguration ?></h2>
	<hr>
    </div>

  <form method="post" action="<?cs var:ScriptURL ?>" enctype="application/x-www-form-urlencoded">
    <input type="hidden" name="state" value="configuration">
    <input type="hidden" name="list" value="<?cs var:Data.ListName ?>">
    <div class="info">
	<p><?cs var:Lang.Misc.ListName ?>: <em><?cs var:Data.ListName ?></em></p>
	<p><?cs var:Lang.Misc.ListAddress ?>: <em><?cs var:Data.ListAddress ?></em></p>
    </div>

    <div class="input">
	<h2><?cs var:Lang.Misc.ListOptions ?> :</h2>
	<!-- TODO: hier muss display_options reinkommen -->
	<!-- TODO: "default" ist kein html-Element, oder? - value?
	<?cs if:Data.List.Prefix ?>
	  <span class="formfield"><?cs var:Lang.Misc.Prefix ?>: <input type="textfield" name="prefix"
	    default="<?cs var:Data.List.Prefix ?>" size="12"><?cs call:help_icon("Prefix") ?></span>
	<?cs /if ?>
	<span class="formfield"><?cs var:Lang.Misc.HeaderRemove ?>:
	  <?cs call:help_icon("HeaderRemove") ?><br/><input type="textarea" name="headerremove"
	  default="<?cs var:Data.List.HeaderRemove ?>" rows="5" columns="70"></span>
	<span class="formfield"><?cs var:Lang.Misc.HeaderAdd ?>:<?cs call:help_icon("HeaderAdd") ?>
	  <br/><input type="textarea" name="headeradd" default="<?cs var:Data.List.HeaderAdd ?>"
	  rows="5" columns="70"></span>
	<?cs if:Data.List.MimeRemove ?>
	  <span class="formfield"><?cs var:Lang.Misc.MimeRemove ?>:
	    <?cs call:help_icon("MimeRemove") ?><br/><input type="textarea" name="mimeremove"
	    default="<?cs var:Data.List.MimeRemove ?>" rows="5" columns="70"></span>
	<?cs /if ?>

	<?cs if:Data.List.WebUsers ?>
	    <span class="formfield"><?cs var:Lang.Misc.AllowedToEdit ?>: <input type="textfield"
	      name="webusers" value="<?cs var:Data.List.WebUsers ?>" size="30">
	      <?cs call:help_icon("WebUsers") ?></span>
	    <span class="help"><?cs Lang.Helper.AllowEdit ?></span>
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
