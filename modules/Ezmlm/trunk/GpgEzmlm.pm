# ===========================================================================
# GpgEzmlm.pm
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

package Mail::Ezmlm::GpgEzmlm;

use strict;
use warnings;
use diagnostics;
use vars qw($GPG_EZMLM_BASE $VERSION @ISA @EXPORT @EXPORT_OK);
use Carp;

use Mail::Ezmlm;

# this package inherits object methods from Mail::Ezmlm
@ISA = qw(Mail::Ezmlm);

$VERSION = '0.1';

require 5.005;

=head1 NAME

Mail::Ezmlm::GpgEzmlm - Object Methods for encrypted Ezmlm Mailing Lists

=head1 SYNOPSIS

 use Mail::Ezmlm::GpgEzmlm;
 $list = new Mail::Ezmlm::GpgEzmlm(DIRNAME);

The rest is a bit complicated for a Synopsis, see the description.

=head1 DESCRIPTION

Mail::Ezmlm::GpgEzmlm is a Perl module that is designed to provide an object
interface to encrypted mailing lists based upon gpg-ezmlm.
See the gpg-ezmlm web page (http://www.synacklabs.net/projects/crypt-ml/) for
details about this software.

The Mail::Ezmlm::GpgEzmlm class is inherited from the Mail::Ezmlm class.

=cut

# == Begin site dependant variables ==
$GPG_EZMLM_BASE = '/usr/bin';	# Autoinserted by Makefile.PL

# == clean up the path for taint checking ==
local $ENV{PATH};
# the following lines were taken from "man perlrun"
$ENV{PATH} = $GPG_EZMLM_BASE;
$ENV{SHELL} = '/bin/sh' if exists $ENV{SHELL};
delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};




# == Initialiser - Returns a reference to the object ==

=head2 Setting up a new Mail::Ezmlm::GpgEzmlm object:

   use Mail::Ezmlm::GpgEzmlm;
   $list = new Mail::Ezmlm::GpgEzmlm('/home/user/lists/moolist');

new() returns undefined if an error occoured.

Use this function to access an existing encrypted mailing list.

=cut

sub new { 
	my ($class, $list_dir) = @_;
	# call the previous initialization function
	my $self = $class->SUPER::new($list_dir);
	bless $self, ref $class || $class || 'Mail::Ezmlm::GpgEzmlm';
	# define the available (supported) options for gpg-ezmlm ==
	@{$self->{SUPPORTED_OPTIONS}} = (
			"KeyDir",
			"RequireSub",
			"RequireSigs",
			"NoKeyNoCrypt",
			"SignMessages",
			"EncryptToAll",
			"VerifiedKeyReq",
			"AllowKeySubmission");
	# check if the mailing is encrypted
	if (_is_encrypted($list_dir)) {
		return $self;
	} else {
		return undef;
	}
}

# == convert an existing list to gpg-ezmlm ==

=head2 Converting a plaintext mailing list to an encrypted list:

You need to have a normal list before you can convert it into an encrypted list.
You can create plaintext mailing list with Mail::Ezmlm.

   $encrypted_list->Mail::Ezmlm::GpgEzmlm->convert_to_encrypted('/lists/foo');

Use this function to convert a plaintext list into an encrypted mailing list.
The function returns a Mail::Ezmlm::GpgEzmlm object if it was successful.
Otherwise it returns undef.

=cut

sub convert_to_encrypted {
	my $class = shift;
	my $list_dir = shift;
	my ($dot_loc, $backup_dir, $dot_prefix);

	# untaint "list_dir"
	$list_dir =~ m/^([\w\d\_\-\.\@ \/]+)$/;
	if (defined($1)) {
		$list_dir = $1;
	} else {
		warn "List directory contains invalid characters!";
		return undef;
	}

	# retrieve location of dotqmail-files
	$dot_loc = _get_dotqmail_location($list_dir);

	# untaint "dot_loc"
	$dot_loc =~ m/^([\w\d\_\-\.\@ \/]+)$/;
	if (defined($1)) {
		$dot_loc = $1;
	} else {
		warn "Directory name of dotqmail files contains invalid characters!";
		return undef;
	}

	# the backup directory will contain the old config file and the dotqmails
	$backup_dir = $list_dir . '/gpg-ezmlm.bak';
	if ((! -e $backup_dir) && (!mkdir($backup_dir))) {
		warn "failed to create gpg-ezmlm conversion backup dir: $backup_dir";
		return undef;
	}

	# the "dot_prefix" is the basename of the main dotqmail file
	# (e.g. '.qmail-list-foo')
	$dot_loc =~ m/\/([^\/]+)$/;
	if (defined($1)) {
		$dot_prefix = $1;
	} else {
		warn 'invalid location of dotqmail file: ' . $dot_loc;
		return undef;
	}

	# check the input
	unless (defined($list_dir)) {
		warn 'must define directory in convert_to_encrypted()';
		return undef;
	}

	# does the list directory exist?
	unless (-d $list_dir) {
		warn 'directory does not exist: ' . $list_dir;
		return undef;
	}

	# try to access the list as an encryted one (this should fail)
	if (Mail::Ezmlm::GpgEzmlm->new($list_dir)) {
		warn 'list is already encrypted: ' . $list_dir;
		return undef;
	}

	unless (defined($dot_loc) && ($dot_loc ne '') && (-e $dot_loc)) {
		warn 'dotqmail files not found: ' . $dot_loc;
		return undef;
	}


	# here starts the real conversion - the code is based on
	# "gpg-ezmlm-convert.pl" - see http://www.synacklabs.net/projects/crypt-ml/

	# move the base dotqmail file
	if (open(DOT_NEW, ">$backup_dir/$dot_prefix.new")) {
		if (open(DOT_ORIG, "<$dot_loc")) {
			while (<DOT_ORIG>) {
				my $line = $_;
				print DOT_NEW ($line =~ /ezmlm-send\s+(\S+)/)
						? "\|$GPG_EZMLM_BASE/gpg-ezmlm-send.pl $1\n"
						: $line;
			}
			close DOT_ORIG;
		} else {
			warn "failed to open base dotqmail file: $dot_loc";
			return undef;
		}
		close DOT_NEW;
	} else {
		warn "failed to create new base dotqmail file: "
				. "$backup_dir/$dot_prefix.new";
		return undef;
	}

	# move the "-default" dotqmail file
	if (open(DEFAULT_NEW, ">$backup_dir/$dot_prefix-default.new")) {
		if (open(DEFAULT_ORIG, "<$dot_loc-default")) {
			while (<DEFAULT_ORIG>) {
				my $line = $_;
				print DEFAULT_NEW ($line =~ /ezmlm-manage\s+(\S+)/)
						? "\|$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl $1\n"
						: $line;
			}
			close DEFAULT_ORIG;
		} else {
			warn "failed to open default dotqmail file: $dot_loc-default";
			return undef;
		}
		close DEFAULT_NEW;
	} else {
		warn "failed to create new default dotqmail file: "
				. "$backup_dir/$dot_prefix-default.new";
		return undef;
	}

	# create the new config file
	if (open(CONFIG_NEW, ">$backup_dir/config.new")) {
		# just create the empty file (default)
		close CONFIG_NEW;
	} else {
		warn "failed to create new config file: $backup_dir/config.new";
		return undef;
	}

	# create the (empty) gnupg keyring directory - this enables the keyring
	# management interface
	unless (mkdir("$list_dir/.gnupg", 0700)) {
		warn "failed to create the gnupg keyring directory: $!";
		return undef;
	}


	# move the original config file (if it exists) to the backup directory
	if ((-e "$list_dir/config") 
			&& (!rename("$list_dir/config", "$backup_dir/config"))) {
		warn "failed to backup the original config file "
				. "'$list_dir/config' to '$backup_dir/config': $!";
		return undef;
	}
	# replace the config file with the new empty one
	unless (rename("$backup_dir/config.new", "$list_dir/config")) {
		warn "failed to move the new config file '$backup_dir/config.new'"
				. " to '$list_dir/config': $!";
		return undef;
	}

	# move the original files to the backup and the new files back
	unless ((rename($dot_loc, "$backup_dir/$dot_prefix"))
			&& (rename("$backup_dir/$dot_prefix.new", $dot_loc))
			&& (rename("$dot_loc-default", "$backup_dir/$dot_prefix-default"))
			&& (rename("$backup_dir/$dot_prefix-default.new",
					"$dot_loc-default"))) {
		warn "failed to move dotqmail files for gpg-ezmlm: $!";
		return undef;
	}

	return $class->new($list_dir);
}

# == convert an encrypted list back to plaintext ==

=head2 Converting an encryted mailing list to a plaintext list:

   $list->convert_to_plaintext();

This function returns undef in case of errors. Otherwise the Mail::Ezmlm
object of the plaintext mailing list is returned.

=cut

sub convert_to_plaintext {
	my $self = shift;
	my ($dot_loc, $list_dir);

	$list_dir = $self->thislist();
	# check if a directory was given
	unless (defined($list_dir)) {
		$self->_seterror(-1, 'must define directory in convert_to_plaintext()');
		return undef;
	}
	# the list directory must exist
	unless (-d $list_dir) {
		$self->_seterror(-1, 'directory does not exist: ' . $list_dir);
		return undef;
	}
	# check if the current object is still encrypted by opening it again
	if (Mail::Ezmlm::GpgEzmlm->new($list_dir)) {
		$self->_seterror(-1, 'list is not encrypted: ' . $list_dir);
		return undef;
	}

	# retrieve location of dotqmail-files
	$dot_loc = _get_dotqmail_location($list_dir);

	# the "dotqmail" location must be valid
	unless (defined($dot_loc) && ($dot_loc ne '') && (-e $dot_loc)) {
		$self->_seterror(-1, 'dotqmail files not found: ' . $dot_loc);
		return undef;
	}

	# TODO: implement the custom backward conversion
	if (system("$GPG_EZMLM_BASE/gpg-ezmlm-convert.pl", "--quiet", "--revert", $list_dir, $dot_loc) != 0) {
		$self->_seterror($?, "failed to undo list encryption: " . $list_dir);
		return undef;
	}

	$self->_seterror(undef);
	$self = $self->SUPER->new($list_dir);
	return $self;
}

# == Update the current list ==

=head2 Updating the configuration of the current list:

   $list->update({ 'allowKeySubmission' => 1 });

=cut

sub update {
	my @params = @_;
	my $self = shift(@params);
	my (%switches, %ok_switches, $one_key, @delete_switches);

	if (scalar @params > 1) {
		%switches = @params;
	} else {
		my $plaintext_switches = shift(@params);
		# only do the "default" configuration of an ezmlm list
		return $self->SUPER::update($plaintext_switches);
	}

	# we continue with the encryption settings
	   
	# check for important files: 'config'
	unless (_is_encrypted($self->thislist())) {
		$self->_seterror(-1, "Update failed: '" . $self->thislist()
				. "' does not appear to be a valid list");
		return undef;
	}

	@delete_switches = ();
	# check if all supplied settings are supported
	# btw we change the case (upper/lower) of the setting to the default one
	foreach $one_key (keys %switches) {
		my $ok_key;
		foreach $ok_key (@{$self->{SUPPORTED_OPTIONS}}) {
			# check the key case-insensitively
			if ($ok_key =~ /^$one_key$/i) {
				$ok_switches{$ok_key} = $switches{$one_key};
				push @delete_switches, $one_key;
			}
		}
	}
	# remove all keys, that were accepted above
	# we could not do it before, since this could cause issues with the current
	# "foreach" looping through the hash
	foreach $one_key (@delete_switches) {
		delete $switches{$one_key};
	}

	# %switches should be empty now
	if (%switches) {
		foreach $one_key (keys %switches) {
			warn "unsupported setting: $one_key";
		}
	}

	my $errorstring;
	my $config_file_old = $self->thislist() . "/config";
	my $config_file_new = $self->thislist() . "/config.new";
	if (open(CONFIG_OLD, "<$config_file_old")) { 
		if (open(CONFIG_NEW, ">$config_file_new")) { 
			my ($in_line, $one_opt, $one_val, $new_setting);
			while (<CONFIG_OLD>) {
				$in_line = $_;
				if (%ok_switches) {
					my $found = 0;
					while (($one_opt, $one_val) = each(%ok_switches)) {
						# is this the right line (maybe commented out)?
						if ($in_line =~ m/^#?\w*$one_opt/i) {
							print CONFIG_NEW "$one_opt ";
							print CONFIG_NEW ($one_val)? "yes" : "no";
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
				print CONFIG_NEW "\n$one_opt ";
				print CONFIG_NEW ($one_val)? "yes" : "no";
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
	my ($self) = @_;
	my (%options, $list_dir);

	# return the "normal" list configuration when asked for a string
	return $self->SUPER::getconfig() unless (wantarray);

	# continue with retrieving the encryption configuration

	# define defaults
	$options{KeyDir} = '';
	$options{SignMessages} = 1;
	$options{NoKeyNoCrypt} = 0;
	$options{AllowKeySubmission} = 1;
	$options{EncryptToAll} = 0;
	$options{VerifiedKeyReq} = 0;
	$options{RequireSub} = 0;
	$options{RequireSigs} = 0;


	# Read the config file
	$list_dir = $self->thislist();
	if (open(CONFIG, "<$list_dir/config")) { 
		# 'config' contains the authorative information
		while(<CONFIG>) {
			if (/^(\w+)\s(.*)$/) {
				my $optname = $1;
				my $optvalue = $2;
				my $one_opt;
				foreach $one_opt (@{$self->{SUPPORTED_OPTIONS}}) {
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
		$self->_seterror(-1, 'unable to read configuration file in getconfig()');
		return undef;
	}

	$self->_seterror(undef);
	return %options;
}


# ********** internal functions ****************

# return the location of the dotqmail files
sub _get_dotqmail_location {
	my $list_dir = shift;
	my ($plain_list, $dot_loc);

	$plain_list = Mail::Ezmlm->new($list_dir);
	if ($plain_list) {
		if (-r "$list_dir/dot") {
			$dot_loc = $plain_list->getpart("dot");
			chomp($dot_loc);
		} elsif (-r "$list_dir/config") {
			# the "config" file was used before ezmlm-idx v5
			$dot_loc = $1 if ($plain_list->getpart("config") =~ m/^T:(.*)$/);
		} else {
			warn 'list configuration file not found: ' . $list_dir;
			$dot_loc = undef;
		}
	} else {
		# return undef for invalid list directories
		$dot_loc = undef;
	}
	return $dot_loc;
}


# return true if the given directory contains a gpg-ezmlm mailing list
sub _is_encrypted {
	my $list_dir = shift;
	my ($result, $plain_list);
	
	# by default we assume, that the list is not encrypted
	$result = 0;

	if (-e "$list_dir/lock") {
		# it is a valid ezmlm-idx mailing list
		$plain_list = Mail::Ezmlm->new($list_dir);
		if ($plain_list) {
			if (-e "$list_dir/config") {
				my $content = $plain_list->getpart("config");
				$content = '' unless defined($content);
				# return false if we encounter the usual ezmlm-idx-v0.4-header
				if ($content =~ /^F:/m) {
					# this is a plaintext ezmlm-idx v0.4 mailing list
					# this is a valid case - no warning necessary
				} else {
					# this is a gpg-ezmlm mailing list
					$result = 1;
				}
			} else {
				# gpg-ezmlm needs a "config" file - thus the list seems to be plain
				# this is a valid case - no warning necessary
			}
		} else {
			# failed to create a plaintext mailing list object
			warn "failed to create Mail::Ezmlm object for: " . $list_dir;
		}
	} else {
		warn "Directory does not appear to contain a valid list: " . $list_dir;
	}

	return $result;
}


# == check version of gpg-ezmlm ==
sub check_gpg_ezmlm_version {
	my $ret_value = system("'$GPG_EZMLM_BASE/gpg-ezmlm-convert.pl' --version &>/dev/null"); 
	# for now we do not need a specific version of gpg-ezmlm - it just has to
	# know the "--version" argument (available since gpg-ezmlm 0.3.4)
	return ($ret_value == 0);
}

# == check if gpg-ezmlm is installed ==
sub is_available {
	# the existence of the gpg-ezmlm script is sufficient for now
	return -e "$GPG_EZMLM_BASE/gpg-ezmlm-convert.pl";
}

############ some internal functions ##############

# == return an error message if appropriate ==
sub errmsg {
	my ($self) = @_;
	return $self->{'ERRMSG'};
}

sub errno {
	my ($self) = @_;
	return $self->{'ERRNO'};
}


# == Internal function to set the error to return ==
sub _seterror {
	my ($self, $no, $mesg) = @_;

	if (defined($no) && $no) {
		if ($no < 0) {
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

1;

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
