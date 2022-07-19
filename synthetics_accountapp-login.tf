resource "datadog_synthetics_test" "accountapp-login" {
  type = "api"
  request_definition {
    method = "POST"
    url    = "https://accounts.jenkins.io/doLogin"
    body   = "userid=datadog_monitoring&password=${datadog_jenkinsuser_password}"
  }
  request_headers {
    Content-Type   = "application/x-www-form-urlencoded"
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
  name    = "login account.jenkins.io"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}
