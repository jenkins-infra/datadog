resource "datadog_synthetics_test" "docker_404" {
  type = "api"
  request_definition {
    method = "GET"
    url    = "https://builds.reports.jenkins.io/build_status_reports/infra.ci.jenkins.io/docker-jobs/docker-404/main/status.json"
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  assertion {
  type     = "body"
  operator = "validatesJSONPath"
  targetjsonpath {
    jsonpath    = "$.build_status"
    operator    = "is"
    targetvalue = "SUCCESS"
    }
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900
    retry {
      count    = 2
      interval = 300
    }
  }
  name    = "docker-404 build status"
  # message = "Notify @pagerduty"
  tags    = ["production", "jenkins-infra", "docker-404"]
  status = "live"
}
