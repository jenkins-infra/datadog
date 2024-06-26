resource "datadog_synthetics_test" "javadoc_jenkins_io" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://javadoc.jenkins.io"
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
  name    = "javadoc.jenkins.io"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}

resource "datadog_synthetics_test" "javadoc_jenkinsci_org" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://javadoc.jenkins-ci.org"
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
  name    = "javadoc.jenkins-ci.org"
  message = "Notify @pagerduty"
  tags = [
    "jenkins-ci.org",
    "production"
  ]

  status = "live"
}
