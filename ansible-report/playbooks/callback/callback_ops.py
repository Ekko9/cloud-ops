#!/usr/bin/env python
# coding=utf-8

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

import sys
reload(sys) 
sys.setdefaultencoding('utf-8')

# from ansible.plugins.callback import CallbackBase

class CallbackModule(object):
    CALLBACK_VERSION = 2.0
    CALLBACK_TYPE = 'stdout'
    CALLBACK_NAME = 'ops'
    CALLBACK_NEEDS_WHITELIST = False

    def runner_on_ok(self, host, res):
        if 'stdout' in res.keys():
            print(res['stdout'] + '\n')

    def runner_on_failed(self, host, res, ignore_errors=False):
        pass
       
    def runner_on_skipped(self, host, item=None):
         pass

    def runner_on_unreachable(self, host, res):
         pass

    def v2_runner_on_ok(self, result):
        host = result._host.get_name()
        self.runner_on_ok(host, result._result)

    def v2_runner_on_failed(self, result, ignore_errors=False):
        host = result._host.get_name()
        self.runner_on_failed(host, result._result, ignore_errors)

    def v2_runner_on_skipped(self, result):
        if C.DISPLAY_SKIPPED_HOSTS:
            host = result._host.get_name()
            self.runner_on_skipped(host, self._get_item_label(getattr(result._result, 'results', {})))

    def v2_runner_on_unreachable(self, result):
        host = result._host.get_name()
        self.runner_on_unreachable(host, result._result)
