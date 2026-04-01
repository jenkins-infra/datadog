resource "datadog_api_key" "cloudflare" {
  name = "cloudflare"
}

resource "datadog_api_key" "certcijenkinsio_ephemeral_agents" {
  name = "Jenkins Agents for Cert.CI"
}

resource "datadog_api_key" "cijenkinsio_ephemeral_agents" {
  name = "Jenkins Agents for ci.jenkins.io (non Kubernetes)"
}

resource "datadog_api_key" "cijenkinsio_agents_2" {
  name = "ci.jenkins.io-agents-2-20241218"
}

resource "datadog_api_key" "infracijenkinsio_agents_1" {
  name = "infracijenkinsio-agents-1"
}

resource "datadog_api_key" "infracijenkinsio_ephemeral_agents" {
  name = "Jenkins Agents for Infra.CI"
}

resource "datadog_api_key" "privatek8s" {
  name = "privatek8s-20240513"
}

resource "datadog_api_key" "publick8s" {
  name = "prodpublick8s-20220416"
}

resource "datadog_api_key" "puppet_managed_vms" {
  name = "agents-on-puppet-managed-vms-key"
}

resource "datadog_api_key" "terraform_datadog_production" {
  name = "terraform-datadog-production-20240723"
}
resource "datadog_api_key" "terraform_datadog_staging" {
  name = "terraform-datadog-staging-20240723"
}

resource "datadog_api_key" "trustedcijenkinsio_ephemeral_agents" {
  name = "Jenkins Agents for Trusted.CI"
}
