resource "datadog_synthetics_test" "archives_jenkins_io" {
  type = "browser"
  request {
    method = "GET"
    url = "http://archives.jenkins.io"
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
  name = "archives.jenkins.io"
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

resource "datadog_synthetics_test" "archives_jenkinsci_org" {
  type = "browser"
  request {
    method = "GET"
    url = "http://archives.jenkins-ci.org"
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
  name = "archives.jenkins-ci.org"
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
