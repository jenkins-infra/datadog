locals {
  update_center_scheme = ["https", "http"]
  update_center_hosts  = ["updates.jenkins.io", "updates.jenkins-ci.org"]
  update_center_uris = [
    "/",
    "/index.html",
    "/update-center.json",
    "/current/update-center.json",
    "/latest/zos-connector.hpi",
    "/download/plugins/zos-connector/3.257.v41e144167971/zos-connector.hpi",
    "/update-center.json?id=default&version=2.462.2",
    "/latest",
  ]

  update_center_urls = [
    for triplet in setproduct(local.update_center_scheme, local.update_center_hosts, local.update_center_uris) : {
      scheme   = triplet[0]
      hostname = triplet[1]
      uri      = triplet[2]
    }
  ]

}

resource "datadog_synthetics_test" "updates_center" {
  for_each = tomap({
    for url in local.update_center_urls : format("%s://%s%s", url.scheme, url.hostname, url.uri) => url.hostname
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
    tick_every       = 900
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
