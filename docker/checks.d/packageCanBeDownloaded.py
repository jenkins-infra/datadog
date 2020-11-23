#!/usr/bin/env python3
# Require Python 3.8

from urllib.request import urlopen
from urllib.error import URLError, HTTPError

import xml.etree.ElementTree as ET

from datadog_checks.base.checks import AgentCheck


def get_latest_version(versions):
    '''
        get_latest_version takes a list of Jenkins versions
        then return the latest one.
        It sorts separatelly each Jenkins versions components
        which follow the pattern X.Y.Z where:
            - X.Y is a weekly version
            - X.Y.Z is a stable version
        So we retrieve the latest X component version.
        Then we look for the latest valid Y version considering X.
        Finally we look for the latest Z version considering X.Y
    '''

    results = []
    # for i in range(3) limit the sort to the first 3 components
    for i in range(3):
        solutions = []
        for version in versions:
            values = version.split('.')

            str_results = [str(x) for x in results]

            if (len(results) < len(values) and
                    str_results[0:len(results)] == values[0:len(results)]):
                try:
                    if int(values[i]) not in solutions:
                        solutions.append(int(values[i]))
                except Exception:
                    print("Ignoring version {}".format(values[i]))

        if not solutions:
            break

        results.append(int(sorted(solutions)[-1]))

    str_results = [str(x) for x in results]
    return '.'.join(str_results)


def is_exist(distribution, url):
    '''
        is_exist test if a specific artifact exist on the destination
    '''
    try:
        return_code = urlopen(url).code
        if return_code != 200:
            print('rc should be 200 but is {}'.format(return_code))
        return 1
    except HTTPError as err:
        if err.code == 404:
            print('{} package not found on {}'.format(distribution, url))
        else:
            print('Something went wrong with url {} for {} package: {}'
                  .format(url, distribution, err))
        return 0


class PackageCanBeDownloaded(AgentCheck):
    '''
       PackageCanBeDownloaded  tests that the latest jenkins packages
       can be downloaded
    '''
    metadataUrl = 'https://repo.jenkins-ci.org/releases/org/jenkins-ci/main/jenkins-war/maven-metadata.xml'
    hostname = "get.jenkins.io"

    def get_latest_weekly_version(self):
        '''
            getLatestWeeklyVersion retrieves the latest weekly version
        '''
        try:
            url = self.metadataUrl
            tree = ET.parse(urlopen(url))
            root = tree.getroot()
            return root.find('versioning/latest').text

        except URLError as err:
            print('Something went wrong while retrieving weekly version: {}'
                  .format(err))

    def get_latest_stable_version(self):
        '''
            getLatestStableVersion retrieves the latest stable version
        '''
        try:
            stable_version = []
            url = self.metadataUrl
            tree = ET.parse(urlopen(url))
            root = tree.getroot()

            versions = root.findall('versioning/versions/version')

            for version in versions:
                if len(version.text.split('.')) == 3:
                    stable_version.append(version.text)

            return get_latest_version(stable_version)

        except URLError as err:
            print('Something went wrong while retrieving stable version: {}'
                  .format(err))

    def check(self, instance):
        '''
            check defines the datadog custom check
        '''

        weekly_version = self.get_latest_weekly_version()
        stable_version = self.get_latest_stable_version()
        endpoints = {
            'debian': 'https://{}/debian/jenkins_{}_all.deb'
                      .format(self.hostname, weekly_version),
            'redhat': 'https://{}/redhat/jenkins-{}-1.1.noarch.rpm'
                      .format(self.hostname, weekly_version),
            'opensuse': 'https://{}/opensuse/jenkins-{}-1.2.noarch.rpm'
                      .format(self.hostname, weekly_version),
            'windows': 'https://{}/windows/{}/jenkins.msi'
                      .format(self.hostname, weekly_version),
            'war': 'https://{}/war/{}/jenkins.war'
                      .format(self.hostname, weekly_version),
            'debian-stable': 'https://{}/debian-stable/jenkins_{}_all.deb'
                      .format(self.hostname, stable_version),
            'redhat-stable': 'https://{}/redhat-stable/jenkins-{}-1.1.noarch.rpm'
                      .format(self.hostname, stable_version),
            'windows-stable': 'https://{}/windows-stable/{}/jenkins.msi'
                      .format(self.hostname, stable_version),
            'opensuse-stable': 'https://{}/opensuse-stable/jenkins-{}-1.2.noarch.rpm'
                      .format(self.hostname, stable_version),
            'war-stable': 'https://{}/war-stable/{}/jenkins.war'
                      .format(self.hostname, stable_version),
        }

        metric = 'jenkins.package.available'
        package = instance['package']
        self.warning("PackageAvailable: {}".format(package))
        tags = [
            "package:" + package,
        ]

        if endpoints.__contains__(package):
            self.gauge(metric, is_exist(package, endpoints[package]), tags)
        else:
            self.warning("PackageCanDownload: Package {} is not supported"
                         .format(package))


if __name__ == "__main__":
    '''
        Only there for testing purposes
    '''
    p = PackageCanBeDownloaded
    weekly_version = p.get_latest_weekly_version(p)
    stable_version = p.get_latest_stable_version(p)
    endpoints = {
        'debian': 'https://{}/debian/jenkins_{}_all.deb'
                  .format(p.hostname, weekly_version),
        'redhat': 'https://{}/redhat/jenkins-{}-1.1.noarch.rpm'
                  .format(p.hostname, weekly_version),
        'opensuse': 'https://{}/opensuse/jenkins-{}-1.2.noarch.rpm'
                  .format(p.hostname, weekly_version),
        'war': 'https://{}/war/{}/jenkins.war'
                  .format(p.hostname, weekly_version),
        'windows': 'https://{}/windows/{}/jenkins.msi'
                  .format(p.hostname, weekly_version),
        'debian-stable': 'https://{}/debian-stable/jenkins_{}_all.deb'
                  .format(p.hostname, stable_version),
        'redhat-stable': 'https://{}/redhat-stable/jenkins-{}-1.1.noarch.rpm'
                  .format(p.hostname, stable_version),
        'windows-stable': 'https://{}/windows-stable/{}/jenkins.msi'
                  .format(p.hostname, stable_version),
        'opensuse-stable': 'https://{}/opensuse-stable/jenkins-{}-1.2.noarch.rpm'
                  .format(p.hostname, stable_version),
        'war-stable': 'https://{}/war-stable/{}/jenkins.war'
                  .format(p.hostname, stable_version),
    }

    print("Latest weekly version: {}".format(weekly_version))
    print("Latest stable version: {}".format(stable_version))

    packages = [
        "debian", "debian-stable",
        "redhat", "redhat-stable",
        "opensuse", "opensuse-stable",
        "windows", "windows-stable",
        "war", "war-stable",
    ]

    for package in packages:
        if not is_exist(package, endpoints[package]):
            print("Latest version for package {} unailable from {}"
                  .format(package, endpoints[package]))
        else:
            print("Latest version for package {} available from {}"
                  .format(package, endpoints[package]))
