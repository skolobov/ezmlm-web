#!/bin/sh

set -eu

[ $# -ne 1 ] && echo "Syntax: `basename $0` VERSION" && echo && exit 1
[ ! -d "ezmlm-web-${1}" ] && echo "the directory 'ezmlm-web-${1}' does not exist!" && exit 2

TMP_DIR=/tmp/ezmlm-web-${1}
[ -e "$TMP_DIR" ] && rm -rf "$TMP_DIR"

svn export "ezmlm-web-${1}" "$TMP_DIR"
tar czf ezmlm-web-${1}.tar.gz -C "$(dirname $TMP_DIR)" --owner=0 --group=0 "$(basename $TMP_DIR)"
rm -rf "$TMP_DIR"
