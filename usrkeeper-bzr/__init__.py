#
# Bazaar plugin that runs usrkeeper pre-commit when necessary

"""Runs usrkeeper pre-commit when necessary."""

from bzrlib.errors import BzrError
import os

def usrkeeper_startcommit_hook(tree):
    abspath = getattr(tree, "abspath", None)
    if abspath is None or not os.path.exists(abspath(".usrkeeper")):
        # Only run the commit hook when this is an usrkeeper branch
        return
    import subprocess
    ret = subprocess.call(["usrkeeper", "pre-commit", abspath(".")])
    if ret != 0:
        raise BzrError("usrkeeper pre-commit failed")

try:
    from bzrlib.hooks import install_lazy_named_hook
except ImportError:
    from bzrlib.mutabletree import MutableTree
    MutableTree.hooks.install_named_hook('start_commit',
        usrkeeper_startcommit_hook, 'usrkeeper')
else:
    install_lazy_named_hook(
        "bzrlib.mutabletree", "MutableTree.hooks",
        'start_commit', usrkeeper_startcommit_hook, 'usrkeeper')

if __name__ == "__main__":
    from distutils.core import setup
    setup(name="bzr-usrkeeper", 
          packages=["bzrlib.plugins.usrkeeper"],
          package_dir={"bzrlib.plugins.usrkeeper":"usrkeeper-bzr"})
