# Monitor build report staleness from builds.reports.jenkins.io
#
# Metrics collected by the buildReportStaleness custom AgentCheck
# deployed via kubernetes-management/config/datadog_confd_checksd.yaml
#
# Ref: https://github.com/jenkins-infra/helpdesk/issues/2843

resource "datadog_monitor" "build_report_stale" {
  name    = "Build report {{ job.name }} on {{ controller.name }} is stale (>24h)"
  type    = "query alert"
  message = <<-EOT
    {{#is_alert}}

    - The build report for {{ job.name }} on {{ controller.name }} has not been updated in over 24 hours
    - Check the job on the private controller
    - https://github.com/jenkins-infra/helpdesk/issues/2843

    {{/is_alert}}

    {{#is_recovery}}

    - Build report for {{ job.name }} on {{ controller.name }} is fresh again

    {{/is_recovery}}

    Notify: @pagerduty
  EOT

  query               = "avg(last_1h):avg:jenkins.build_report.age_hours{*} by {controller,job} > 24"
  notify_audit        = false
  timeout_h           = 0
  no_data_timeframe   = 120
  renotify_interval   = 60
  new_group_delay     = 300
  require_full_window = false

  monitor_thresholds {
    warning           = 18
    critical          = 24
    critical_recovery = 20
  }

  tags = ["terraformed:true", "service:build-reports"]
}


