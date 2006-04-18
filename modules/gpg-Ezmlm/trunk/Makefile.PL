# $Id$

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
	'CONFIGURE'	=> \&set_paths,
	'NAME'		=> 'Mail::Ezmlm::Gpg',
	'VERSION_FROM'	=> 'Gpg.pm', # finds $VERSION
	'DISTNAME'		=> 'Mail-Ezmlm-Gpg',
	'PREREQ_PM'		=> { 'Mail::Ezmlm' => 0.05 },
	'dist'		=> { COMPRESS => 'gzip', SUFFIX => 'gz' },
	'clean'		=> { FILES => 'gpg-ezmlmtmp' }
);

use strict;

sub set_paths {
	my ($gpg_path, $GPG_EZMLM_BASE);

	# special case to handle the FreeBSD ports system
	if ($ENV{BSD_BATCH_INSTALL}) {
		print STDERR "\$BSD_BATCH_INSTALL is set in your environment, assuming port defaults\n";
		return {};
	}

	print "\nTo work correctly, I need to know, where your gnupg program is located.\n\n";

	*prompt = \&ExtUtils::MakeMaker::prompt;
   
	# guess default
	$gpg_path = '/usr/local/bin/gpg'
		unless (-e "$gpg_path");
	$gpg_path = '/usr/bin/gpg'
		unless (-e "$gpg_path");
	$gpg_path = '/bin/gpg'
		unless (-e "$gpg_path");
	$gpg_path = '/usr/local/bin/gpg2'
		unless (-e "$gpg_path");
	$gpg_path = '/usr/bin/gpg2'
		unless (-e "$gpg_path");
	$gpg_path = '/bin/gpg2'
		unless (-e "$gpg_path");
	# return to default, if nothing can be found
	$gpg_path = '/usr/bin/gpg'
		unless (-e "$gpg_path");

	foreach (1..10) {
		$gpg_path = prompt('Location of your gnupg program?', "$gpg_path");
		last if (-e "$gpg_path");
		print "I can't find '$gpg_path'. Please try again\n";
	}
	unless (-e "$gpg_path") {
		$gpg_path = '/usr/bin';
		print STDERR "Warning: No correct input after 10 attempts. Using default ($gpg_path) ...\n";
	}


	print "\n\nI also need to know, where to find your gpg-ezmlm binaries.\n\n";
	# guess the location of the gpg-ezmlm program files
	$GPG_EZMLM_BASE = '/usr/local/bin/ezmlm'
		unless (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl");
	$GPG_EZMLM_BASE = '/usr/local/bin/ezmlm-idx'
		unless (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl");
	$GPG_EZMLM_BASE = '/usr/local/bin'
		unless (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl");
	$GPG_EZMLM_BASE = '/usr/bin/ezmlm'
		unless (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl");
	$GPG_EZMLM_BASE = '/usr/bin/ezmlm-idx'
		unless (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl");
	$GPG_EZMLM_BASE = '/usr/bin'
		unless (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl");

	foreach (1..10) {
		$GPG_EZMLM_BASE = prompt('Location of your gpg-ezmlm binaries?', "$GPG_EZMLM_BASE");
		last if (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl");
		print "I can't find '$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl'. Please try again\n";
	}
	unless (-e "$GPG_EZMLM_BASE/gpg-ezmlm-manage.pl") {
		$GPG_EZMLM_BASE = '/usr/bin';
		print STDERR "Warning: No correct input after 10 attempts. Using default ($GPG_EZMLM_BASE) ...\n";
	}


	print << 'EOM';

Thank you. I will use this information to configure Mail::Ezmlm::Gpg for you

EOM

	# Back up file
	open(GPG, '<Gpg.pm') or die "Unable to open Gpg.pm for read: $!";
	open(TMP, ">Gpg.pm.tmp.$$") or die "Unable to create temp file: $!";
	while(<GPG>) { print TMP; }
	close TMP; close GPG;

	# Do variable substitution
	open(GPG, '>Gpg.pm') or die "Unable to open Gpg.pm for write: $!";
	open(TMP, "<Gpg.pm.tmp.$$") or die "Unable to read temp file: $!";
	while(<TMP>) {
		s{^\$GPG_BIN\s*=\s*['"].+?['"]\s*;\s*(#.*|)$}{\$GPG_BIN = '$gpg_path';	# Autoinserted by Makefile.PL};
		s{^\$GPG_EZMLM_BASE\s*=\s*['"].+?['"]\s*;\s*(#.*|)$}{\$GPG_EZMLM_BASE = '$GPG_EZMLM_BASE';	# Autoinserted by Makefile.PL};
		print GPG;
	}
	close TMP; close GPG;

	unlink "Gpg.pm.tmp.$$";

	return {};

}
