resource "datadog_synthetics_test" "cijenkinsio" {
  type = "browser"
  request_definition {
    method = "GET"
    url    = "https://ci.jenkins.io"
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
  name    = "ci.jenkins.io"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins.io"]

  status = "live"

  device_ids = [
    "laptop_large",
    "tablet",
    "mobile_small"

  ]
}
