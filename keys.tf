resource "datadog_api_key" "infracijenkinsio_agents_1" {
  name = "infracijenkinsio-agents-1"
}

# See the permissions available for scoped keys at https://docs.datadoghq.com/account_management/rbac/permissions/#permissions-list
resource "datadog_application_key" "infracijenkinsio_agents_1" {
  name = "infracijenkinsio-agents-1"
  # scopes unset - inherits all user permissions
}
