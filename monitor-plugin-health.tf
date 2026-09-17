# Monitor plugin-health-scoring engine staleness from plugin-health.jenkins.io
#
# Metrics collected by the pluginHealthEngineStaleness custom AgentCheck
# deployed via kubernetes-management/config/datadog_confd_checksd.yaml
#
# Ref: https://github.com/jenkins-infra/helpdesk/issues/5257

locals {
  # Both engines are components of a single actuator response, so the list is defined
  # here rather than mirrored from kubernetes-management.
  plugin_health_engines = toset(["probeEngine", "scoringEngine"])
}


resource "datadog_monitor" "plugin_health_engine_stale" {
  for_each = local.plugin_health_engines

  name = "Plugin health scoring ${each.value} is stale"
  type = "query alert"

  message = <<-EOT
    {{#is_alert}}

    - The plugin health ${each.value} has not recorded a success in over {{ threshold_in_hours.name }} hour(s)
    - The status field is derived from the last success and never expires, so this can be stale while still reporting UP
    - Health: https://plugin-health.jenkins.io/actuator/health/engines
    - Check the cronjob schedule on publick8s

    - https://github.com/jenkins-infra/helpdesk/issues/5257

    {{/is_alert}}

    {{#is_recovery}}

    - Plugin health ${each.value} is recording successes again

    {{/is_recovery}}
  EOT

  # Alert if any check in the last 5m reports stale (>=1) for this specific engine
  query               = "max(last_5m):avg:jenkins.phs_engine.stale{engine:${each.value}} by {threshold_in_hours} >= 1"
  notify_audit        = false
  timeout_h           = 0
  no_data_timeframe   = 120
  renotify_interval   = 60
  require_full_window = false
  # Published without a notification target: it evaluates and is visible in Datadog
  # but pages nobody until the thresholds have been confirmed against real data
  draft_status = "published"

  monitor_thresholds {
    critical = 1
  }

  tags = ["terraformed:true", "*"]
}

resource "datadog_monitor" "plugin_health_engine_unreachable" {
  for_each = local.plugin_health_engines

  name = "Plugin health scoring ${each.value} is unreachable"
  type = "query alert"

  message = <<-EOT
    {{#is_alert}}

    - The plugin health actuator endpoint is unreachable, so ${each.value} cannot be checked
    - Health: https://plugin-health.jenkins.io/actuator/health/engines

    - https://github.com/jenkins-infra/helpdesk/issues/5257

    {{/is_alert}}

    {{#is_recovery}}

    - Plugin health actuator endpoint is reachable again

    {{/is_recovery}}
  EOT

  # Alert if the actuator endpoint was unreachable for all checks in the last 5m
  query               = "min(last_5m):avg:jenkins.phs_engine.reachable{engine:${each.value}} < 1"
  notify_audit        = false
  timeout_h           = 0
  no_data_timeframe   = 120
  renotify_interval   = 60
  require_full_window = false
  # Published without a notification target: it evaluates and is visible in Datadog
  # but pages nobody until the thresholds have been confirmed against real data
  draft_status = "published"

  monitor_thresholds {
    critical = 1
  }

  tags = ["terraformed:true", "*"]
}
