resource "datadog_synthetics_test" "plugin_health_scoring" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://plugin-health.jenkins.io"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "302"
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900
  }
  name    = "plugin-health.jenkins.io"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}

resource "datadog_synthetics_test" "plugin_health_scoring" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://plugin-health.jenkins.io/probes"
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
  name    = "plugin-health.jenkins.io-probes"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}
