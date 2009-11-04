#!/usr/bin/env python2.4
#
# This file is part of lispet - an encryption filter for the
# ezmlm-idx mailinglist manager.
#
# Copyright 02007 Sense.Lab e.V. <info@senselab.org>
#
# This script decrypts an incoming mail and encrypts it for each recipient
# separately. Afterwards it calls qmail-queue for each recipient.
# It is meant as a wrapper around qmail-queue. See 'man qmail-queue' for
# details of the qmail-queue interface.
#
# Syntax:
#  lispet-encrypt [MAILINGLIST_DIRECTORY]
# 
# If no MAILINGLIST_DIRECTORY is given, then it will only run some self-tests.
#
# Environment settings:
#  - QMAILQUEUE should contain the path of the qmail-queue program (or a
#    substitute - e.g. for spam filtering) - otherwise the default location
#    /var/qmail/bin/qmail-queue is used
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


# TODO:
#	implement 'sign_messages'
#	implement 'hide_subject'


import sys
import os
import re
#the following modules are imported later
# import configobj


# try to load the module configobj
try:
	import configobj
except ImportError:
	sys.stderr.write("Failed to import the required module 'configobj'. "
			. "Please check if it is installed!\n")
	sys.exit(1)


############### some default settings ##################


## default settings - the setting keys must always be lower case!
DEFAULT_SETTINGS = {
		"plain_without_key": False,
		"sign_messages": False,
		"gnupg_dir": ".gnupg"
	}

	def read_config(self):
		"""Read the config file.

		If a value is not defined in the config file, then the default value
		is used.
		Any line that does not really look like a config setting is ignored.
		Any unknown configuration settings are ignored, too.
		"""
		result = DEFAULT_SETTINGS
		## retrieve the absolute path of the configuration file
		## by default it is relative to the mailinglist's directory
		if os.path.isabs(CONF_FILE):
			conf_file = CONF_FILE
		else:
			conf_file = os.path.join(self.list_dir, CONF_FILE)
		if not os.access(conf_file, os.R_OK):
			internal_error("Could not read gpgpy-ezmlm config file: %s" % conf_file)
		## read all lines of the configuration file
		all_lines = [ e.strip() for e in file(conf_file).readlines() ]
		for line in all_lines:
			## ignore empty lines, comments and lines without "="
			if (not line) or e.startswith("#") or (e.find("=") == -1):
				continue
			key, value = line.split("=", 1)
			## turn everything to lower case and remove surrounding whitespace
			key, value = (key.strip().lower(), value.strip())
			if (len(value) > 1) and \
					((value.startswith('"') and value.endswith('"')) \
					or (value.startswith("'") and value.endswith("'"))):
				value = value[1:-1]
			## ignore empty values or keys
			if not key or not value:
				continue
			## check boolean values
			if key in ['plain_without_key', 'sign_messages']:
				if value.lower() == 'no':
					result[key] = False
				elif value.lower() == 'yes':
					result[key] = True
				else:
					continue
			## process the key directory
			elif key == 'gnupg_dir':
				result[key] = value
			## unknown setting - ignore
			else:
				continue
		if result["gnupg_dir"].startswith('~'):
			result["gnupg_dir"] = os.path.expanduser(result["gnupg_dir"])
		elif not os.path.isabs(result["gnupg_dir"]):
			result["gnupg_dir"] = os.path.abspath(os.path.join(
					self.list_dir, result["gnupg_dir"]))
		return result

