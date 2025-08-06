locals {
  update_center_hosts = ["updates.jenkins.io", "updates.jenkins-ci.org"]
  update_center_uris = [
    "/",
    "/index.html",
    "/update-center.json",
    "/current",
    "/current/",
    "/current/update-center.json",
    "/latest/zos-connector.hpi",
    "/download/plugins/zos-connector/3.257.v41e144167971/zos-connector.hpi",
    "/update-center.json?id=default&version=2.462.2",
    "/updates",
    "/updates/",
    "/updates/hudson.tasks.Maven.MavenInstaller.json",
    "/current/updates",
    "/current/updates/",
    "/latest",
    "/latest/",
  ]

  update_center_urls = [
    for duet in setproduct(local.update_center_hosts, local.update_center_uris) : {
      hostname = triplet[0]
      uri      = triplet[1]
    }
  ]
}

resource "datadog_synthetics_test" "updates_center" {
  for_each = tomap({
    for url in local.update_center_urls : format("https://%s%s", url.hostname, url.uri) => url.hostname
  })


  type = "api"
  request_definition {
    method = "GET"
    url    = each.key
  }
  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every       = 60
    follow_redirects = true
  }
  name    = each.key
  message = "Notify @pagerduty"
  tags = [
    each.value,
    "production"
  ]

  status = "live"
}

resource "datadog_synthetics_test" "updates_center_http_to_https" {
  for_each = tomap({
    for url in local.update_center_urls : format("%s%s", url.hostname, url.uri) => url.hostname
  })

  type = "api"
  request_definition {
    method = "GET"
    url    = format("http://%s", each.key)
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
    target   = format("https://%s", each.key)
  }
  locations = ["aws:eu-central-1"]
  options_list {
    tick_every = 900
  }
  name = each.key
  ## TODO: uncomment to enable alerting
  # message = "Notify @pagerduty"
  tags = [
    each.value,
    "production"
  ]

  status = "live"
}
