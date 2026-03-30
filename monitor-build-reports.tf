# Monitor build report staleness from builds.reports.jenkins.io
#
# Metrics collected by the buildReportStaleness custom AgentCheck
# deployed via kubernetes-management/config/datadog_confd_checksd.yaml
#
# Ref: https://github.com/jenkins-infra/helpdesk/issues/2843

locals {
  build_report_jobs = yamldecode(file("${path.module}/build-report-jobs.yaml")).build_report_jobs
}

resource "datadog_monitor" "build_report_stale" {
  for_each = local.build_report_jobs

  name = "Build report ${each.value.job} on ${each.value.controller} is stale"
  type = "query alert"

  message = <<-EOT
    {{#is_alert}}

    - The build report for {{ job.name }} on {{ controller.name }} has not been updated in over {{ threshold_hours.name }} hour(s)
    - Check the job on the private controller {{ controller.name }}
    - Job URL: https://{{ controller.name }}/job/{{ job.name }}
    - Report: https://builds.reports.jenkins.io/build_status_reports/{{ controller.name }}/{{ job.name }}/status.json

    - https://github.com/jenkins-infra/helpdesk/issues/2843

    {{/is_alert}}

    {{#is_recovery}}

    - Build report for {{ job.name }} on {{ controller.name }} is fresh again

    {{/is_recovery}}

    Notify: @pagerduty
  EOT

# Alert if any check in the last 5m reports stale (>=1) for this specific controller+job
  query               = "max(last_5m):avg:jenkins.build_report.stale{controller:${each.value.controller},job:${each.value.job}} >= 1"
  notify_audit        = false
  timeout_h           = 0
  no_data_timeframe   = 120
  renotify_interval   = 60
  new_group_delay     = 300
  require_full_window = false
  draft_status        = "draft"

  monitor_thresholds {
    critical = 1
  }

  tags = ["terraformed:true", "*"]
}
