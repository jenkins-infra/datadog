resource "datadog_synthetics_test" "wikijenkinsio" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://wiki.jenkins.io/status"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "205"
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900
  }
  name    = "wiki.jenkins.io"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins.io"]

  status = "live"

  device_ids = [
    "laptop_large",
    "tablet",
    "mobile_small"
  ]
}

resource "datadog_synthetics_test" "wikijenkins_ciorg" {
  type = "browser"
  request_definition {
    method = "GET"
    url    = "https://wiki.jenkins-ci.org/status"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "301"
  }
  assertion {
    type     = "header"
    operator = "is"
    target   = "location: https://wiki.jenkins.io/status"

  }
  locations = ["aws:eu-central-1"]
  # Can't work at the moment according datadog message
  # Synthetics is only available for the Datadog US site.
  # locations = [
  #   "aws:eu-central-1",
  #   "aws:eu-central-2",
  #   "aws:us-east-2",
  #   "aws:us-west-2",
  #   "aws:ap-northeast-1",
  #   "aws:ap-southeast-2"
  # ]
  options_list {
    tick_every = 900
  }
  name    = "wiki.jenkins-ci.org"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins-ci.org"]

  device_ids = [
    "laptop_large",
    "tablet",
    "mobile_small"
  ]

  status = "live"
}
