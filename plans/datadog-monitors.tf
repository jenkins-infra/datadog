resource "datadog_monitor" "account_app_slow" {
  name               = "Account app is slow"
  type               = "metric alert"
  message            = "@all @pagerduty Account App is slow"

  query = "avg(last_5m):avg:network.http.response_time{url:https://accounts.jenkins.io/} > 1"

  notify_no_data      = true
  renotify_interval   = 0
  no_data_timeframe   = 10
  notify_audit        = false
  locked              = false
  timeout_h           = 0
  require_full_window = true

  thresholds {
      critical = 1
  }

  tags = ["terraformed:true", "service:account-app"]
}

resource "datadog_monitor" "confluence_choking" {
  name               = "Confluence is choking"
  type               = "metric alert"
  message            = "@all @pagerduty confluence is choking"

  query = "min(last_1m):avg:apache.performance.busy_workers{host:lettuce} > 300"

  notify_no_data      = false
  no_data_timeframe   = 2
  notify_audit        = false
  locked              = false
  timeout_h           = 0
  require_full_window = true
  new_host_delay      = 300
  renotify_interval   = 0

  thresholds {
      critical = 300,
      warning = 250
  }

  tags = ["terraformed:true", "service:confluence"]
}


resource "datadog_monitor" "confluence_down" {
  name               = "Confluence is down"
  type               = "service check"
  message            = "@all @pagerduty Confluence is down"

  query = "\"process.up\".over(\"host:lettuce\",\"process:confluence\").last(6).count_by_status()"

  notify_no_data      = true
  no_data_timeframe   = 5
  notify_audit        = false
  timeout_h           = 0
  renotify_interval   = 0

  thresholds {
      critical = 5,
      warning  = 3,
      ok       = 1
  }

  tags = ["terraformed:true", "service:confluence"]
}

resource "datadog_monitor" "confluence_slow" {
  name               = "Confluence is slow"
  type               = "metric alert"
  message            = "@all @pagerduty Confluence is slow"

  query = "avg(last_5m):avg:network.http.response_time{host:lettuce,url:https://wiki.jenkins-ci.org/display/jenkins/git_plugin} > 3"

  notify_no_data      = true
  no_data_timeframe   = 20
  notify_audit        = false
  timeout_h           = 0
  renotify_interval   = 0

  tags = ["terraformed:true", "service:confluence"]
}

resource "datadog_monitor" "disk_space" {
  name               = "Disk space is below 1GB free {{host.name}}"
  type               = "query alert"
  message            = "@pagerduty"

  query = "max(last_5m):min:system.disk.free{!device:tmpfs,!device:cgroup,!device:udev,!device:shm,!device:cgmfs,!device:/dev/sda15} by {host,device} < 1073741824"

  locked              = false
  include_tags        = false
  notify_no_data      = false
  notify_audit        = false
  timeout_h           = 0
  renotify_interval   = 0
  new_host_delay      = 300
  require_full_window = true

  thresholds {
      critical = 1073741824
  }

  tags = ["terraformed:true", "*"]
}

resource "datadog_monitor" "jira_down" {
  name               = "JIRA is down"
  type               = "service check"
  message            = "@all @pagerduty JIRA is down"

  query = "\"process.up\".over(\"host:edamame\",\"process:jira\").last(6).count_by_status()"

  notify_audit        = false
  timeout_h           = 0
  locked              = false
  include_tags        = false
  notify_no_data      = true
  no_data_timeframe   = 5
  renotify_interval   = 0

  thresholds {
      critical = 5,
      warning  = 3,
      ok       = 1
  }

  tags = ["terraformed:true", "service:jira"]
}

resource "datadog_monitor" "jenkins_dns" {
  name               = "Jenkins DNS may be broken, non-responsive"
  type               = "metric alert"
  message            = <<EOT
It is taking too long or the data is simply unavailable from one or more of our DNS servers.
Consult the [bind runbook](https://github.com/jenkins-infra/runbooks/tree/master/bind) for corrective actions
@pagerduty @oncall
EOT

  query = "avg(last_5m):avg:dns.response_time{*} > 0.5"

  notify_audit        = false
  timeout_h           = 0
  locked              = false
  include_tags        = false
  notify_no_data      = true
  no_data_timeframe   = 2
  renotify_interval   = 10
  new_host_delay      = 300
  require_full_window = true

  thresholds {
      critical = 0.5,
      warning  = 0.2
  }

  tags = ["terraformed:true", "service:jenkins-dns"]
}

resource "datadog_monitor" "plugin_site_index_age" {
  name               = "PluginSite Index age"
  type               = "metric alert"
  message            = <<EOT
{{#is_alert}} {{ site.name }} index is too old {{/is_alert}}. @pagerduty
EOT

  query = "max(last_5m):max:plugins.index.age{*} >= 12"

  notify_audit        = false
  timeout_h           = 0
  locked              = false
  include_tags        = false
  notify_no_data      = true
  no_data_timeframe   = 2
  renotify_interval   = 0
  new_host_delay      = 300
  require_full_window = true

  thresholds {
      critical = 12,
      warning  = 6
  }

  tags = ["terraformed:true", "service:plugin-site", "*"]
}

resource "datadog_monitor" "ssl_certificate_expiration" {
  name               = "SSL certificate expiring soon for {{url}}"
  type               = "metric alert"
  message            = <<EOT
SSL certificate expiring soon for {{url}}, you should take a looksee. @oncall @pagerduty
EOT

  query = "max(last_15m):min:http.ssl.days_left{*} by {url} <= 5"

  notify_audit        = false
  timeout_h           = 0
  locked              = false
  include_tags        = false
  notify_no_data      = true
  no_data_timeframe   = 10
  renotify_interval   = 0
  new_host_delay      = 300
  require_full_window = true

  thresholds {
      critical = 5,
      warning  = 10
  }

  tags = ["terraformed:true", "*"]
}

resource "datadog_monitor" "weird_response_time" {
  name               = "Weird Response time {{url}}"
  type               = "metric alert"
  message            = <<EOT
{{#is_alert}}{{url.name}} response time is bigger than {{threshold}} seconds  {{/is_alert}}
{{#is_alert_to_warning}}{{url.name}} response time is bigger than {{warn_threshold}} seconds {{/is_alert_to_warning}}
{{#is_alert_recovery}}{{url.name}} response time is back to normal{{/is_alert_recovery}}
{{#is_no_data}}{{url.name}} does not response{{/is_no_data}}
@oncall @pagerduty
EOT

  query = "avg(last_5m):max:network.http.response_time{*} by {url} > 5"

  notify_audit        = false
  timeout_h           = 0
  locked              = false
  include_tags        = false
  notify_no_data      = true
  no_data_timeframe   = 10
  renotify_interval   = 720
  new_host_delay      = 300
  require_full_window = true

  thresholds {
      critical = 5,
      warning  = 3
  }

  tags = ["terraformed:true", "*"]
}

resource "datadog_monitor" "service_unreachable" {
  name               = "{{url.name}} is unreachable"
  type               = "service check"
  message            = "@oncall"

  query = "\"http.can_connect\".over(\"*\").last(4).count_by_status()"

  notify_audit        = false
  timeout_h           = 0
  locked              = false
  include_tags        = false
  notify_no_data      = true
  no_data_timeframe   = 10
  renotify_interval   = 5
  new_host_delay      = 300
  require_full_window = true

  thresholds {
      critical = 3,
      warning  = 2
  }

  tags = ["terraformed:true", "*"]
}
