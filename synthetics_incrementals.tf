resource "datadog_synthetics_test" "incrementalsjenkinsio" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://incrementals.jenkins.io/"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    # TODO: improve healthcheck on the incremental publisher app
    ## Checking for an HTTP/404 covers some errors (all HTTP/5xx such as no pod running) but not all cases
    ## Still better than no monitoring at all
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
