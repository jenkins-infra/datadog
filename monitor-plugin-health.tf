# Monitor plugin-health-scoring engine staleness from plugin-health.jenkins.io
#
# Metrics collected by the pluginHealthEngineStaleness custom AgentCheck
# deployed via kubernetes-management/config/datadog_confd_checksd.yaml
#
# Ref: https://github.com/jenkins-infra/helpdesk/issues/5257

locals {
  # Both engines are components of a single actuator response, so the list is defined
  # here rather than mirrored from kubernetes-management.
  # Datadog normalises tag values to lowercase, so the queries below match on the
  # lowercased name while the monitor names keep the camel case used by the actuator.
  plugin_health_engines = toset(["probeEngine", "scoringEngine"])
}


resource "datadog_monitor" "plugin_health_engine_stale" {
  for_each = local.plugin_health_engines

  name = "Plugin health scoring ${each.value} is stale"
  type = "query alert"

  message = <<-EOT
    {{#is_alert}}

    - The plugin health ${each.value} last recorded a success {{ value }} hour(s) ago
    - The status field is derived from the last success and never expires, so this can be stale while still reporting UP
    - Health: https://plugin-health.jenkins.io/actuator/health/engines
    - Check the cronjob schedule on publick8s

    - https://github.com/jenkins-infra/helpdesk/issues/5257

    {{/is_alert}}

    {{#is_recovery}}

    - Plugin health ${each.value} is recording successes again

    {{/is_recovery}}

    Notify: @pagerduty
  EOT

  # The check submits hourly, so the window has to be wide enough to hold a point.
  # Warning is two missed runs, critical is six.
  query               = "max(last_2h):avg:jenkins.phs_engine.age_in_hours{engine:${lower(each.value)}} > 6"
  notify_audit        = false
  timeout_h           = 0
  no_data_timeframe   = 120
  renotify_interval   = 60
  require_full_window = false
  draft_status        = "published"

  monitor_thresholds {
    warning  = 2
    critical = 6
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

    Notify: @pagerduty
  EOT

  # Alert only if every check in the window failed to reach the endpoint, so a
  # single transient failure does not page anyone
  query               = "max(last_2h):avg:jenkins.phs_engine.reachable{engine:${lower(each.value)}} < 1"
  notify_audit        = false
  timeout_h           = 0
  no_data_timeframe   = 120
  renotify_interval   = 60
  require_full_window = false
  draft_status        = "published"

  monitor_thresholds {
    critical = 1
  }

  tags = ["terraformed:true", "*"]
}
