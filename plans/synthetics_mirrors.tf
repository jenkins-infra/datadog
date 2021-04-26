resource "datadog_synthetics_test" "mirrors_jenkins_io" {
  type = "browser"
  request {
    method = "GET"
    url    = "http://mirrors.jenkins.io"
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
  name    = "mirrors.jenkins.io"
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

resource "datadog_synthetics_test" "mirrors_jenkinsci_org" {
  type = "browser"
  request {
    method = "GET"
    url    = "https://mirrors.jenkins-ci.org"
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
  name    = "mirrors.jenkins-ci.org"
  message = "Notify @pagerduty"
  tags = [
    "jenkins-ci.org",
    "production"
  ]

  device_ids = [
    "laptop_large",
    "tablet",
    "mobile_small"

  ]

  status = "live"
}
