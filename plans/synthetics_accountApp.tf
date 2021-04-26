resource "datadog_synthetics_test" "accountsApp" {
  type = "browser"
  request {
    method = "GET"
    url    = "https://accounts.jenkins.io"
  }
  assertions = [
    {
      type     = "statusCode"
      operator = "is"
      target   = "200"
    }
  ]
  locations = ["aws:eu-central-1"]
  options {
    tick_every = 900
  }
  name    = "account.jenkins.io"
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
