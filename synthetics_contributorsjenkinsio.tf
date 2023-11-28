resource "datadog_synthetics_test" "contributors_jenkins_io" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://contributors.jenkins.io"
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
  name    = "contributors.jenkins.io"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}
