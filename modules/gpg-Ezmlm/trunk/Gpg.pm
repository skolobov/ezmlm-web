# ===========================================================================
# Gpg.pm
# $Id$
#
# Object methods for gpg-ezmlm mailing lists
#
# Copyright (C) 2006, Lars Kruse, All Rights Reserved.
# Please send bug reports and comments to devel@sumpfralle.de
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met: 
#
# TODO: change to GPL
#
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# Neither name Lars Kruse nor the names of any contributors
# may be used to endorse or promote products derived from this software
# without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
# IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# ==========================================================================
# POD is at the end of this file. Search for '=head' to find it
package Mail::Ezmlm::Gpg;

use strict;
use vars qw($GPG_EZMLM_BASE $GPG_BIN $VERSION @ISA @EXPORT @EXPORT_OK);
use vars qw(@GPG_LIST_OPTIONS);
use Carp;
use Crypt::GPG;

require Exporter;

@ISA = qw(Exporter);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
   
);
$VERSION = '0.01';

require 5.005;

# == Begin site dependant variables ==
$GPG_EZMLM_BASE = '/usr/local/bin'; #Autoinserted by Makefile.PL
$GPG_BIN = '/usr/bin/gpg';
# == End site dependant variables ==

# == check the ezmlm-make path ==
$GPG_EZMLM_BASE = '/usr/local/bin/ezmlm' unless (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl");
$GPG_EZMLM_BASE = '/usr/local/bin/ezmlm-idx' unless (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl");
$GPG_EZMLM_BASE = '/usr/local/bin' unless (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl");
$GPG_EZMLM_BASE = '/usr/bin/ezmlm' unless (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl");
$GPG_EZMLM_BASE = '/usr/bin/ezmlm-idx' unless (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl");
$GPG_EZMLM_BASE = '/usr/bin' unless (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl");

# == check the gpg path ==
$GPG_BIN = '/usr/local/bin/gpg' unless (-e "$GPG_BIN");
$GPG_BIN = '/bin/gpg' unless (-e "$GPG_BIN");

# == clean up the path for taint checking ==
local $ENV{'PATH'} = $GPG_EZMLM_BASE;

# == define the available (supported) GPG_LIST_OPTIONS ==
@GPG_LIST_OPTIONS = (
		"RequireSub",
		"NokeyNocrypt",
		"signMessages",
		"encryptToAll",
		"VerifiedKeyReq",
		"allowKeySubmission");

# == Initialiser - Returns a reference to the object ==
sub new { 
	my($class, $list) = @_;
	my $self = {};
	bless $self, ref $class || $class || 'Mail::Ezmlm::Gpg';
	$self->setlist($list) if(defined($list) && $list);      
	return $self;
}

# == Make a new mailing list and set it to current ==
sub convert {
	my($self, %list) = @_;

	($self->_seterror(-1, 'must define -dir in a make()') && return 0) unless(defined($list{'-dir'}));

	# Attempt to make the list if we can.
	unless(-e $list{'-dir'}) {
		system("$GPG_EZMLM_BASE/gpg-ezmlm-convert.pm", $list{'-dir'}) == 0
			|| ($self->_seterror($?) && return undef);
	} else {
		($self->_seterror(-1, '-dir must be defined in make()') && return 0);
	}   

	$self->_seterror(undef);
	return $self->setlist($list{'-dir'});
}

# == Update the current list ==
sub update {
	my($self, %switches, %ok_switches) = @_;
	   
	# check for important files: 'config'
	($self->_seterror(-1, "$self->{'LIST_NAME'} does not appear to be a valid list in update()") && return 0) unless((-e "$self->{'LIST_NAME'}/config") || (-e "$self->{'LIST_NAME'}/flags"));

	# check if all supplied settings are supported
	# btw we change the case (upper/lower) of the setting to the default one
	my $one_key;
	foreach $one_key (keys %switches) {
		my $ok_key;
		foreach $ok_key (@GPG_LIST_OPTIONS) {
			if ($ok_key =~ /^$one_key$/i) {
				$ok_switches{$ok_key} = $switches{$one_key};
				delete $switches{$one_key};
			}
		}
	}
	# %switches should be empty now
	if (%switches) {
		foreach $one_key (keys %switches) {
			warn "unsupported setting: $one_key";
		}
	}

	my $config_file_old = "$self->{'LIST_NAME'}/config";
	my $config_file_new = "$self->{'LIST_NAME'}/config.new";
	if(open(CONFIG_OLD, "<$config_file_old")) { 
		if(open(CONFIG_NEW, ">$config_file_new")) { 
			my ($in_line, $one_opt, $one_val, $new_setting);
			while (<CONFIG_OLD>) {
				$in_line = $_;
				if (%ok_switches) {
					while (($one_opt, $one_val) = each(%ok_switches)) {
						# is this the right line (maybe commented out)?
						if ($in_line =~ m/^#?\w*$one_opt/i) {
							print CONFIG_NEW "$one_opt ";
							print CONFIG_NEW ($one_val)? "yes" : "no";
							print CONFIG_NEW "\n";
							delete $ok_switches{$one_opt};
						} else {
							print CONFIG_NEW $in_line;
						}
					}
				} else {
					# just print the remaining config file if no other settings are left
					print CONFIG_NEW $in_line;
				}
			}
			# write the remaining settings to the end of the file
			while (($one_opt, $one_val) = each(%ok_switches)) {
				print CONFIG_NEW "\n$one_opt ";
				print CONFIG_NEW ($one_val)? "yes" : "no";
				print CONFIG_NEW "\n";
			}
		} else {
			my $errorstring = "failed to write to temporary config file: $config_file_new";
			$self->_seterror(-1, $errorstring);
			warn $errorstring;
			close CONFIG_OLD;
			return (1==0);
		}
		close CONFIG_NEW;
	} else {
		my $errorstring = "failed to read the config file: $config_file_old";
		$self->_seterror(-1, $errorstring);
		warn $errorstring;
		return (1==0);
	}
	close CONFIG_OLD;
	unless (rename($config_file_new, $config_file_old)) {
		my $errorstring = "failed to move new config file ($config_file_new) " 
			. "to original config file ($config_file_old)";
		$self->_seterror(-1, $errorstring);
		warn $errorstring;
		return (1==0);
	}
	$self->_seterror(undef);
	return (0==0);
}


# == Get a list of options for the current list ==
sub getconfig {
	my($self) = @_;
	my(%options);

	# Read the config file
	if(open(CONFIG, "<$self->{'LIST_NAME'}/config")) { 
		# 'config' contains the authorative information
		while(<CONFIG>) {
			if (/^(\w+)\s(.*)$/) {
				my $optname = $1;
				my $optvalue = $2;
				my $one_opt;
				foreach $one_opt (@GPG_LIST_OPTIONS) {
					if ($one_opt =~ m/^$optname$/i) {
						if ($optvalue =~ /^yes$/i) {
							$options{$one_opt} = 1;
						} else {
							$options{$one_opt} = 0;
						}
					}
				}
			}
		}
		close CONFIG;
	} else {
		$self->_seterror(-1, 'unable to read configuration file in getconfig()' && return undef);
	}

	$self->_seterror(undef);
	return %options;
}


# == Return the directory of the current list ==
sub thislist {
	my($self) = shift;
	$self->_seterror(undef);
	return $self->{'LIST_NAME'};
}


# == Set the current mailing list ==
sub setlist {
	my($self, $list) = @_;
	if ($list =~ m/^([\w\d\_\-\.\/]+)$/) {
		$list = $1;
		if (-e "$list/lock") {
			$self->_seterror(undef);
			return $self->{'LIST_NAME'} = $list;
		} else {
			$self->_seterror(-1, "$list does not appear to be a valid list in setlist()");
			return undef;
		}
	} else {
		$self->_seterror(-1, "$list contains tainted data in setlist()");
		return undef;
	}
}


# == is the list encrypted? ==
sub is_gpg {
	my($self) = @_;
	($self->_seterror(-1, 'must setlist() before is_gpg()') && return 0) unless(defined($self->{'LIST_NAME'}));
	$self->_seterror(undef);
	return (0==1) unless (-e "$self->{'LIST_NAME'}/config");
	my $content = $self->getpart("config");
	# return false if we encounter the usual ezmlm-idx-v0.4-header
	return (0==1) if ($content =~ /^F:/m);
	return (0==0);
}


# == retrieve file contents ==
sub getpart {
	my($self, $part) = @_;
	my(@contents, $content);
	my $filename = $self->{'LIST_NAME'} . "/$part";
	if (open(PART, "<$filename")) {
		while(<PART>) {
			unless ( /^#/ ) {
				chomp($contents[$#contents++] = $_);
				$content .= $_;
			}
		}
		close PART;
		if(wantarray) {
			return @contents;
		} else {
			return $content;
		}
	} ($self->_seterror($?) && return undef);
}


# == set files contents ==
sub setpart {
	my($self, $part, @content) = @_;
	my($line);
	if(open(PART, ">$self->{'LIST_NAME'}/$part")) {
		foreach $line (@content) {
			$line =~ s/[\r]//g; $line =~ s/\n$//;
			print PART "$line\n";
		}
		close PART;
		return 1;
	} ($self->_seterror($?) && return undef);
}


# == import a new public key for a subscriber ==
sub import_public_key {
	my ($self, $key) = @_;
	my $gpg = $self->_get_gpg_object();
	my @imported_keys = $gpg->addkey($key);
	if ($#imported_keys > 0) {
		return (0==0);
	} else {
		return (1==0);
	}
}


# == delete a public key ==
sub delete_public_key {
	my ($self, $keyid) = @_;
	my $gpg = $self->_get_gpg_object();
	if (undef($gpg->delkey($keyid))) {
		return (1==0);
	} else {
		return (0==0);
	}
}


# == generate new private key ==
sub generate_private_key {
	my ($self, $name, $email, $keysize, $expire) = @_;
	my $gpg = $self->_get_gpg_object();
	return (1==0) if undef($gpg->genkey($name, $email, 'ELG-E', $keysize, $expire));
	return (0==0);
}


# == get_public_keys ==
sub get_public_keys {
	my ($self) = @_;
	my @keys = $self->_get_keys("pub");
	return @keys;
}


# == get_private_keys ==
sub get_secret_keys {
	my ($self) = @_;
	my @keys = $self->_get_keys("sec");
	return @keys;
}

# == internal function for creating a gpg object ==
sub _get_gpg_object() {
	my ($self) = @_;
	my $gpg = new Crypt::GPG();
	$gpg->gpgbin($GPG_BIN);
	$gpg->gpgopts("--lock-multiple --batch --no-tty --no-secmem-warning --homedir '" . $self->{'LIST_NAME'} . "/.gnupg'");
	return $gpg;
}


# == internal function to list keys ==
sub _get_keys() {
	# type can be "pub" or "sec"
	my ($self, $keyType) = @_;
	my $gpg = $self->_get_gpg_object();
	my ($flag, $gpgoption, @keys, $key);
	if ($keyType eq "pub") {
		$flag = "pub";
		$gpgoption = "--list-keys";
	} elsif ($keyType eq "sec") {
		$flag = "sec";
		$gpgoption = "--list-secret-keys";
	} else {
		warn "wrong keyType: $keyType";
		return undef;
	}
	my $gpgcommand = $gpg->gpgbin() . " " . $gpg->gpgopts() . " --with-colons $gpgoption";
	my @read_keys = grep /^$flag/, `$gpgcommand`;
	foreach $key (@read_keys) {
		my ($type, $trust, $size, $algorithm, $id, $created,
			$expires, $u2, $ownertrust, $uid) = split ":", $key;
			# stupid way of "decoding" utf8 (at least it works for ":")
			$uid =~ s/\\x3a/:/g;
			$uid =~ /^(.*) <([^<]*)>/;
			my $name = $1;
			my $email = $2;
		push @keys, {name => $name, email => $email, id => $id, expires => $expires};
	}
	return @keys;
}


# == return an error message if appropriate ==
sub errmsg {
	my($self) = @_;
	return $self->{'ERRMSG'};
}

sub errno {
	my($self) = @_;
	return $self->{'ERRNO'};
}


# == Internal function to set the error to return ==
sub _seterror {
	my($self, $no, $mesg) = @_;

	if(defined($no) && $no) {
		if($no < 0) {
			$self->{'ERRNO'} = -1;
			$self->{'ERRMSG'} = $mesg || 'An undefined error occoured';
		} else {
			$self->{'ERRNO'} = $no / 256;
			$self->{'ERRMSG'} = $! || $mesg || 'An undefined error occoured in a system() call';
		}
	} else {
		$self->{'ERRNO'} = 0;
		$self->{'ERRMSG'} = undef;
	}
	return 1;
}

# == Internal function to test for valid email addresses ==
sub _checkaddress {
	my($self, $address) = @_;
	return 1 unless defined($address);
	return 0 unless ($address =~ m/^(\S+\@\S+\.\S+)$/);
	$_[1] = $1;
	return 1;
}


1;
__END__

=head1 NAME

Ezmlm - Object Methods for Ezmlm Mailing Lists

=head1 SYNOPSIS

 use Mail::Ezmlm;
 $list = new Mail::Ezmlm;
 
The rest is a bit complicated for a Synopsis, see the description.

=head1 ABSTRACT

Ezmlm is a Perl module that is designed to provide an object interface to
the ezmlm mailing list manager software. See the ezmlm web page
(http://www.ezmlm.org/) for a complete description of the software.

This version of the module is designed to work with ezmlm version 0.53.
It is fully compatible with ezmlm's IDX extensions (version 0.4xx and 5.0 ). Both
of these can be obtained via anon ftp from ftp://ftp.ezmlm.org/pub/patches/

=head1 DESCRIPTION

=head2 Setting up a new Ezmlm object:

   use Mail::Ezmlm;
   $list = new Mail::Ezmlm;
   $list = new Mail::Ezmlm('/home/user/lists/moolist');

=head2 Changing which list the Ezmlm object points at:
 

   $list->setlist('/home/user/lists/moolist');

=head2 Getting a list of current subscribers:

=item Two methods of listing subscribers is provided. The first prints a list
of subscribers, one per line, to the supplied FILEHANDLE. If no filehandle is
given, this defaults to STDOUT. An optional second argument specifies the
part of the list to display (mod, digest, allow, deny). If the part is
specified, then the FILEHANDLE must be specified.

   $list->list;
   $list->list(\*STDERR);
   $list->list(\*STDERR, 'deny');

=item The second method returns an array containing the subscribers. The
optional argument specifies which part of the list to display (mod, digest,
allow, deny).

   @subscribers = $list->subscribers;
   @subscribers = $list->subscribers('allow');

=head2 Testing for subscription:

   $list->issub('nobody@on.web.za');
   $list->issub(@addresses);
   $list->issub(@addresses, 'mod');

issub() returns 1 if all the addresses supplied are found as subscribers 
of the current mailing list, otherwise it returns undefined. The optional
argument specifies which part of the list to check (mod, digest, allow,
deny).

=head2 Subscribing to a list:

   $list->sub('nobody@on.web.za');
   $list->sub(@addresses);
   $list->sub(@addresses, 'digest');

sub() takes a LIST of addresses and subscribes them to the current mailing list.
The optional argument specifies which part of the list to subscribe to (mod,
digest, allow, deny).


=head2 Unsubscribing from a list:

   $list->unsub('nobody@on.web.za');
   $list->unsub(@addresses);
   $list->unsub(@addresses, 'mod');

unsub() takes a LIST of addresses and unsubscribes them (if they exist) from the
current mailing list. The optional argument specifies which part of the list
to unsubscribe from (mod, digest, allow, deny).


=head2 Creating a new list:

   $list->make(-dir=>'/home/user/list/moo',
         -qmail=>'/home/user/.qmail-moo',
         -name=>'user-moo',
         -host=>'on.web.za',
         -user=>'onwebza',
         -switches=>'mPz');

make() creates the list as defined and sets it to the current list. There are
three variables which must be defined in order for this to occur; -dir, -qmail and -name.

=over 6

=item -dir is the full path of the directory in which the mailing list is to
be created.

=item -qmail is the full path and name of the .qmail file to create.

=item -name is the local part of the mailing list address (eg if your list
was user-moo@on.web.za, -name is 'user-moo').

=item -host is the name of the host that this list is being created on. If
this item is omitted, make() will try to determine your hostname. If -host is
not the same as your hostname, then make() will attempt to fix DIR/inlocal for
a virtual host.

=item -user is the name of the user who owns this list. This item only needs to
be defined for virtual domains. If it exists, it is prepended to -name in DIR/inlocal.
If it is not defined, the make() will attempt to work out what it should be from
the qmail control files.

=item -switches is a list of command line switches to pass to ezmlm-make(1).
Note that the leading dash ('-') should be ommitted from the string.

=back

make() returns the value of thislist() for success, undefined if there was a
problem with the ezmlm-make system call and 0 if there was some other problem.

See the ezmlm-make(1) man page for more details

=head2 Determining which list we are currently altering:

   $whichlist = $list->thislist;
   print $list->thislist;

=head2 Getting the current configuration of the current list:

   $list->getconfig;

getconfig() returns a string that contains the command line switches that
would be necessary to re-create the current list. It does this by reading the
DIR/config file (idx < v5.0) or DIR/flags (idx >= v5.0) if one of them exists.
If it can't find these files it attempts to work things out for itself (with
varying degrees of success). If both these methods fail, then getconfig()
returns undefined.

   $list->ismodpost;
   $list->ismodsub;
   $list->isremote;
   $list->isdeny;
   $list->isallow;

The above five functions test various features of the list, and return a 1
if the list has that feature, or a 0 if it doesn't. These functions are
considered DEPRECATED as their result is not reliable. Use "getconfig" instead.

=head2 Updating the configuration of the current list:

   $list->update('msPd');

update() can be used to rebuild the current mailing list with new command line
options. These options can be supplied as a string argument to the procedure.
Note that you do not need to supply the '-' or the 'e' command line switch.

   @part = $list->getpart('headeradd');
   $part = $list->getpart('headeradd');
   $list->setpart('headerremove', @part);

getpart() and setpart() can be used to retrieve and set the contents of
various text files such as headeradd, headerremove, mimeremove, etc.

=head2 Manage language dependent text files

   $list->get_available_text_files;
   $list->get_text_content('sub-ok');
   $list->set_text_content('sub-ok', @content);

These functions allow you to manipulate the text files, that are used for
automatic replies by ezmlm.

   $list->is_text_default('sub-ok');
   $list->reset_text('sub-ok');

These two functions are available if you are using ezmlm-idx v5.0 or higher.
is_text_default() checks, if there is a customized text file defined for this list.
reset_text() removes the customized text file from this list. Ezmlm-idx will use
system-wide default text file, if there is no customized text file for this list.

=head2 Change the list's settings (for ezmlm-idx >= 5.0)

   Mail::Ezmlm->get_config_dir;
   $list->get_config_dir;
   $list->set_config_dir('/etc/ezmlm-local');

These function access the file 'conf-etc' in the mailing list's directory. The
static function always returns the default configuration directory of ezmlm-idx
(/etc/ezmlm).

   $list->get_available_languages;
   $list->get_lang;
   $list->set_lang('de');
   $list->get_charset;
   $list->set_charset('iso-8859-1:Q');

These functions allow you to change the language of the text files, that are used
for automatic replies of ezmlm-idx (since v5.0 the configured language is stored
in 'conf-lang' within the mailing list's directory). Customized files (in the 'text'
directory of a mailing list directory) override the default language files.
Empty strings for set_lang() and set_charset() reset the setting to its default value.

=head2 Get the installed version of ezmlm

   Mail::Ezmlm->get_version;

The result is one of the following:
 0 - unknown
 3 - ezmlm 0.53
 4 - ezmlm-idx 0.4xx
 5 - ezmlm-idx 5.x

=head2 Creating MySQL tables:

   $list->createsql();

Currently only works for MySQL.

createsql() will attempt to create the table specified in the SQL connect
options of the current mailing list. It will return an error if the current
mailing list was not configured to use SQL, or is Ezmlm was not compiled
with MySQL support. See the MySQL info pages for more information.

=head2 Checking the Mail::Ezmlm and ezmlm version numbers

The version number of the Mail::Ezmlm module is stored in the variable
$Mail::Ezmlm::VERSION. The compatibility of this version of Mail::Ezmlm
with your system installed version of ezmlm can be checked with

   $list->check_version();

This returns 0 for compatible, or the version string of ezmlm-make(2) if
the module is incompatible with your set up.

=head1 RETURN VALUES

All of the routines described above have return values. 0 or undefined are
used to indicate that an error of some form has occoured, while anything
>0 (including strings, etc) are used to indicate success.

If an error is encountered, the functions

   $list->errno();
   $list->errmsg();

can be used to determine what the error was. 

errno() returns;  0  or undef if there was no error.
                 -1  for an error relating to this module.
                 >0  exit value of the last system() call.

errmsg() returns a string containing a description of the error ($! if it
was from a system() call). If there is no error, it returns undef.

For those who are interested, in those sub routines that have to make system
calls to perform their function, an undefined value indicates that the
system call failed, while 0 indicates some other error. Things that you would
expect to return a string (such as thislist()) return undefined to indicate 
that they haven't a clue ... as opposed to the empty string which would mean
that they know about nothing :)

=head1 AUTHOR

 Guy Antony Halse <guy-ezmlm@rucus.net>
 Lars Kruse <devel@sumpfralle.de>

=head1 BUGS

 There are no known bugs.

 Please report bugs to the author or use the bug tracking system at
 https://systemausfall.org/trac/ezmlm-web.

=head1 SEE ALSO

 ezmlm(5), ezmlm-make(2), ezmlm-sub(1), 
 ezmlm-unsub(1), ezmlm-list(1), ezmlm-issub(1)

 http://rucus.ru.ac.za/~guy/ezmlm/
 https://systemausfall.org/toolforge/ezmlm-web
 http://www.ezmlm.org/
 http://www.qmail.org/

=cut
