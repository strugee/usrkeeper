# You should configure usrkeeper.conf for your distribution before
# installing usrkeeper.
CONFFILE=usrkeeper.conf
include $(CONFFILE)

DESTDIR?=
prefix=/usr
bindir=${prefix}/bin
etcdir=/etc
mandir=${prefix}/share/man
vardir=/var
completiondir=${prefix}/share/bash-completion/completions
CP=cp -R
INSTALL=install 
INSTALL_EXE=${INSTALL}
INSTALL_DATA=${INSTALL} -m 0644
PYTHON=python

build: usrkeeper.spec usrkeeper.version
	-$(PYTHON) ./usrkeeper-bzr/__init__.py build || echo "** bzr support not built"
	-$(PYTHON) ./usrkeeper-dnf/usrkeeper.py build || echo "** DNF support not built"

install: usrkeeper.version
	mkdir -p $(DESTDIR)$(etcdir)/usrkeeper/ $(DESTDIR)$(vardir)/cache/usrkeeper/
	$(CP) *.d $(DESTDIR)$(etcdir)/usrkeeper/
	$(INSTALL_DATA) $(CONFFILE) $(DESTDIR)$(etcdir)/usrkeeper/usrkeeper.conf
	mkdir -p $(DESTDIR)$(bindir)
	$(INSTALL_EXE) usrkeeper $(DESTDIR)$(bindir)/usrkeeper
	mkdir -p $(DESTDIR)$(mandir)/man8
	$(INSTALL_DATA) usrkeeper.8 $(DESTDIR)$(mandir)/man8/usrkeeper.8
	mkdir -p $(DESTDIR)$(completiondir)
	$(INSTALL_DATA) bash_completion $(DESTDIR)$(completiondir)/usrkeeper
ifeq ($(HIGHLEVEL_PACKAGE_MANAGER),apt)
	mkdir -p $(DESTDIR)$(etcdir)/apt/apt.conf.d
	$(INSTALL_DATA) apt.conf $(DESTDIR)$(etcdir)/apt/apt.conf.d/05usrkeeper
	mkdir -p $(DESTDIR)$(etcdir)/cruft/filters-unex
	$(INSTALL_DATA) cruft_filter $(DESTDIR)$(etcdir)/cruft/filters-unex/usrkeeper
endif
ifeq ($(LOWLEVEL_PACKAGE_MANAGER),pacman)
	mkdir -p $(DESTDIR)$(prefix)/share/libalpm/hooks
	$(INSTALL_DATA) ./pacman-pre-install.hook $(DESTDIR)$(prefix)/share/libalpm/hooks/05-usrkeeper-pre-install.hook
	$(INSTALL_DATA) ./pacman-post-install.hook $(DESTDIR)$(prefix)/share/libalpm/hooks/95-usrkeeper-post-install.hook
endif
ifeq ($(LOWLEVEL_PACKAGE_MANAGER),pacman-g2)
	mkdir -p $(DESTDIR)$(etcdir)/pacman-g2/hooks
	$(INSTALL_DATA) pacman-g2.hook $(DESTDIR)$(etcdir)/pacman-g2/hooks/usrkeeper
endif
ifeq ($(HIGHLEVEL_PACKAGE_MANAGER),yum)
	mkdir -p $(DESTDIR)$(prefix)/lib/yum-plugins
	$(INSTALL_DATA) yum-usrkeeper.py $(DESTDIR)$(prefix)/lib/yum-plugins/usrkeeper.py
	mkdir -p $(DESTDIR)$(etcdir)/yum/pluginconf.d
	$(INSTALL_DATA) yum-usrkeeper.conf $(DESTDIR)$(etcdir)/yum/pluginconf.d/usrkeeper.conf
endif
ifeq ($(HIGHLEVEL_PACKAGE_MANAGER),dnf)
	-$(PYTHON) ./usrkeeper-dnf/usrkeeper.py install --root=$(DESTDIR) ${PYTHON_INSTALL_OPTS} || echo "** DNF support not installed"
endif
ifeq ($(HIGHLEVEL_PACKAGE_MANAGER),zypper)
	mkdir -p $(DESTDIR)$(prefix)/lib/zypp/plugins/commit
	$(INSTALL) zypper-usrkeeper.py $(DESTDIR)$(prefix)/lib/zypp/plugins/commit/zypper-usrkeeper.py
endif
	-$(PYTHON) ./usrkeeper-bzr/__init__.py install --root=$(DESTDIR) ${PYTHON_INSTALL_OPTS} || echo "** bzr support not installed"
	echo "** installation successful"

clean: usrkeeper.spec usrkeeper.version
	rm -rf build

usrkeeper.spec:
	sed -i~ "s/Version:.*/Version: $$(perl -e '$$_=<>;m/\((.*?)(-.*)?\)/;print $$1;'<debian/changelog)/" usrkeeper.spec
	rm -f usrkeeper.spec~

usrkeeper.version:
	sed -i~ "s/Version:.*/Version: $$(perl -e '$$_=<>;m/\((.*?)(-.*)?\)/;print $$1;' <debian/changelog)\"/" usrkeeper
	rm -f usrkeeper~

.PHONY: usrkeeper.spec usrkeeper.version
