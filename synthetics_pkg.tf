resource "datadog_synthetics_test" "pkg_jenkins_io" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://pkg.origin.jenkins.io"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "301"
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

  status = "live"
}

resource "datadog_synthetics_test" "pkg_jenkinsci_org" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://pkg.jenkins-ci.org"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "301"
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

  status = "live"
}
