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
