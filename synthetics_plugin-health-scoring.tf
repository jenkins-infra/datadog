resource "datadog_synthetics_test" "plugin_health_scoring" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://plugin-health.jenkins.io/actuator/health"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  assertion {
    type = "body"
    operator = "validatesJSONPath"
    targetjsonpath {
      jsonpath         = "$.status"      
      operator         = "is"
      elementsoperator = "firstElementMatches"
      targetvalue      = "UP"
    }
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900
  }
  name    = "plugin-health.jenkins.io"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}

resource "datadog_synthetics_test" "plugin_health_scoring_report" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://reports.jenkins.io/plugin-health-scoring/scores.json"
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
  name    = "plugin-health.jenkins.io-report"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}
