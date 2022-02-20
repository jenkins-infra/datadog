resource "datadog_synthetics_test" "pkg_jenkins_io" {
  type = "browser"
  request_definition {
    method = "GET"
    url    = "https://pkg.origin.jenkins.io"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900
  }
  name    = "pkg.origin.jenkins.io"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  device_ids = [
    "laptop_large",
    "tablet",
    "mobile_small"

  ]

  status = "live"
}

## Do not monitor https
resource "datadog_synthetics_test" "pkg_jenkinsci_org" {
  type = "browser"
  request_definition {
    method = "GET"
    url    = "http://pkg.jenkins-ci.org"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900
  }
  name    = "pkg.jenkins-ci.org"
  message = "Notify @pagerduty"
  tags = [
    "jenkins-ci.org",
    "production"
  ]

  device_ids = [
    "laptop_large",
    "tablet",
    "mobile_small"

  ]

  status = "live"
}
