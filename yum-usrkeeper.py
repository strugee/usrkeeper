#
# 
# author: jtang@tchpc.tcd.ie
# 
# this plugin is based on the hello world example 
# from http://yum.baseurl.org/wiki/WritingYumPlugins
# 
# to install, copy this file to /usr/lib/yum-plugins/usrkeeper.py
# and then create /etc/yum/pluginconf.d/usrkeeper.conf with the contents
# below.
# 
#  /etc/yum/pluginconf.d/usrkeeper.conf:
#   [main]
#   enabled=1
#

import os
from glob import fnmatch

import yum
from yum.plugins import PluginYumExit, TYPE_CORE

requires_api_version = '2.1'
plugin_type = (TYPE_CORE,)

def pretrans_hook(conduit):
    conduit.info(2, 'usrkeeper: pre transaction commit')
    servicecmd = conduit.confString('main', 'servicecmd', '/usr/bin/usrkeeper')
    command = '%s %s > /dev/null' % (servicecmd, " pre-install")
    ret = os.system(command)
    if ret != 0:
        raise PluginYumExit('usrkeeper returned %d' % (ret >> 8))

def posttrans_hook(conduit):
    conduit.info(2, 'usrkeeper: post transaction commit')
    if os.path.exists('/usr/bin/usrkeeper'):
	    servicecmd = conduit.confString('main', 'servicecmd', '/usr/bin/usrkeeper')
	    command = '%s %s > /dev/null' % (servicecmd, "post-install")
	    os.system(command)
