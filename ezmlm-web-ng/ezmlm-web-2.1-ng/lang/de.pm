# language-specific definitions for ezmlm-web
# in english

# The meanings of the various ezmlm-make command line switches. The default
# ones match the ezmlm-idx 0.4 default ezmlmrc ... Alter them to suit your
# own ezmlmrc. Removing options from this list makes them unavailable
# through ezmlm-web - this could be useful for things like -w

%EZMLM_LABELS = (
#   option => ['Short Name', 
#              'Long Help Description'],

      a => ['archivieren', 
            'Ezmlm wird neue Nachrichten zum Archiv hinzuf&uuml;gen'],
      b => ['Archiv nur f&uuml;r ModeratorInnen', 
            'Nur ModeratorInnen haben Zugriff zum Archiv'],
#     c => config. This is implicity called, so is not defined here
      d => ['Zusammenfassungen',
            'Erstelle eine Mailing-Liste, an die regelm&auml;&szlig;ige Zusammenfassungen versandt werden'], 
#     e => edit. Also implicity called, so not defined here
      f => ['Pr&auml;fix in Betreff einf&uuml;gen',
            'In die versandten Mails wird in der Betreff-Zeile ein Pr&auml;fix eingef&uuml;gt'],
      g => ['Archiv nur f&uuml;r Mitglieder',
            'Nur TeilnehmerInnen der Liste erhalten Zugriff zum Archiv'],
      h => ['abonnieren ohne Best&auml;tigung',
            'Das Abonnieren der Liste erfordert keine Best&auml;tigung durch die neue AbonnentIn'],
      i => ['Web-Index erstellen',
            'Den Zugriff auf das Archiv per Webinterface erlauben'],
      j => ['abmelden ohne Best&auml;tigung',
            'Das Abbestellen der Liste erfordert keine Best&auml;tigung durch die ehemalige AbonnentIn'],
      k => ['Beachte Ausschlussliste',
            'Einsendungen von Abonnenten, die inm deny-Verzeichnis enthalten sind, werden abgelehnt'], 
      l => ['Abonnenten-Auflistung f&uuml;r AdministratorInnen',
            'Die AdministratorInnen k&ouml;nnen eine Liste aller AbonnentInnen anfordern'],
      m => ['Moderation aktivieren',
            'Alle eingehenden Nachrichten m&uuml;ssen durch eine ModeratorIn best&auml;tigt werden'],
      n => ['Anpassung der Textbausteine erlauben', 
            'Administratoren d&uuml;rfen die Standard-Textbausteine im Unterverzeichnis text/ ver&auml;ndern'],
      o => ['Nur ModeratorInnen d&uuml;rfen einsenden', 
            'Nur eingehende Nachrichten von den ModeratorInnen werden akzeptiert'],
      p => ['&Ouml;ffentlich',
            'Die &ouml;ffentliche Einschreibung und Archiv-Anforderung ist erlaubt'],
      q => ['Verarbeite Anforderungen',
            'Mails an liste-request@domain werden verarbeitet'],
      r => ['Administration per Mail erlauben',
            'Die Verwaltung der Liste durch Mails der AdministratorInnen ist erlaubt'],
      s => ['Abonnierung durch ModeratorIn best&auml;tigen',
            'Die Einschreibungen in die Liste und die Zusammenfassungs-Liste werden moderiert'],
      t => ['Infotext an Mails anh&auml;ngen',
            'An alle ausgehenden Mails wird ein Anhang angef&uuml;gt'], 
      u => ['Nur Abonnenten d&uuml;rfen einsenden',
            'Einsendungen von nicht-eingeschriebenen Mail-Adressen werden abgewiesen'], 
#     v => version. I doubt you will really need this ;-)
      w => ['Warnung deaktivieren',
            'Entferne den Aufruf von ezmlm-warn aus der Listen-Konfiguration - es wird angenommen, dass ezmlm-warn auf einem anderem Wege gestartet wird'],
      x => ['Filtere Anh&auml;nge und Kopfzeilen',
            'Mails mit den angegebenen Anhangs-Typen werden abgewiesen - die angegebenen Kopfzeilen werden aus den ausgehenden Mails entfernt'],
#     y => not used
#     z => not used

# These all take an extra argument, which is the default value to use

      0 => ['Unterlisten', 
            'Diese Liste soll eine Unterliste einer anderen Hauptliste sein',
            'hauptliste@domain'],   
#     1 => not used
#     2 => not used
      3 => ['Absender',
            'Ersetze den Absender der ausgehenden Mails durch diesen Text',
            'Absender'],
      4 => ['Zusammenfassungseinstellungen',
            'Einstellungen for ezmlm-tstdig (nach &quot;t&quot; Stunden oder &quot;m&quot; Nachrichten oder &quot;k&quot; Kilobyte',
            '-t24 -m30 -k64'],
      5 => ['Adresse des Verantwortlichen der Liste',
            'Mail-Adresse des Listen-Eigent&uuml;mers', 
            'name@domain.org'],
      6 => ['SQL-Datenbank',
            'SQL-Datenbank-Zugangsinformationen (erfordert SQL-Unterst&uuml;tzung)',
            'host:port:user:password:datab:table'],
      7 => ['Listen-Moderations-Verzeichnis',
            'Falls die Liste moderiert wird, ist der vollst&auml;ndige Verzeichnispfad zur Moderationsdatenbank erforderlich',
            '/absoluter/pfad/zur/moderations/datenbank'],
      8 => ['Einschreibungs-Moderations-Verzeichnis',
            'Falls die Einschreibung in die Liste moderiert wird, ist der vollst&auml;ndige Verzeichnispfad zur Einschreibungs-Moderationsdatenbank erforderlich',
            '/absoluter/pfad/zur/abonnenten/moderations/datenbank'],
      9 => ['Administrations-Verzeichnis',
            'Falls die Liste per Mail administriert wird, ist der vollst&auml;ndige Verzeichnispfad zur Administrationsdatenbank erforderlich',
            '/absoluter/pfad/zur/administrations/datenbank'],

);

# This list defines most of the context sensitive help in ezmlm-web. What
# isn't defined here is the options, which are defined above ... You can
# alter these if you feel something else would make more sense to your users
# Just be careful of what can fit on a screen!

%HELPER = (

   # These should be self explainitory
   addaddress       => 'Hier ist eine Mail-Adresse erforderlich. Auch Eingaben in der Form &quot;Max Meier &lt;max@meier.de&gt;&quot;',
   addaddressfile   => 'alternativ ist auch die Angabe einer Datei mit jeweils einer Mailadresse pro Zeile m&ouml;glich',
   moderator        => 'ModeratorInnen kontrollen, welche Mails weitegeleitet und welche AbonnentInnen akzeptiert werden',
   deny             => 'Ausschluss: die Mail-Adressen, die NIE an die Liste schreiben d&uuml;rfen',
   allow            => 'Zulassung: die Mail-Adressen, die trotz anderweitiger Einschr&auml;nkungen immer an die Liste schreiben d&uuml;rfen',
   digest           => 'Zusammenfassung: diese Leute werden regel&auml;&szlig;ige Zusammenfassungen der Mailingliste erhalten',
   webarch          => 'Gehe zum Web-Archiv der Mailingliste',
   config           => 'Einstellungen zur Mailingliste',
   listname         => 'Dies ist der eindeutige Name der Mailingliste',
   listadd          => 'Die Adresse der Mailingliste - der Standardwert wird durch qmail festgelegt - nur der lokale Teil der Adresse sollte ge&auml;ndert werden',
   webusers         => 'unfertig: derzeit k&ouml;nnen Listen-Administratoren nur manuell festgelegt werden',
   prefix           => 'Pr&auml;fix der Betreffzeile',
   headerremove     => 'Diese Kopfzeilen werden aus den ausgehenden Mails entfernt',
   headeradd        => 'Diese Kopfzeilen werden zu jeder ausgehenden Mail hinzugef&uuml;gt',
   mimeremove       => 'Alle Mails, die die genannten Anhangs-Typen beinhalten, werden abgewiesen',
   allowedit        => 'unfertig: Komma-getrennte Liste von Nutzern oder <CODE>ALL</CODE> die diese Liste konfigurieren d&uuml;rfen',
   mysqlcreate      => 'Anlegen der konfigurierten MySQL-Datenbank'

);

# This defines the captions of each of the buttons in ezmlm-web, and allows 
# you to configure them for your own language or taste. Since these are used
# by the switching algorithm it is important that every button has a unique
# caption - ie we can't have two 'Edit' buttons doing different things.

%BUTTON = (
   
   # These MUST all be unique!
   create                => 'Anlegen',
   createlist            => 'Liste anlegen',
   edit                  => 'Bearbeiten',
   delete                => 'Entfernen',
   deleteaddress         => 'Entferne Adresse',
   addaddress            => 'Fuege Adresse hinzu',
   moderators            => 'ModeratorInnen',
   denylist              => 'Ausschlussliste',
   allowlist             => 'Zulassungsliste',
   digestsubscribers     => 'Abonnenten der Zusammenfassungen',
   configuration         => 'Konfiguration',
   yes                   => 'Ja',
   no                    => 'Nein',
   updateconfiguration   => 'Speichere Konfiguration',
   edittexts             => 'Bearbeite Texte',
   editfile              => 'Bearbeite Datei',
   savefile              => 'Speichere Datei',
   webarchive            => 'Web-Archiv',
   selectlist            => 'Listenauswahl',
   subscribers           => 'AbonnentInnen',
   cancel                => 'Abbruch',
   resetform             => 'Reset',

);

# This defines the fixed text strings that are used in ezmlm-web. By editing
# these along with the button labels and help texts, you can convert ezmlm-web
# to another language :-) If anyone gets arround to doing complete templates
# for other languages I would appreciate a copy so that I can include it in
# future releases of ezmlm-web.

%LANGUAGE = (
   nop                   => 'Diese Funktionalit&auml;t ist noch nicht umgesetzt worden',
   chooselistinfo        => "<UL><LI>Markiere eine Liste in der Auswahlbox oder klicke auf [$BUTTON{'create'}].<LI>Klicke auf den [$BUTTON{'edit'}]-Schalter, falls du die markierte Liste bearbeiten m&ouml;chtest.<LI>Klicke auf den [$BUTTON{'delete'}]-Schalter, falls du die markierte Liste l&ouml;schen m&ouml;chtest.</UL>",
   confirmdelete         => 'Best&auml;tige die L&ouml;schung von ', # list name
   subscribersto         => 'Abonnenten von', # list name
   subscribers           => 'Abonnenten',
   additionalparts       => 'Weitere Listen-Bestandteile',
   posting               => 'Einsendungen',
   subscription          => 'Einschreibung',
   remoteadmin           => 'Entfernte AdministratorIn',
   for                   => 'f&uuml;r', # as in; moderators for blahlist
   createnew             => 'Lege eine neue Liste an',
   listname              => 'Name der Liste',
   listaddress           => 'Adresse der Liste',
   listoptions           => 'Einstellungen der Liste',
   allowedtoedit         => 'Nutzer, die diese Liste bearbeiten d&uuml;rfen',
   editconfiguration     => 'Einstellungen &auml;ndern',
   prefix                => 'Pr&auml;fix der Betreff-Zeile ausgehender Nachrichten',
   headerremove          => 'zu entfernende Kopfzeilen',
   headeradd             => 'einzuf&uuml;gende Kopfzeilen',
   mimeremove            => 'abzuweisende Anhangs-Typen',
   edittextinfo          => "Das Auswahlfeld links enth&auml;lt die Dateien des <BR>Verzeichnisses DIR/text/. Diese Dateien werden als Antwort auf spezifische Nutzer-Anfragen oder als Teil aller ausgehenden Nachrichten versandt.<P>Um diese Dateien zu ver&auml;ndern, w&auml;hle ihren Namen im Auswahlfeld an. Anschli&szlig;end klicke auf den [$BUTTON{'editfile'}] Schalter.<P>Bet&auml;tige [$BUTTON{'cancel'}] um die Ver&auml;nderung abzubrechen.",
   editingfile           => 'Bearbeite Datei',
   editfileinfo          => '<BIG><STRONG>ezmlm-manage</STRONG></BIG><BR><TT><STRONG>&lt;#l#&gt;</STRONG></TT> Der Name der Liste<BR><TT><STRONG>&lt;#A#&gt;</STRONG></TT> Die Anmeldungs-Adresse<BR><TT><STRONG>&lt;#R#&gt;</STRONG></TT> Die Best&auml;tigungs-Adresse<P><BIG><STRONG>ezmlm-store</STRONG></BIG><BR><TT><STRONG>&lt;#l#&gt;</STRONG></TT> Der Name der Liste<BR><TT><STRONG>&lt;#A#&gt;</STRONG></TT> Die Zusage-Adresse<BR><TT><STRONG>&lt;#R#&gt;</STRONG></TT> Die Ablehungs-Adresse</UL>',
   mysqlcreate           => 'Lege die MySQL-Datenbank an, falls erforderlich',

);

#                      === Configuration file ends ===
