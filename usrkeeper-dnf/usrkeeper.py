# usrkeeper.py, support usrkeeper for dnf
#
# Copyright (C) 2014 Peter Listiak
# https://github.com/plistiak/dnf-usrkeeper
#
# Later modifications by Petr Spacek:
# Distutils code below was copied from usrkeeper-bzr distributed with v1.15
#

from dnfpluginscore import logger

import os
import dnf


class Usrkeeper(dnf.Plugin):

    name = 'usrkeeper'

    def _out(self, msg):
        logger.debug('Usrkeeper plugin: %s', msg)

    def resolved(self):
        self._out('pre transaction commit')
        command = '%s %s' % ('usrkeeper', " pre-install")
        ret = os.system(command)
        if ret != 0:
            raise dnf.exceptions.Error('usrkeeper returned %d' % (ret >> 8))

    def transaction(self):
        self._out('post transaction commit')
        command = '%s %s > /dev/null' % ('usrkeeper', "post-install")
        os.system(command)

if __name__ == "__main__":
    from distutils.core import setup
    setup(name="dnf-usrkeeper",
          packages=["dnf-plugins"],
          package_dir={"dnf-plugins":"usrkeeper-dnf"})
