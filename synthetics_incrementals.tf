resource "datadog_synthetics_test" "incrementalsjenkinsio" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://incrementals.jenkins.io/"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "404"
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900
  }
  name    = "incrementals.jenkins.io"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins.io"]

  status = "live"
}
