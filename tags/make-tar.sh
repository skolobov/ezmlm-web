#!/bin/sh

set -eu

PREFIX=ezmlm-web

[ $# -ne 1 ] && echo "Syntax: `basename $0` VERSION" && echo && exit 1
[ ! -d "${PREFIX}-${1}" ] && echo "the directory '${PREFIX}-${1}' does not exist!" && exit 2

TMP_DIR=/tmp/${PREFIX}-${1}
[ -e "$TMP_DIR" ] && rm -rf "$TMP_DIR"

svn export "${PREFIX}-${1}" "$TMP_DIR"
tar czf "packages/${PREFIX}-${1}.tar.gz" -C "$(dirname $TMP_DIR)" --exclude debian --owner=0 --group=0 "$(basename $TMP_DIR)"
rm -rf "$TMP_DIR"
