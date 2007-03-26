# ===========================================================================
# Gpg.pm
# $Id$
#
# Object methods for gpg-ezmlm mailing lists
#
# Copyright (C) 2006, Lars Kruse, All Rights Reserved.
# Please send bug reports and comments to devel@sumpfralle.de
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
#
# ==========================================================================

package Mail::Ezmlm::Gpg;

use strict;
use vars qw($GPG_EZMLM_BASE $GPG_BIN $VERSION @ISA @EXPORT @EXPORT_OK);
use vars qw(@GPG_LIST_OPTIONS);
use Carp;
use Crypt::GPG;

$VERSION = '0.1';

require 5.005;

=head1 NAME

Mail::Ezmlm::Gpg - Object Methods for encrypted Ezmlm Mailing Lists

=head1 SYNOPSIS

 use Mail::Ezmlm::Gpg;
 $list = new Mail::Ezmlm::Gpg(DIRNAME);

The rest is a bit complicated for a Synopsis, see the description.

=head1 DESCRIPTION

Mail::Ezmlm::Gpg is a Perl module that is designed to provide an object
interface to encrypted mailing lists based upon gpgpy-ezmlm.
See the gpgpy-ezmlm web page (https://systemausfall.org/toolforge/gpgpy-ezmlm/)
for a this software.

=cut

# == Begin site dependant variables ==
$GPG_BIN = '/usr/bin/gpg';	# Autoinserted by Makefile.PL


# == check the gpg path ==
$GPG_BIN = '/usr/local/bin/gpg'
	unless (-e "$GPG_BIN");
$GPG_BIN = '/usr/bin/gpg'
	unless (-e "$GPG_BIN");
$GPG_BIN = '/bin/gpg'
	unless (-e "$GPG_BIN");
$GPG_BIN = '/usr/local/bin/gpg2'
	unless (-e "$GPG_BIN");
$GPG_BIN = '/usr/bin/gpg2'
	unless (-e "$GPG_BIN");
$GPG_BIN = '/bin/gpg2'
	unless (-e "$GPG_BIN");
$GPG_BIN = '/usr/local/bin/gpg'
	unless (-e "$GPG_BIN");
$GPG_BIN = '/bin/gpg'
	unless (-e "$GPG_BIN");

# == clean up the path for taint checking ==
local $ENV{'PATH'} = "/bin";

# == define the available (supported) GPG_LIST_OPTIONS ==
my %GPGPY_DEFAULT_OPTIONS = (
		"plain_without_key" => 0,
		"sign_messages" => 0,
		"gnupg_dir" => ".gnupg" );

my $GPGPY_CONF_FILE = 'conf-gpgpy';

# == Initialiser - Returns a reference to the object ==

=head2 Setting up a new Ezmlm::Gpg object:

   use Mail::Ezmlm::Gpg;
   $list = new Mail::Ezmlm::Gpg('/home/user/lists/moolist');

new() returns the value of thislist() for success, undefined if there was a
problem.

=cut

sub new { 
	my($class, $list) = @_;
	my $self = {};
	bless $self, ref $class || $class || 'Mail::Ezmlm::Gpg';
	$list =~ m/^([\w\._\/-]*)$/;
	$list = $1;
	$self->setlist($list) if(defined($list) && $list);      
	return $self;
}

# == convert an existing list to gpg-ezmlm ==

=head2 Converting a plaintext mailing list to an encrypted list:

You have to create a normal list before you can convert it.
Use Mail::Ezmlm to do this.

   $list->enable_encryption();

=cut

sub enable_encryption {
	my($self) = @_;
	my $errorstring;

	my $list_dir = $self->{'LIST_NAME'};

	unless (defined($list_dir)) {
		$errorstring = 'must define directory in enable_encrypted()';
		$self->_seterror(-1, $errorstring);
		warn $errorstring;
		return (1==0);
	}

	unless(-d $list_dir) {
		$errorstring = 'directory does not exist: ' . $list_dir;
		$self->_seterror(-1, $errorstring);
		warn $errorstring;
		return (1==0);
	}

	if ($self->is_encrypted()) {
		$errorstring = 'list is already encrypted: ' . $list_dir;
		$self->_seterror(-1, $errorstring);
		warn $errorstring;
		return (1==0);
	}

	# create config file - this enables encryption support
	unless (open(CONFIG_FILE, ">$list_dir/$GPGPY_CONF_FILE")) { 
		$errorstring = "failed to create config file: $list_dir/$GPGPY_CONF_FILE";
		$self->_seterror(-1, $errorstring);
		warn $errorstring;
		return (1==0);
	}
	close(CONFIG_FILE);

	# we write the default values to the file - this is easier to read for humans
	return (1==0) unless ($self->update(%GPGPY_DEFAULT_OPTIONS));

	$self->_seterror(undef);
	return (0==0);
}

# == convert an encrypted list back to plaintext ==

=head2 Converting an encryted mailing list to a plaintext list:

   $list->disable_encryption();

=cut

sub disable_encryption {
	my($self) = @_;
	my $errorstring;

	my $list_dir = $self->{'LIST_NAME'};

	unless (defined($list_dir)) {
		$errorstring = 'must define directory in disable_encrypted()';
		$self->_seterror(-1, $errorstring);
		warn $errorstring;
		return (1==0);
	}

	unless(-d $list_dir) {
		$errorstring = 'directory does not exist: ' . $list_dir;
		$self->_seterror(-1, $errorstring);
		warn $errorstring;
		return (1==0);
	}

	unless ($self->is_encrypted()) {
		$errorstring = 'list is not encrypted: ' . $list_dir;
		$self->_seterror(-1, $errorstring);
		warn $errorstring;
		return (1==0);
	}

	unless (unlink("$list_dir/$GPGPY_CONF_FILE")) {
		$errorstring = "failed to remove config file: $list_dir/$GPGPY_CONF_FILE";
		$self->_seterror(-1, $errorstring);
		warn $errorstring;
		return (1==0);
	}

	$self->_seterror(undef);
	return (0==0);
}

# == Update the current list ==

=head2 Updating the configuration of the current list:

   $list->update({ 'allowKeySubmission' => 1 });

=cut

sub update {
	my($self, %switches) = @_;
	my %ok_switches;
	my ($one_key, $ok_key, $errorstring);
	   
	# check for important files: 'conf-gpgpy'
	unless ((-e "$self->{'LIST_NAME'}/config") || (-e "$self->{'LIST_NAME'}/lock")) {
		$errorstring = "$self->{'LIST_NAME'} does not appear to be a valid list in     update()";
		$self->_seterror(-1, $errorstring);
		warn $errorstring;
		return (0==1);
	}

	# check if all supplied settings are supported
	# btw we change the case (upper/lower) of the setting to the default one
	foreach $one_key (keys %switches) {
		foreach $ok_key (keys %GPGPY_DEFAULT_OPTIONS) {
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

	my $config_file_old = "$self->{'LIST_NAME'}/$GPGPY_CONF_FILE";
	my $config_file_new = "$self->{'LIST_NAME'}/$GPGPY_CONF_FILE.new";
	if(open(CONFIG_OLD, "<$config_file_old")) { 
		if(open(CONFIG_NEW, ">$config_file_new")) { 
			my ($in_line, $one_opt, $one_val, $new_setting);
			while (<CONFIG_OLD>) {
				$in_line = $_;
				if (%ok_switches) {
					my $found = 0;
					while (($one_opt, $one_val) = each(%ok_switches)) {
						# is this the right line (maybe commented out)?
						if ($in_line =~ m/^#?\w*$one_opt/i) {
							print CONFIG_NEW "$one_opt = ";
							if ($one_opt eq "gnupg_dir") {
								print CONFIG_NEW $one_val;
							} else {
								print CONFIG_NEW ($one_val)? "yes" : "no";
							}
							print CONFIG_NEW "\n";
							delete $ok_switches{$one_opt};
							$found = 1;
						}
					}
					print CONFIG_NEW $in_line if ($found == 0);
				} else {
					# just print the remaining config file if no other settings are left
					print CONFIG_NEW $in_line;
				}
			}
			# write the remaining settings to the end of the file
			while (($one_opt, $one_val) = each(%ok_switches)) {
				print CONFIG_NEW "\n$one_opt = ";
				# is this a non-boolean setting?
				if ($one_opt eq "gnupg_dir") {
					print CONFIG_NEW $one_val;
				} else {
					print CONFIG_NEW ($one_val)? "yes" : "no";
				}
				print CONFIG_NEW "\n";
			}
		} else {
			$errorstring = "failed to write to temporary config file: $config_file_new";
			$self->_seterror(-1, $errorstring);
			warn $errorstring;
			close CONFIG_OLD;
			return (1==0);
		}
		close CONFIG_NEW;
	} else {
		$errorstring = "failed to read the config file: $config_file_old";
		$self->_seterror(-1, $errorstring);
		warn $errorstring;
		return (1==0);
	}

	close CONFIG_OLD;
	unless (rename($config_file_new, $config_file_old)) {
		$errorstring = "failed to move new config file ($config_file_new) " 
			. "to original config file ($config_file_old)";
		$self->_seterror(-1, $errorstring);
		warn $errorstring;
		return (1==0);
	}

	$self->_seterror(undef);
	return (0==0);
}


# == Get a list of options for the current list ==

=head2 Getting the current configuration of the current list:

   $list->getconfig;

getconfig() returns a hash including all available settings
(undefined settings are returned with their default value).

=cut

sub getconfig {
	my($self) = @_;
	my(%options, $key);

	foreach $key (keys %GPGPY_DEFAULT_OPTIONS) {
		$options{$key} = $GPGPY_DEFAULT_OPTIONS{$key};
	}

	# Read the config file
	if(open(CONFIG, "<$self->{'LIST_NAME'}/$GPGPY_CONF_FILE")) { 
		# 'conf-gpgpy' contains the authorative information
		while(<CONFIG>) {
			if (/^(\w+)\s*=\s*(.*)$/) {
				my $optname = $1;
				my $optvalue = $2;
				my $one_opt;
				foreach $one_opt (keys %GPGPY_DEFAULT_OPTIONS) {
					if ($one_opt =~ m/^$optname$/i) {
						if ($optname ne 'gnupg_dir') {
							# 'gnupg_dir' is the only non-boolean setting
							if ($optvalue =~ /^yes$/i) {
								$options{$one_opt} = 1;
							} else {
								$options{$one_opt} = 0;
							}
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

# == Return the directory of the gnupg keyring of the current list ==

=head2 Retrieving the directory of the gnupg keyring of the current list

   $print $list->get_gnupg_dir();

=cut

sub get_gnupg_dir {
	my ($self) = shift;

	my %config = $self->getconfig();
	my $setting = $config{"gnupg_dir"};

	$self->_seterror(undef);

	# prefix the directory with the list directory if the directory is not absolute
	if (substr($setting, 0, 1) eq "~") {
		# nothing to be done - the "system" call for gpg will expand it via shell
		return $setting;
	} elsif (substr($setting, 0, 1) eq "/") {
		# absolute path - this is ok, too
		return $setting;
	} else {
		return $self->{'LIST_NAME'} . '/' . $setting;
	}
}


# == Return the directory of the current list ==

=head2 Determining which list we are currently altering:

   $whichlist = $list->thislist;
   print $list->thislist;

=cut

sub thislist {
	my($self) = shift;
	$self->_seterror(undef);
	return $self->{'LIST_NAME'};
}


# == Set the current mailing list ==

=head2 Changing which list the Mail::Ezmlm::Gpg object points at:
 
   $list->setlist('/home/user/lists/moolist');

=cut

sub setlist {
	my($self, $list) = @_;
	if ($list =~ m/^([\w\d\_\-\.\/]+)$/) {
		$list = $1;
		if (-e "$list/lock") {
			# it is an ezmlm list
			# it is not necessary, that it is an encrypted list
			$self->_seterror(undef);
			return $self->{'LIST_NAME'} = $list;
		} else {
			# not an ezmlm list
			$self->_seterror(-1, "$list does not appear to be a valid list in setlist()");
			return undef;
		}
	} else {
		# invalid characters
		$self->_seterror(-1, "$list contains tainted data in setlist()");
		return undef;
	}
}


# == is the list encrypted? ==

=head2 Checking the state of a list:

To determine, if a list is encrypted or not, call is_encrypted().

	$list->is_encrypted();

=cut

sub is_encrypted {
	my($self) = @_;
	($self->_seterror(-1, 'must setlist() before is_encrypted()') && return 0) unless(defined($self->{'LIST_NAME'}));
	$self->_seterror(undef);
	if (-e "$self->{'LIST_NAME'}/$GPGPY_CONF_FILE") {
		return (0==0);
	} else {
		return (1==0);
	}
}


# == export a key ==

=head2 Export a key:

You may export public keys of the keyring of a list.

The key can be identified by its id or other (unique) patterns (like the
gnupg program).

	$list->export_key($key_id);
	$list->export_key($email_address);

The return value is a string containing the ascii armored key data.

=cut

sub export_key {
	my ($self, $keyid) = @_;
	my $gpg = $self->_get_gpg_object();
	my $gpgoption = "--armor --export $keyid";
	my $gpgcommand = $gpg->gpgbin() . " " . $gpg->gpgopts() . " $gpgoption";
	my $output = `$gpgcommand 2>/dev/null`;
	if ($output) {
		return $output;
	} else {
		return undef;
	}
}


# == import a new key ==

=head2 Import a key:

You can import public or secret keys into the keyring of the list.

The key should be ascii armored.

	$list->import_key($ascii_armored_key_date);

=cut

sub import_key {
	my ($self, $key) = @_;
	my $gpg = $self->_get_gpg_object();
	if ($gpg->addkey($key)) {
		return (0==0);
	} else {
		return (1==0);
	}
}


# == delete a key ==

=head2 Delete a key:

Remove a public key (and the matching secret key if it exists) from the keyring
of the list.

The argument is the id of the key or any other unique pattern.

	$list->delete_key($keyid);

=cut

sub delete_key {
	my ($self, $keyid) = @_;
	my $gpg = $self->_get_gpg_object();
	my $fprint = $self->_get_fingerprint($keyid);
	return (1==0) unless (defined($fprint));
	my $gpgoption = "--delete-secret-and-public-key $fprint";
	my $gpgcommand = $gpg->gpgbin() . " " . $gpg->gpgopts() . " $gpgoption";
	if (system($gpgcommand)) {
		return (1==0);
	} else {
		return (0==0);
	}
}


# == generate new private key ==

=head2 Generate a new key:

	$list->generate_key($name, $comment, $email_address, $keysize, $expire);

Refer to the documentation of gnupg for the format of the arguments.

=cut

sub generate_private_key {
	my ($self, $name, $comment, $email, $keysize, $expire) = @_;
	my $gpg = $self->_get_gpg_object();
	my $gpgoption = "--gen-key";
	my $gpgcommand = $gpg->gpgbin() . " " . $gpg->gpgopts() . " $gpgoption";
	my $pid = open(INPUT, "| $gpgcommand");
	print INPUT "Key-Type: DSA\n";
	print INPUT "Key-Length: 1024\n";
	print INPUT "Subkey-Type: ELG-E\n";
	print INPUT "Subkey-Length: $keysize\n";
	print INPUT "Name-Real: $name\n";
	print INPUT "Name-Comment: $comment\n" if ($comment);
	print INPUT "Name-Email: $email\n";
	print INPUT "Expire-Date: $expire\n";
	return close INPUT;
}


# == get_public_keys ==

=head2 Getting public keys:

Return an array of key hashes each containing the following elements:

=over

=item *
name

=item *
email

=item *
id

=item *
expires

=back

	$list->get_public_keys();
	$list->get_secret_keys();

=cut

sub get_public_keys {
	my ($self) = @_;
	my @keys = $self->_get_keys("pub");
	return @keys;
}


# == get_private_keys ==
# see above for POD (get_public_keys)
sub get_secret_keys {
	my ($self) = @_;
	my @keys = $self->_get_keys("sec");
	return @keys;
}


# == check version of gpg-ezmlm ==
sub check_gpgpy_ezmlm_version {
	my $ret_value = system("'$GPG_EZMLM_BASE/gpg-ezmlm-convert.pl' --version &>/dev/null"); 
	# for now we do not need a specific version of gpg-ezmlm - it just has to
	# know the "--version" argument (available since gpg-ezmlm 0.3.4)
	return ($ret_value == 0);
}


############ some internal functions ##############

# == internal function for creating a gpg object ==
sub _get_gpg_object() {
	my ($self) = @_;
	my $gpg = new Crypt::GPG();
	my $dirname = $self->get_gnupg_dir();
	# fix spaces in filename
	$dirname =~ s/ /\\ /g;
	$gpg->gpgbin($GPG_BIN);
	$gpg->gpgopts("--lock-multiple --no-tty --no-secmem-warning --batch --quiet --homedir $dirname");
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


# == internal function to retrieve the fingerprint of a key ==
sub _get_fingerprint()
{
	my ($self, $key_id) = @_;
	my $gpg = $self->_get_gpg_object();
	$key_id =~ /^([0-9A-Z]*)$/;
	$key_id = $1;
	return undef unless ($key_id);
	my $gpgoption = "--fingerprint $key_id";

	my $gpgcommand = $gpg->gpgbin() . " " . $gpg->gpgopts() . " --with-colons $gpgoption";
	
	my @fingerprints = grep /^fpr:/, `$gpgcommand`;
	if (@fingerprints > 1) {
		warn "[Mail::Ezmlm::Gpg] more than one key matched ($key_id)!";
		return undef;
	}
	return undef if (@fingerprints < 1);
	my $fpr = $fingerprints[0];
	$fpr =~ /^fpr:*([0-9A-Z]*):*$/;
	$fpr = $1;
	return undef unless $1;
	return $1;
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

 Lars Kruse <devel@sumpfralle.de>

=head1 BUGS

 There are no known bugs.

 Please report bugs to the author or use the bug tracking system at
 https://systemausfall.org/trac/ezmlm-web.

=head1 SEE ALSO

 ezmlm(5), ezmlm-make(2), ezmlm-sub(1), 
 ezmlm-unsub(1), ezmlm-list(1), ezmlm-issub(1)

 https://systemausfall.org/toolforge/ezmlm-web/
 http://www.synacklabs.net/projects/crypt-ml/
 http://www.ezmlm.org/
 http://www.qmail.org/

=cut
