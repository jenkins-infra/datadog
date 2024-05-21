resource "datadog_synthetics_test" "incrementalsjenkinsio" {
  type = "api"
  request_definition {
    method = "GET"
    # https://github.com/jenkins-infra/incrementals-publisher/blob/a754f43d44be5f6b09e2ac3f9e5600e04175936b/index.js#L62
    url = "https://incrementals.jenkins.io/readiness"
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
  name    = "incrementals.jenkins.io"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins.io"]

  status = "live"
}
