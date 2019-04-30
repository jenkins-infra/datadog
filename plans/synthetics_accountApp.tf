resource "datadog_synthetics_test" "accounts.jenkins.io" {
  type = "browser"
  request {
    method = "GET"
    url = "https://accounts.jenkins.io"
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
  name = "Test account.jenkins.io"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}
