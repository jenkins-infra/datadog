#!/usr/bin/env python

import json

try:
    # For Python 3.0 and later
    from urllib.request import urlopen
except ImportError:
    # Fall back to Python 2's urllib2
    from urllib2 import urlopen

url = 'https://api.github.com/repos/DataDog/datadog-agent/releases/latest'
data = json.load(urlopen(url))

print(data['name'])
