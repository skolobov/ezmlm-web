#!/bin/sh

set -eu

[ $# -ne 1 ] && echo "Syntax: `basename $0` VERSION" && echo && exit 1
[ ! -d "ezmlm-web-${1}" ] && echo "the directory 'ezmlm-web-${1}' does not exist!" && exit 2

tar czf ezmlm-web-${1}.tar.gz --owner=0 --group=0 --exclude=.svn ezmlm-web-${1}
