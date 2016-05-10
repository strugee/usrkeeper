#!/usr/bin/env python

import errno
import subprocess
import zypp_plugin
import os

def _call_usrkeeper(install_arg):
    # zypper interprets the plugin's stdout as described in
    # http://doc.opensuse.org/projects/libzypp/HEAD/zypp-plugins.html so it's
    # important that we don't write anything to it. We therefore redirect
    # usrkeeper's stdout to the plugin's stderr. Since zypper writes the
    # stderr of plugins to its log file, usrkeeper's stdout will go there as
    # well.

    subprocess.call(['usrkeeper', install_arg], stdout=2)


class UsrkeeperPlugin(zypp_plugin.Plugin):
    def PLUGINBEGIN(self, headers, body):
        _call_usrkeeper('pre-install')
        self.ack()

    def PLUGINEND(self, headers, body):
        try:
            _call_usrkeeper('post-install')
        except OSError as e:
            # if usrkeeper was just removed, executing it will fail with
            # ENOENT
            if e.errno != errno.ENOENT:
                # reraise so that we don't hide other errors than usrkeeper
                # not existing
                raise
        self.ack()


os.environ["LANG"] = "C"
plugin = UsrkeeperPlugin()
plugin.main()
