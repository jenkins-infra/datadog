resource "datadog_synthetics_test" "issuesjenkinsio" {
  type = "browser"
  request_definition {
    method = "GET"
    url    = "https://issues.jenkins.io/status"
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
  name    = "issues.jenkins.io"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins.io"]

  device_ids = [
    "laptop_large",
    "tablet",
    "mobile_small"
  ]

  status = "live"
}

resource "datadog_synthetics_test" "issuesjenkinsciorg" {
  type = "browser"
  request_definition {
    method = "GET"
    url    = "https://issues.jenkins-ci.org/status"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "301"
  }
  assertion {
    type     = "header"
    operator = "is"
    target   = "location: https://issues.jenkins.io/"
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900
  }
  name    = "issues.jenkins-ci.org"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins-ci.org"]

  device_ids = [
    "laptop_large",
    "tablet",
    "mobile_small"
  ]

  status = "live"
}
