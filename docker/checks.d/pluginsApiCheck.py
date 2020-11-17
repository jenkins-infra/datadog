#!/usr/bin/env python3

# Return pluginsite elasticsearch index age in hour
#

from urllib.request import urlopen

import json
from datetime import datetime

# the following try/except block will make the custom check
# compatible with any Agent version
try:
    # first, try to import the base class from new versions of the Agent...
    from datadog_checks.base import AgentCheck
except ImportError:
    # ...if the above failed, the check is running in Agent version < 6.6.0
    from checks import AgentCheck


class PluginsApiCheck(AgentCheck):
    def check(self, instance):
        metric = 'plugins.index.age'
        site = instance['site']
        tag = "site:" + site
        self.gauge(metric, self.get_index_age(site), tags=[tag])

    def get_index_age(self, site):
        url = "https://{0}/api/health/elasticsearch".format(site)
        health_status = urlopen(url).read()
        index_creation = datetime.strptime(json.loads(health_status)['createdAt'], '%Y-%m-%dT%H:%M:%S')
        age = datetime.today() - index_creation
        return age.seconds / 3600
