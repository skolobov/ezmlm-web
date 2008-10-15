#!/bin/sh

set -eu

DEBIAN_URL=https://svn.systemausfall.org/svn/ezmlm-web/debian

PRJ_ROOT=$(dirname $(cd "$(dirname $0)"; pwd))
#ARCHITECTURES="i386 ia64 alpha amd64 armeb arm hppa m32r m68k mips mipsel powerpc ppc64 s390 s390x sh3 sh3eb sh4 sh4eb sparc"
ARCHITECTURES="i386"
PREFIX=ezmlm-web


get_debian_version()
# compare the given version with the one from debian/changelog
{
	head -1 "$SRC_DIR/debian/changelog" | cut -f 2 -d "(" | cut -f 1 -d "-"
}

set_package_version()
# set the version attribute in ezmlm-web.cgi
{
	sed -i "s/^\$VERSION = '.*$/\$VERSION = '$1';/" "$SRC_DIR/ezmlm-web.cgi"
}

[ $# -lt 1 -o $# -gt 2 ] && echo "Syntax: `basename $0` VERSION {PATH}" && echo && exit 1
REL_SRC_DIR=${PREFIX}-${1}
[ $# -eq 2 ] && REL_SRC_DIR=$2
SRC_DIR=$(cd "$(pwd)/$REL_SRC_DIR"; pwd)
[ ! -d "$SRC_DIR" ] && echo "the directory '$REL_SRC_DIR' does not exist!" && exit 2

deb_version=$(get_debian_version)
if test "$1" = "$deb_version"
  then	true
  else	echo "The version number you specified ($1) was not equal to the current debian changelog version ($deb_version)!"
	echo "Run 'debchange -i' to create a new changelog entry."
	echo
	exit 3
 fi

set_package_version "$1"

# create the tar file
"$(dirname $0)/make-tar.sh" "$@"

TAR_FILE=$PRJ_ROOT/tags/packages/${PREFIX}-${1}.tar.gz
DEB_DIR=$(dirname "$TAR_FILE")/debian

TMP_DIR=/tmp/builddir-$PREFIX-$$

mkdir -p "$TMP_DIR"
cd "$TMP_DIR"
NEW_TAR_FILE=${PREFIX}_${1}.orig.tar.gz
cp "$TAR_FILE" "$NEW_TAR_FILE"
tar xzf "$TAR_FILE"
cd "$PREFIX-$1"
svn export $DEBIAN_URL" debian

# problem: the orig tarball is being rebuild again and again - so it is always different
for arch in $ARCHITECTURES
  do	dpkg-buildpackage -tc -us -uc -rfakeroot -a$arch
  #do	debuild -us -uc -a$arch
 done

mkdir -p "$DEB_DIR"
for a in "$TMP_DIR"/${PREFIX}*
  do	test -f "$a" && mv "$a" "$DEB_DIR/"
 done

