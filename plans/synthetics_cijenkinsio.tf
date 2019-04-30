resource "datadog_synthetics_test" "cijenkinsio" {
  type = "browser"
  request {
    method = "GET"
    url = "https://ci.jenkins.io"
  }
  assertions = [
    {
      type = "statusCode"
      operator = "is"
      target = "200"
    }
  ]
  locations = [ "aws:eu-central-1" ]
  options {
    tick_every = 900
  }
  name = "ci.jenkins.io"
  message = "Notify @pagerduty"
  tags = ["production", "jenkins.io"]

  status = "live"

  device_ids = [
    "laptop_large",
    "tablet",
    "mobile_small"

  ]
}
