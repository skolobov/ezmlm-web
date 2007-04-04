
PREFIX ?= /usr/local
QMAILQUEUE ?= /var/qmail/bin/qmail-queue

# man pages are compressed by default
COMPR_BIN ?= gzip
COMPR_EXT ?= .gz

# we need to replace some paths within the scripts and man pages
SED_BIN ?= sed
SED_PARAMS = s\#/usr/local/\#${PREFIX}/\#g; s\#/var/qmail/bin/qmail-queue\#${QMAILQUEUE}\#g

SCRIPTS = gpgpy-ezmlm-manage gpgpy-ezmlm-queue gpgpy-ezmlm-encrypt
MANPAGES1 = gpgpy-ezmlm-manage.1 gpgpy-ezmlm-queue.1 gpgpy-ezmlm-encrypt.1
MANPAGES5 = gpgpy-ezmlm.5 conf-gpgpy.5

.PHONY = prepare install test clean help

prepare:
	@mkdir -p target
	@echo "Adjusting installation paths for scripts ..."
	@for script_file in ${SCRIPTS} ;\
	  do	"${SED_BIN}" "${SED_PARAMS}" "bin/$$script_file" >"target/$$script_file" ;\
	 done
	@echo "Adjusting installation paths for manpages ..."
	@for man_file in ${MANPAGES1} ${MANPAGES5};\
	  do	"${SED_BIN}" "${SED_PARAMS}" "man/$$man_file" | gzip >"target/$$man_file${COMPR_EXT}" ;\
	 done


install: prepare
	@echo "Installing scripts ..."
	@mkdir -p "${PREFIX}/bin/"
	@for file in ${SCRIPTS} ;\
	  do	install "target/$$file" "${PREFIX}/bin/" ;\
	 done
	@echo "Installing man pages ..."
	@mkdir -p "${PREFIX}/share/man/man1/"
	@for file in ${MANPAGES1} ;\
	  do	install "target/$$file${COMPR_EXT}" "${PREFIX}/share/man/man1/" ;\
	 done
	@mkdir -p "${PREFIX}/share/man/man5/"
	@for file in ${MANPAGES5} ;\
	  do	install "target/$$file${COMPR_EXT}" "${PREFIX}/share/man/man5/" ;\
	 done

test: install
	@echo "Testing gpgpy-ezmlm-manage ..."
	@"${PREFIX}/bin/gpgpy-ezmlm-manage" >/dev/null && echo "   => OK"
	@echo "Testing gpgpy-ezmlm-queue ..."
	@"${PREFIX}/bin/gpgpy-ezmlm-queue" test >/dev/null && echo "   => OK"

clean:
	@echo "Removing temporary files ..."
	@for file in ${SCRIPTS} ;\
	  do	rm -f "target/$$file" ;\
	 done
	@for file in ${MANPAGES1} ${MANPAGES5} ;\
	  do	rm -f "target/$$file${COMPR_EXT}" ;\
	 done
	-@rmdir target 2>/dev/null


help:
	@echo "Valid targets are:"
	@echo "	prepare	- adjust paths"
	@echo "	install	- install scripts and man pages"
	@echo "	test	- check if the installation was successful"
	@echo "	clean	- remove temporary files"
	@echo
	@echo "The following environment settings are used:"
	@echo "	PREFIX		- the installation path prefix - defaults to /usr/local"
	@echo "	QMAILQUEUE	- location of your installed qmail-queue binary"
	@echo

