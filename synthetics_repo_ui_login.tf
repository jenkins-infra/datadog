resource "datadog_synthetics_test" "repojenkinsciorgui-login" {
  type = "api"
  request_definition {
    method = "POST"
    url    = "https://repo.jenkins-ci.org/ui/api/v1/ui/auth/login?_spring_security_remember_me=false"
    body   = "{\"user\":\"datadog_monitoring\",\"password\":\"${var.datadog_jenkinsuser_password}\",\"type\":\"login\"}"
  }

  request_headers = {
    Content-Type     = "application/json"
    X-Requested-With = "XMLHttpRequest"
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
  name    = "login repo.jenkins-ci.org (UI)"
  message = "Notify @pagerduty"
  tags    = ["production", "jenkins-ci.org"]

  status = "live"

}
