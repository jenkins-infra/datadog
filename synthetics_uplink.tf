resource "datadog_synthetics_test" "uplink_jenkins_io" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://uplink.jenkins.io"
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
  name    = "uplink.jenkins.io"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}
