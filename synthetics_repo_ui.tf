resource "datadog_synthetics_test" "repojenkinsciorgui" {
  type = "browser"
  request_definition {
    method = "GET"
    url    = "https://repo.jenkins-ci.org/ui"
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
  name    = "repo.jenkins-ci.org (UI)"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins-ci.org"]

  status = "live"

  device_ids = [
    "laptop_large",
    "tablet",
    "mobile_small"
  ]
}
