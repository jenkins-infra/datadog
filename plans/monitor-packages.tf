resource "datadog_monitor" "distribution_package_can_be_downloaded" {
  name                = "Package {{ package.name }} is not available from get.jenkins.io"
  type                = "query alert"
  message             = "{{#is_alert}}\n\n- Please ask help on IRC channel #jenkins-release and #jenkins-infra\n- If appropriate, please open an incident on our [status page](https://github.com/jenkins-infra/status)\n\n{{/is_alert}}\n\n{{#is_recovery}}\n\n- Don't forget  to close an open incidents on status.jenkins.io\n- Have you update our [runbooks][https://github.com/jenkins-infra/runbooks]? \n\n{{/is_recovery}}\n\nNotify: @pagerduty"
  query               = "avg(last_30m):avg:jenkins.package.available{*} by {package} <= 0"
  notify_audit        = false
  timeout_h           = 0
  locked              = false
  no_data_timeframe   = 60
  renotify_interval   = 5
  new_host_delay      = 300
  require_full_window = false

  monitor_thresholds {
    critical          = 0
    critical_recovery = 0.1
  }

  tags = ["terraformed:true", "*"]
}
