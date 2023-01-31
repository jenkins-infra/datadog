resource "datadog_synthetics_test" "artifact-caching-proxy-providers" {
  for_each = toset(var.artifact_caching_proxy_providers)
  type     = "api"
  request_definition {
    method = "GET"
    url    = "https://repo.${each.value}.jenkins.io/health"
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
  name    = "repo.${each.value}.jenkins.io"
  message = "Notify @pagerduty"
  tags = [
    "jenkins.io",
    "production"
  ]

  status = "live"
}
