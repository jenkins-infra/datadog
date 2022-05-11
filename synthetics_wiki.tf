resource "datadog_synthetics_test" "wikijenkinsio" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://wiki.jenkins.io/status"
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
  name    = "wiki.jenkins.io"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins.io"]

  status = "live"

}

resource "datadog_synthetics_test" "wikijenkins_ciorg" {
  type = "api"
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
    property = "location"
    target   = "https://wiki.jenkins.io:443/status"
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

  status = "live"
}
