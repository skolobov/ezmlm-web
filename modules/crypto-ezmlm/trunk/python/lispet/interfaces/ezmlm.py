#!/usr/bin/env python2.4
#
# This file is part of lispet - an encryption filter for different
# mailing list manager.
#
# Copyright 02007-02008 Sense.Lab e.V. <info@senselab.org>
#
#
# lispet is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# lispet is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with the CryptoBox; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#



import sys
import os
import re
# the following modules are imported later
#import subprocess

# check if the subprocess module is available (python >= 2.4)
try:
	import subprocess
except ImportError:
	sys.stderr.write("Failed to import the python module 'subprocess'! "
			. "It requires python2.4 or higher.\n")
	sys.exit(1)


############### some default settings ##################

## we will finally deliver via the original qmail-queue
if os.environ.has_key("QMAILQUEUE"):
	QMAILQUEUE_BIN = os.environ["QMAILQUEUE"]
else:
	QMAILQUEUE_BIN = '/var/qmail/bin/qmail-queue'



def write_to_qmailqueue:
		## use tmpfile as input for qmail-queue
		## we have to complicate things a little bit, as qmail-queue expects input
		## at file handle 1 - this is usually stdout
		# TODO: use something like StringIO instead
		tmpfile = os.tmpfile()
		tmpfile.write('F%s\0T%s\0\0' % (sender, recipient))
		tmpfile.seek(0)
		## execute the original qmail-queue
		proc = subprocess.Popen(
			shell = False,
			stdin = subprocess.PIPE,
			stdout = tmpfile.fileno(),
			env = os.environ,
			args = [ QMAILQUEUE_BIN ] )
		proc.stdin.write(mail.as_string())
		## tmpfile is deleted automatically after closing
		tmpfile.close()
		proc.stdin.close()
		proc.wait()
		## exit immediately, if qmail-queue failed once
		if proc.returncode != 0:
			sys.exit(proc.returncode)



#################### input/output stuff ###################

def internal_error(message=None, exitcode=81):
	if message:
		sys.stderr.write(message + "\n")
	sys.exit(exitcode)


def process_input_and_output(handler):
	"""Read mail content and the envelopement information from fd1 and fd2

	see 'main qmail-queue' for details
	"""
	in_mail = os.fdopen(0, "r")
	in_envelope = os.fdopen(1, "rb")
	## try to read mail and 
	try:
		mail_text = in_mail.read()
		envelope = in_envelope.read()
	except IOError:
		## report "Unable to read the message or envelope." (see 'man qmail-queue')
		sys.exit(54)
	## see 'man qmail-queue' for details of the envelope format
	envelope_addresses = re.match(u'F(.+?)\0((?:T[^\0]+?\0)+)\0$', envelope)
	if not envelope_addresses or (len(envelope_addresses.groups()) != 2):
		## report "Envelope format error." (see 'man qmail-queue')
		sys.exit(91)
	## the first match is the sender address
	envelope_sender = envelope_addresses.groups()[0]
	## the second match is the list of all recipients
	## each preceded by "T" and followed by "\0"
	envelope_recipients = envelope_addresses.groups()[1].split("\0")
	## remove leading "T" and skip empty values
	envelope_recipients = [ e[1:] for e in envelope_recipients if e ]
	for recipient in envelope_recipients:
		handler.process_mail(envelope_sender, recipient, mail_text)


def check_for_errors():
	errors = False
	## check the original qmail-queue binary
	if not os.access(QMAILQUEUE_BIN, os.X_OK):
		sys.stderr.write("Could not find executable qmail-queue: %s\n" % QMAILQUEUE_BIN)
		errors = True
	## check the existence of the pyme module
	try:
		import pyme
	except ImportError:
		sys.stderr.write("Failed to import python-pyme!\n")
		errors = True
	## check if the subprocess module is available (python >= 2.4)
	try:
		import subprocess
	except ImportError:
		sys.stderr.write("Failed to import the python module 'subprocess'! It requires python2.4.\n")
		errors = True
	return errors == False


if __name__ == '__main__':
	# reduce priority
	os.nice(5)
	if not check_for_errors():
		internal_error()
	if len(sys.argv) == 1:
		## we were only supposed to run the self-tests - exiting successfully
		sys.exit(0)
	## we expect exactly one parameter - the mailinglist directory
	if len(sys.argv) != 2:
		internal_error("More than one parameter (the mailinglist directory) given!")
	## print some help if it was requested
	if sys.argv[0] == '--help':
		sys.stderr.write("Syntax: %s [MAILINGLIST_DIRECTORY]\n\n" % \
				os.path.basename(sys.argv[0]))
		sys.stderr.write("If you omit the MAILINGLIST_DIRECTORY, " \
				+ "then only some self-tests are done.\n\n")
		sys.exit(0)
	## retrieve the mailing list directory by reading the dotqmail file
	list_dir = sys.argv[1]
	## does the mailinglist directory exist?
	if not os.access(list_dir, os.X_OK):
		internal_error("Could not access the mailinglist directory: %s" % list_dir)
	## reencrypt the mail for each recipient
	mail_handler = MailEncryption(list_dir)
	process_input_and_output(mail_handler)

