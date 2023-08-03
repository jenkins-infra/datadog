resource "datadog_synthetics_test" "jenkinsio" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://www.jenkins.io"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900

    retry {
      count    = 2
      interval = 300
    }
  }
  name    = "jenkins.io"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins.io"]

  status = "live"

}

resource "datadog_synthetics_test" "jenkinsio_www_redirection" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "http://jenkins.io"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "308" # Permanent redirect from Nginx ingress eventually cached by Fastly
  }
  assertion {
    type     = "header"
    property = "location"
    operator = "is"
    target   = "https://jenkins.io"
  }
  options_list {
    tick_every = 900
  }
  locations = ["aws:eu-central-1"]
  name    = "jenkins.io-www-redirection"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}

resource "datadog_synthetics_test" "jenkinsio_enforced_https" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "http://jenkins.io"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "308" # Permanent redirect from Nginx ingress eventually cached by Fastly
  }
  assertion {
    type     = "header"
    property = "location"
    operator = "is"
    target   = "https://jenkins.io"
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900
  }
  name    = "jenkins.io-enforced-http"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}
