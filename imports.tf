import {
  to = datadog_logs_custom_pipeline.mirrorbits_scan_mirrors_logs
  id = "5NZhKxKZSsema717VHp2mw"
}
import {
  to = datadog_logs_custom_pipeline.mirrorbits_scan_repo_logs
  id = "2tJ_0biaSWaN6I43gDJehg"
}
moved {
  from = datadog_logs_custom_pipeline.mirrorbits_logs
  to   = datadog_logs_custom_pipeline.mirrorbits_general_logs
}
