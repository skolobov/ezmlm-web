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
            'Ezmlm wird neue Nachrichten zum Archiv hinzufügen'],
      b => ['Archiv nur für ModeratorInnen', 
            'Nur ModeratorInnen haben Zugriff zum Archiv'],
#     c => config. This is implicity called, so is not defined here
      d => ['Zusammenfassungen',
            'Erstelle eine Mailing-Liste, an die regelmäßige Zusammenfassungen versandt werden'], 
#     e => edit. Also implicity called, so not defined here
      f => ['Listenname als Präfix in Betreff einfügen',
            'In die versandten Mails wird in der Betreff-Zeile ein Präfix eingefügt'],
      g => ['Archiv nur für Mitglieder',
            'Nur TeilnehmerInnen der Liste erhalten Zugriff zum Archiv'],
      h => ['abonnieren ohne Bestätigung',
            'Das Abonnieren der Liste erfordert keine Bestätigung durch die neue AbonnentIn'],
      i => ['Web-Index erstellen',
            'Den Zugriff auf das Archiv per Webinterface erlauben'],
      j => ['abmelden ohne Bestätigung',
            'Das Abbestellen der Liste erfordert keine Bestätigung durch die ehemalige AbonnentIn'],
      k => ['Beachte Ausschlussliste',
            'Einsendungen von Abonnenten, die inm deny-Verzeichnis enthalten sind, werden abgelehnt'], 
      l => ['Abonnenten-Auflistung für AdministratorInnen',
            'Die AdministratorInnen können eine Liste aller AbonnentInnen anfordern'],
      m => ['Moderation aktivieren',
            'Alle eingehenden Nachrichten müssen durch eine ModeratorIn bestätigt werden'],
      n => ['Anpassung der Textbausteine erlauben', 
            'Administratoren dürfen die Standard-Textbausteine im Unterverzeichnis text/ verändern'],
      o => ['Nur ModeratorInnen dürfen einsenden', 
            'Nur eingehende Nachrichten von den ModeratorInnen werden akzeptiert'],
      p => ['Öffentlich',
            'Die öffentliche Einschreibung und Archiv-Anforderung ist erlaubt'],
      q => ['Verarbeite Anforderungen',
            'Mails an liste-request@domain werden verarbeitet'],
      r => ['Administration per Mail erlauben',
            'Die Verwaltung der Liste durch Mails der AdministratorInnen ist erlaubt'],
      s => ['Abonnierung durch ModeratorIn bestätigen',
            'Die Einschreibungen in die Liste und die Zusammenfassungs-Liste werden moderiert'],
      t => ['Infotext an Mails anhängen',
            'An alle ausgehenden Mails wird ein Anhang angefügt'], 
      u => ['Nur Abonnenten dürfen einsenden',
            'Einsendungen von nicht-eingeschriebenen Mail-Adressen werden abgewiesen'], 
#     v => version. I doubt you will really need this ;-)
      w => ['Warnung deaktivieren',
            'Entferne den Aufruf von ezmlm-warn aus der Listen-Konfiguration - es wird angenommen, dass ezmlm-warn auf einem anderem Wege gestartet wird'],
      x => ['Filtere Anhänge und Kopfzeilen',
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
            'Ersetze den Absender der ausgehenden Mails durch diese Adresse',
            'Absender'],
      4 => ['Zusammenfassungseinstellungen',
            'Einstellungen for ezmlm-tstdig (nach "t" Stunden oder "m" Nachrichten oder "k" Kilobyte',
            '-t24 -m30 -k64'],
      5 => ['Adresse des Verantwortlichen der Liste',
            'Mail-Adresse des Listen-Eigentümers', 
            'name@domain.org'],
      6 => ['SQL-Datenbank',
            'SQL-Datenbank-Zugangsinformationen (erfordert SQL-Unterstützung)',
            'host:port:user:password:datab:table'],
      7 => ['Listen-Moderations-Verzeichnis',
            'Falls die Liste moderiert wird, ist der vollständige Verzeichnispfad zur Moderationsdatenbank erforderlich',
            '/absoluter/pfad/zur/moderations/datenbank'],
      8 => ['Einschreibungs-Moderations-Verzeichnis',
            'Falls die Einschreibung in die Liste moderiert wird, ist der vollständige Verzeichnispfad zur Einschreibungs-Moderationsdatenbank erforderlich',
            '/absoluter/pfad/zur/abonnenten/moderations/datenbank'],
      9 => ['Administrations-Verzeichnis',
            'Falls die Liste per Mail administriert wird, ist der vollständige Verzeichnispfad zur Administrationsdatenbank erforderlich',
            '/absoluter/pfad/zur/administrations/datenbank'],

);

# This list defines most of the context sensitive help in ezmlm-web. What
# isn't defined here is the options, which are defined above ... You can
# alter these if you feel something else would make more sense to your users
# Just be careful of what can fit on a screen!

%HELPER = (

   # These should be self explainitory
   addaddress       => 'Eine Mail-Adresse - auch in der Form \'Max Meier <max@meier.de>\'',
   addaddressfile   => 'alternativ ist auch eine Datei mit je einer Adresse pro Zeile möglich',
   moderator        => 'ModeratorInnen kontrollen, welche Mails weitegeleitet und welche AbonnentInnen akzeptiert werden',
   deny             => 'Ausschluss: die Mail-Adressen, die NIE an die Liste schreiben dürfen',
   allow            => 'Zulassung: die Mail-Adressen, die immer an die Liste schreiben dürfen',
   digest           => 'Zusammenfassung: diese Leute werden regeläßige Zusammenfassungen der Mailingliste erhalten',
   webarch          => 'Gehe zum Web-Archiv der Mailingliste',
   config           => 'Einstellungen zur Mailingliste',
   listname         => 'Dies ist der eindeutige Name der Mailingliste',
   listadd          => 'Die Adresse der Mailingliste - nur der lokale Teil kann geändert werden',
   webusers         => 'unfertig: derzeit können Listen-Administratoren nur manuell festgelegt werden',
   prefix           => 'Präfix der Betreffzeile',
   headerremove     => 'Diese Kopfzeilen werden aus den ausgehenden Mails entfernt',
   headeradd        => 'Diese Kopfzeilen werden zu jeder ausgehenden Mail hinzugefügt',
   mimeremove       => 'Alle Mails, die die genannten Anhangs-Typen beinhalten, werden abgewiesen',
   allowedit        => 'unfertig: Komma-getrennte Liste von Nutzern oder <CODE>ALL</CODE> die diese Liste konfigurieren dürfen',
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
   addaddress            => 'Füge Adresse hinzu',
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
   nop                   => 'Diese Funktionalität ist noch nicht umgesetzt worden',
   chooselistinfo        => "<UL><LI>Markiere eine Liste in der Auswahlbox oder klicke auf [$BUTTON{'create'}].<LI>Klicke auf den [$BUTTON{'edit'}]-Schalter, falls du die markierte Liste bearbeiten möchtest.<LI>Klicke auf den [$BUTTON{'delete'}]-Schalter, falls du die markierte Liste löschen möchtest.</UL>",
   confirmdelete         => 'Bestätige die Löschung von ', # list name
   subscribersto         => 'Abonnenten von', # list name
   subscribers           => 'Abonnenten',
   additionalparts       => 'Weitere Listen-Bestandteile',
   posting               => 'Einsendungen',
   subscription          => 'Einschreibung',
   remoteadmin           => 'Entfernte AdministratorIn',
   for                   => 'für', # as in; moderators for blahlist
   createnew             => 'Lege eine neue Liste an',
   listname              => 'Name der Liste',
   listaddress           => 'Adresse der Liste',
   listoptions           => 'Einstellungen der Liste',
   allowedtoedit         => 'Nutzer, die diese Liste bearbeiten dürfen',
   editconfiguration     => 'Einstellungen ändern',
   prefix                => 'Präfix der Betreff-Zeile ausgehender Nachrichten',
   headerremove          => 'zu entfernende Kopfzeilen',
   headeradd             => 'einzufügende Kopfzeilen',
   mimeremove            => 'abzuweisende Anhangs-Typen',
   edittextinfo          => "Das Auswahlfeld links enthält die Dateien des <BR>Verzeichnisses DIR/text/. Diese Dateien werden als Antwort auf spezifische Nutzer-Anfragen oder als Teil aller ausgehenden Nachrichten versandt.<P>Um diese Dateien zu verändern, wähle ihren Namen im Auswahlfeld an. Anschlißend klicke auf den [$BUTTON{'editfile'}] Schalter.<P>Betätige [$BUTTON{'cancel'}] um die Veränderung abzubrechen.",
   editingfile           => 'Bearbeite Datei',
   editfileinfo          => '<BIG><STRONG>ezmlm-manage</STRONG></BIG><BR><TT><STRONG>&lt;#l#&gt;</STRONG></TT> Der Name der Liste<BR><TT><STRONG>&lt;#A#&gt;</STRONG></TT> Die Anmeldungs-Adresse<BR><TT><STRONG>&lt;#R#&gt;</STRONG></TT> Die Bestätigungs-Adresse<P><BIG><STRONG>ezmlm-store</STRONG></BIG><BR><TT><STRONG>&lt;#l#&gt</STRONG></TT> Der Name der Liste<BR><TT><STRONG>&lt;#A#&gt;</STRONG></TT> Die Zusage-Adresse<BR><TT><STRONG>&lt;#R#&gt;</STRONG></TT> Die Ablehungs-Adresse</UL>',
   mysqlcreate           => 'Lege die MySQL-Datenbank an, falls erforderlich',

);

#                      === Configuration file ends ===
