resource "datadog_synthetics_test" "mirrors_jenkins_io" {
  type = "browser"
  request_definition {
    method = "GET"
    url    = "http://mirrors.jenkins.io"
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
  name    = "mirrors.jenkins.io"
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

resource "datadog_synthetics_test" "mirrors_jenkinsci_org" {
  type = "browser"
  request_definition {
    method = "GET"
    url    = "http://mirrors.jenkins-ci.org"
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
  name    = "mirrors.jenkins-ci.org"
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
