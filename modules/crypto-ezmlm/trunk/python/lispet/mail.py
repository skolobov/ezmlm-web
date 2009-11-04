#!/usr/bin/env python
#
# This file is part of lispet - an encryption filter for the different
# mailinglist manager.
#
# Copyright 02007-2008 Sense.Lab e.V. <info@senselab.org>
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


# TODO:
#	implement 'sign_messages'
#	implement 'hide_subject'


import sys
import os
import email
# the following modules are imported later
#import pyme
#import subprocess


## try to import the pyme module
try:
	import pyme
except ImportError:
	sys.stderr.write("Failed to import python-pyme!\n")
	sys.exit(1)
## check if the subprocess module is available (python >= 2.4)
try:
	import subprocess
except ImportError:
	sys.stderr.write("Failed to import the python module 'subprocess'! "
			. "It requires python2.4 or higher.\n")
	sys.exit(1)

#################### some strings ######################


## put this warning into a mail instead of the encrypted content, in case
## the key of the recipient is missing
NOKEY_WARNING = "No valid encryption key found!"


## in case of 'cannot decrypt' errors
DECRYPT_ERROR = "Failed to decrypt the mail that was sent to the mailinglist. Please check the configuration of the mailinglist. Maybe the sender used an invalid encryption key?"


################ the encryption handler ################

class MailEncryption:

	def __init__(self, list_dir):
		self.list_dir = os.path.abspath(list_dir)
		## does the list directory exist?
		if not os.access(self.list_dir, os.X_OK):
			internal_error("Could not access mailinglist directory: %s" \
					% self.list_dir)
		## read the config file
		self.config = self.read_config()
		## does the gnupg directory exist?
		if not os.access(self.config["gnupg_dir"], os.X_OK):
			internal_error("Could not access gnupg directory: %s" \
					% self.config["gnupg_dir"])
		## set GPGHOME environment - this should be used by pyme
		os.environ["GNUPGHOME"] = self.config["gnupg_dir"]
		## we _must_ import pyme after configuring the GNUPGHOME setting
		import pyme.core
		self.pyme = pyme
		self.context = self.pyme.core.Context()
		self.context.set_armor(1)
	

	def get_valid_keys(self, pattern=""):
		for key in self.context.op_keylist_all(pattern, 0):
			if key.can_encrypt != 0:
				yield key


	def encrypt_to_keys(self, plain, keylist):
		plaindata = self.pyme.core.Data(plain)
		cipher = self.pyme.core.Data(plain)
		self.context.op_encrypt(keylist, 1, plaindata, cipher)
		cipher.seek(0, 0)
		return cipher.read()


	def reencrypt_mail(self, mail, keys):
		if mail.is_multipart():
			payloads = mail.get_payload()
			index = 0
			while index < len(payloads):
				if self.is_encrypted(payloads[index].get_payload()):
					decrypted_part = email.message_from_string(
							self.decrypt_block(payloads[index].get_payload()))
					if keys:
						payloads[index].set_payload(self.encrypt_to_keys(
								decrypted_part.as_string(), keys))
					else:
						if self.config["plain_without_key"]:
							payloads[index].set_payload(decrypted_part.as_string())
						else:
							payloads[index].set_payload(NOKEY_WARNING)
				index += 1
		else:
			if self.is_encrypted(mail.get_payload()):
				if keys:
					mail.set_payload(self.encrypt_to_keys(
							self.decrypt_block(mail.get_payload()), keys))
				else:
					if self.config["plain_without_key"]:
						mail.set_payload(self.decrypt_block(mail.get_payload()))
					else:
						mail.set_payload(NOKEY_WARNING)
					


	def is_encrypted(self, text):
		# TODO: check for base64 encoded mails!
		return text.find("-----BEGIN PGP MESSAGE-----") != -1


	def decrypt_block(self, text):
		cipher = self.pyme.core.Data(text)
		plain = self.pyme.core.Data()
		try:
			self.context.op_decrypt(cipher, plain)
		except self.pyme.errors.GPGMEError:
			## decryption failed - we do not do anything
			plain = self.pyme.core.Data(DECRYPT_ERROR)
		plain.seek(0, 0)
		# this function should write to a stream
		return plain.read()


	def process_mail(self, sender, recipient, mail_text):
		"""Decrypt the mail and encrypt it again for the specified recipient
		"""
		mail = email.message_from_string(mail_text)
		keys = self.get_valid_keys(recipient)
		## reencrypt the whole mail for the specific recipient
		self.reencrypt_mail(mail, keys)
		## use tmpfile as input for qmail-queue
		## we have to complicate things a little bit, as qmail-queue expects input
		## at file handle 1 - this is usually stdout
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

