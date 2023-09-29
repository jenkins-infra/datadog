resource "datadog_synthetics_test" "ratingjenkinsio" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://rating.jenkins.io/rate/result.php"
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
  name    = "rating.jenkins.io"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins.io"]

  status = "live"
}
