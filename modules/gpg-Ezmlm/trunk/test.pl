# ===========================================================================
# test.pl - version 0.02 - 25/09/2000
# $Id: test.pl,v 1.5 2005/03/05 14:08:30 guy Exp $
# Test suite for Mail::Ezmlm
#
# Copyright (C) 02006, Lars Kruse, All Rights Reserved.
# Please send bug reports and comments to devel@sumpfralle.de
#
# This program is subject to the restrictions set out in the copyright
# agreement that can be found in the Gpg.pm file in this distribution
#
# ==========================================================================
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'


use Test;
BEGIN { plan tests => 5 }

print "Trying to load the Mail::Ezmlm module: ";
eval { require Mail::Ezmlm; return 1;};
ok($@,'');
croak() if $@;  # If Mail::Ezmlm didn't load... bail hard now

print "Trying to load the Mail::Ezmlm::Gpg module: ";
eval { require Mail::Ezmlm::Gpg; return 1;};
ok($@,'');
croak() if $@;	# Mail::Ezmlm::Gpg is essential ...


######################### End of black magic.

use Cwd;
$list = new Mail::Ezmlm;

# create a temp directory if necessary
$TMP = cwd() . '/gpg-ezmlmtmp';
mkdir $TMP, 0755 unless (-d $TMP);

print 'Checking list creation with Mail::Ezmlm: ';
$test1 = $list->make(-name=>"ezmlm-test1-$$", 
            -qmail=>"$TMP/.qmail-ezmlm-test1-$$", 
            -dir=>"$TMP/ezmlm-test1-$$"); 

ok($test1 eq "$TMP/ezmlm-test1-$$");

# backup the created to list to check clean conversion later
system("cp", "-a", $list->{'LIST_NAME'}, $list->{'LIST_NAME'} . ".backup");


print 'Testing list conversion from plaintext to encryption: ';
$gpg_list = new Mail::Ezmlm::Gpg($list->{'LIST_NAME'});
ok($gpg_list->convert_to_encrypted() && $gpg_list->is_gpg());


print 'Testing list conversion from encryption to plaintext: ';
ok($gpg_list->convert_to_plaintext() && !($gpg_list->is_gpg()));


print 'Testing if back and forth conversion was clean: ';
ok(system("diff -qr --exclude=.gnupg --exclude=tmp --exclude=text '" . $list->{'LIST_NAME'} . "' '" . $list->{'LIST_NAME'} . '.backup' . "' 2>/dev/null") == 0);


print 'Testing getconfig: ';
$gpg_list->convert_to_encrypted();
ok($gpg_list->getconfig());


print 'Testing update: ';
# toggle a setting and check, if it works
$gpg_list->update((requireSigs => 1));
my %list_config = $gpg_list->getconfig();
my $update_failed = ($list_config{requireSigs} == 1)? 0 : 1;
unless ($update_failed) {
	$gpg_list->update((requireSigs => 0));
	%list_config = $gpg_list->getconfig();
	$update_failed = ($list_config{requireSigs} == 0)? 0 : 1;
}
ok(!$update_failed);


print 'Testing key generation: ';
ok($gpg_list->generate_private_key("Name", "Comment", "mail@addr.ess", 1024, 0));


print 'Testing key retrieval: ';
my @pub_keys = $gpg_list->get_public_keys();
my @sec_keys = $gpg_list->get_secret_keys();
ok((@pub_keys == 1) && (@sec_keys == 1));


print 'Testing key export: ';
my $keyid = $pub_keys[0]{id};
ok($gpg_list->export_key($keyid));


print 'Testing key deletion: ';
$gpg_list->delete_key($keyid);
@pub_keys = $gpg_list->get_public_keys();
@sec_keys = $gpg_list->get_secret_keys();
ok((@pub_keys == 0) && (@sec_keys == 0));

