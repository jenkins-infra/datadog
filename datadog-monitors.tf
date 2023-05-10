resource "datadog_monitor" "account_app_slow" {
  name    = "Account app is slow"
  type    = "metric alert"
  message = "@all @pagerduty Account App is slow"

  query = "avg(last_5m):avg:network.http.response_time{url:https://accounts.jenkins.io/} > 1"

  notify_no_data      = true
  renotify_interval   = 0
  no_data_timeframe   = 10
  notify_audit        = false
  timeout_h           = 0
  require_full_window = true

  monitor_thresholds {
    critical = 1
  }

  tags = ["terraformed:true", "service:account-app"]
}

resource "datadog_monitor" "disk_space" {
  name    = "Available disk space is above {{ value }}% used for {{host.name}}"
  type    = "query alert"
  message = "{{^is_warning}}@pagerduty{{/is_warning}}"

  query               = "avg(last_5m):exclude_null(avg:system.disk.in_use{!device:tmpfs,!device:cgroup,!device:udev,!device:shm,!device:cgmfs,!label:UEFI,!label:uefi,!device:/dev/loop*} by {host,device}) * 100 > 90"
  include_tags        = false
  notify_no_data      = false
  notify_audit        = false
  timeout_h           = 0
  renotify_interval   = 0
  new_group_delay     = 300
  require_full_window = true

  monitor_thresholds {
    critical = 90
    warning  = 80
  }

  tags = ["terraformed:true", "*"]
}

resource "datadog_monitor" "volume_space" {
  name    = "Available space is below {{ value }}% for the {{ persistentvolumeclaim.name }} PVC on {{ cluster_name.name }} cluster"
  type    = "query alert"
  message = "{{^is_warning}}@pagerduty{{/is_warning}}"

  query = "avg(last_5m):exclude_null(avg:kubernetes.kubelet.volume.stats.available_bytes{*} by {cluster_name,persistentvolumeclaim}) / exclude_null(avg:kubernetes.kubelet.volume.stats.capacity_bytes{*} by {cluster_name,persistentvolumeclaim}) * 100 < 10"

  include_tags        = false
  notify_no_data      = false
  notify_audit        = false
  timeout_h           = 0
  renotify_interval   = 0
  new_group_delay     = 300
  require_full_window = true

  monitor_thresholds {
    critical = 10
    warning  = 20
  }

  tags = ["terraformed:true", "*"]
}

resource "datadog_monitor" "ssl_certificate_expiration" {
  name    = "SSL certificate expiring soon for {{url}}"
  type    = "metric alert"
  message = <<EOT
SSL certificate expiring soon for {{url}}, you should take a looksee. {{^is_warning}}@pagerduty{{/is_warning}}
EOT

  query = "max(last_15m):min:http.ssl.days_left{production} by {url} <= 5"

  notify_audit        = false
  timeout_h           = 0
  include_tags        = false
  notify_no_data      = true
  no_data_timeframe   = 10
  renotify_interval   = 0
  new_group_delay     = 300
  require_full_window = true

  monitor_thresholds {
    critical = 5
    warning  = 10
  }

  tags = ["terraformed:true", "*"]
}

resource "datadog_monitor" "weird_response_time" {
  name    = "Weird Response time {{url}} from {{ cluster_name.name }} cluster"
  type    = "metric alert"
  message = <<EOT
{{#is_alert}}{{url.name}} response time is bigger than {{threshold}} seconds from {{ cluster_name.name }} cluster{{/is_alert}}
{{#is_alert_to_warning}}{{url.name}} response time is bigger than {{warn_threshold}} seconds from {{ cluster_name.name }} cluster{{/is_alert_to_warning}}
{{#is_alert_recovery}}{{url.name}} response time from {{ cluster_name.name }} cluster is back to normal{{/is_alert_recovery}}
{{#is_no_data}}{{url.name}} does not response from {{ cluster_name.name }} cluster{{/is_no_data}}
{{^is_warning}}@pagerduty{{/is_warning}}
EOT

  query = "avg(last_5m):max:network.http.response_time{production} by {url,cluster_name} > 5"

  notify_audit        = false
  timeout_h           = 0
  include_tags        = false
  notify_no_data      = true
  no_data_timeframe   = 10
  renotify_interval   = 720
  new_group_delay     = 300
  require_full_window = true

  monitor_thresholds {
    critical = 5
    warning  = 3
  }

  tags = ["terraformed:true", "*"]
}

resource "datadog_monitor" "jenkins_buildqueue_size" {
  name    = "Huge Job Queue on {{host.name}}"
  type    = "metric alert"
  message = "{{#is_alert}} Please forward the alert in #jenkins-infra regardless if you can('t) address this issue.\n\nTo fix look a the following steps:\n\n1. Is there any disk space issues on {{ host.name }}\n2. Does your linux or windows virtual machines correctly provisioned?\n3. Does your aci containers instances correctly provisioned?\n\nDon't hesitate to ask help to someone [here](https://github.com/jenkins-infra/runbooks#contact)\n\n{{/is_alert}}\n\n{{#is_recovery}} Job Queue size is back to normal {{/is_recovery}}\n {{^is_warning}}@pagerduty{{/is_warning}}"
  query   = "avg(last_5m):max:jenkins.queue.size{*} > 150"

  notify_audit        = false
  timeout_h           = 0
  include_tags        = false
  notify_no_data      = false
  renotify_interval   = 5
  require_full_window = true

  monitor_thresholds {
    critical = 150
    warning  = 100
  }

  tags = ["terraformed:true", "*"]
}
