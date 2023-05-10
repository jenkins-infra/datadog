resource "datadog_synthetics_test" "jenkinsio" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://www.jenkins.io"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900

    retry {
      count    = 2
      interval = 300
    }
  }
  name    = "jenkins.io"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins.io"]

  status = "live"

}
