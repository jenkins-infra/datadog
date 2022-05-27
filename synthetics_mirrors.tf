resource "datadog_synthetics_test" "mirrors_jenkins_io" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://mirrors.jenkins.io/debian/jenkins_2.251_all.deb?mirrorlist"
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
  name    = "mirrors.jenkins.io"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}

resource "datadog_synthetics_test" "mirrors_jenkins_io_enforced_https" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "http://mirrors.jenkins.io"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "308"
  }
  assertion {
    type     = "header"
    property = "location"
    operator = "is"
    target   = "https://mirrors.jenkins.io"
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900
  }
  name    = "mirrors.jenkins.io-enforced-http"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}

resource "datadog_synthetics_test" "mirrors_jenkinsci_org" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://mirrors.jenkins-ci.org/debian/jenkins_2.251_all.deb?mirrorlist"
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
  name    = "mirrors.jenkins-ci.org"
  message = "Notify @pagerduty"
  tags = [
    "jenkins-ci.org",
    "production"
  ]

  status = "live"
}

resource "datadog_synthetics_test" "mirrors_jenkinsci_org_enforced_https" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "http://mirrors.jenkins-ci.org"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "308"
  }
  assertion {
    type     = "header"
    property = "location"
    operator = "is"
    target   = "https://mirrors.jenkins-ci.org"
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900
  }
  name    = "mirrors.jenkins-ci.org-enforced-http"
  message = "Notify @pagerduty"
  tags = [
    "jenkins-ci.org",
    "production"
  ]

  status = "live"
}
