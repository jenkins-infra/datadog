resource "datadog_synthetics_test" "wikijenkinsio" {
  type = "browser"
  request {
    method = "GET"
    url = "https://wiki.jenkins.io/status"
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
  name = "Test wiki.jenkins.io"
  message = "Notify @pagerduty"
  tags = ["production", "jenkins.io"]

  status = "live"
}

resource "datadog_synthetics_test" "wikijenkins_ciorg" {
  type = "browser"
  request {
    method = "GET"
    url = "https://wiki.jenkins-ci.org/status"
  }
  assertions = [
    {
      type = "statusCode"
      operator = "is"
      target = "301"
    },
    {
      type = "header"
      operator = "is"
      target = "location: https://wiki.jenkins.io/"
      
    } 
  ]
  locations = [ "aws:eu-central-1" ]
  options {
    tick_every = 900
  }
  name = "Test wiki.jenkins-ci.org"
  message = "Notify @pagerduty"
  tags = ["production", "jenkins-ci.org"]

  status = "live"
}
