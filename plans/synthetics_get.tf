resource "datadog_synthetics_test" "get_jenkins_io" {
  type = "api"
  request {
    method = "GET"
    url = "https://get.jenkins.io/debian/jenkins_2.251_all.deb?mirrorlist"
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
  name = "get.jenkins.io"
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
