#!/usr/bin/env python3

import urllib2
import xml.etree.ElementTree as ET

try:
    # first, try to import the base class from old versions of the Agent...
    from checks import AgentCheck
except ImportError:
    # ...if the above failed, the check is running in Agent version 6 or later
    from datadog_checks.checks import AgentCheck


class PackageCanBeDownloaded(AgentCheck):
    metadataUrl = 'https://repo.jenkins-ci.org/releases/org/jenkins-ci/main/jenkins-war/maven-metadata.xml'

    def getLatestWeeklyVersion(self):
        try:
            url = self.metadataUrl
            tree = ET.parse(urllib2.urlopen(url))
            root = tree.getroot()
            return root.find('versioning/latest').text

        except urllib2.URLError, e:
            print 'Something went wrong while retrieving weekly version: {}'.format(e)

    def getLatestStableVersion(self):
        try:
            stable_version = []
            url = self.metadataUrl
            tree = ET.parse(urllib2.urlopen(url))
            root = tree.getroot()

            versions = root.findall('versioning/versions/version')

            for version in versions:
                if len(version.text.split('.')) == 3:
                    stable_version.append(version.text)

            return stable_version[-1]

        except urllib2.URLError, e:
            print 'Something went wrong while retrieving stable version: {}'.format(e)

    def isExist(self, distribution, url):
        try:
            rc = urllib2.urlopen(url).code
            if rc != 200:
                print 'rc should be 200 but is {}'.format(rc)
            print "{} package published on {}".format(distribution, url)
            return 1
        except urllib2.URLError, e:
            if e.code == 404:
                print '{} package not found on {}'.format(distribution, url)
            else:
                print 'Something went wrong with url {} for {} package: {}'.format(url, distribution, e)
            return 0

    def check(self, instance):

        weeklyVersion = self.getLatestWeeklyVersion()
        stableVersion = self.getLatestStableVersion()
        endpoints = {
            'debian': 'https://pkg.jenkins.io/debian/binary/jenkins_{}_all.deb'.format(weeklyVersion),
            'redhat': 'https://pkg.jenkins.io/redhat/jenkins-{}-1.1.noarch.rpm'.format(weeklyVersion),
            'opensuse': 'https://pkg.jenkins.io/opensuse/jenkins-{}-1.2.noarch.rpm'.format(weeklyVersion),
            'osx': 'http://mirrors.jenkins.io/osx/jenkins-{}.pkg'.format(weeklyVersion),
            'windows': 'http://mirrors.jenkins.io/windows/jenkins-{}.zip'.format(weeklyVersion),
            'debian-stable': 'https://pkg.jenkins.io/debian-stable/binary/jenkins_{}_all.deb'.format(stableVersion),
            'redhat-stable': 'https://pkg.jenkins.io/redhat-stable/jenkins-{}-1.1.noarch.rpm'.format(stableVersion),
            'opensuse-stable': 'https://pkg.jenkins.io/opensuse-stable/jenkins-{}-1.2.noarch.rpm'.format(stableVersion),
            'osx-stable': 'http://mirrors.jenkins.io/osx-stable/jenkins-{}.pkg'.format(stableVersion),
            'windows-stable': 'http://mirrors.jenkins.io/windows-stable/jenkins-{}.zip'.format(stableVersion)
        }

        metric = 'jenkins.package.can_download'
        package = instance['package']
        self.warning("PackageCanBeDownloaded: {}".format(package))
        tags = [
            "package:" + package,
        ]

        if endpoints.has_key(package):
            self.gauge(metric, self.isExist(package, endpoints[package]), tags)
        else:
            self.warning("PackageCanDownload: Package {} is not supported".format(package))
