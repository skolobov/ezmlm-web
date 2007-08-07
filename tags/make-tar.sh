#!/bin/sh

set -eu

PRJ_ROOT=$(dirname $(cd "$(dirname $0)"; pwd))
PREFIX=ezmlm-web

[ $# -lt 1 -o $# -gt 2 ] && echo "Syntax: `basename $0` VERSION" && echo && exit 1
REL_SRC_DIR=${PREFIX}-${1}
[ $# -eq 2 ] && REL_SRC_DIR=$2
SRC_DIR=$(cd "$(pwd)/$REL_SRC_DIR"; pwd)
[ ! -d "$SRC_DIR" ] && echo "the directory '$REL_SRC_DIR' does not exist!" && exit 2

TAR_FILE=$PRJ_ROOT/tags/packages/${PREFIX}-${1}.tar.gz

TMP_DIR=/tmp/${PREFIX}-${1}
[ -e "$TMP_DIR" ] && rm -rf "$TMP_DIR"

svn export "$SRC_DIR" "$TMP_DIR"

# update language files
"$TMP_DIR/scripts/update_language_files.py"

tar czf "$PRJ_ROOT/tags/packages/${PREFIX}-${1}.tar.gz" -C "$(dirname $TMP_DIR)" --exclude-from="$SRC_DIR/package.exclude" --owner=0 --group=0 "$(basename $TMP_DIR)"
rm -rf "$TMP_DIR"

