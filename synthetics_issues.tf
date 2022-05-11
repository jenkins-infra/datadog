resource "datadog_synthetics_test" "issuesjenkinsio" {
  type = "api"
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

  status = "live"
}

resource "datadog_synthetics_test" "issuesjenkinsciorg" {
  type = "api"
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
    property = "location"
    target   = "https://issues.jenkins.io/status"
  }

  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900
  }
  name    = "issues.jenkins-ci.org"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins-ci.org"]

  status = "live"
}
