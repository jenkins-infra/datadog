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

# TODO: remove after import
import {
  to = datadog_application_key.puppet_managed_vms
  id = "341a39c9-de8d-4f1a-ba26-1ba6ce82e5c8"
}
import {
  to = datadog_application_key.cijenkinsio_agents_2
  id = "b9ac5318-bb65-4cd1-b51b-89424c661853"
}
import {
  to = datadog_application_key.cloudflare
  id = "d01fc7b5-2389-471f-8b40-afeaf547e063"
}
import {
  to = datadog_application_key.certcijenkinsio_ephemeral_agents
  id = "38094507-5dbf-46fb-8e60-1beea367b2d9"
}
import {
  to = datadog_application_key.cijenkinsio_ephemeral_agents
  id = "b790b17b-a191-495d-8c36-482ff3eb397d"
}
import {
  to = datadog_application_key.infracijenkinsio_ephemeral_agents
  id = "2bbff789-66e2-4c6a-b446-e7d355baec26"
}
import {
  to = datadog_application_key.trustedcijenkinsio_ephemeral_agents
  id = "8a5da448-cd4f-42c0-a7e9-5eef68d470f8"
}
import {
  to = datadog_application_key.privatek8s
  id = "b106f3bc-c616-41e8-8adf-074f1d3ef885"
}
import {
  to = datadog_application_key.publick8s
  id = "9daaae0d-4728-49d3-98da-ad194e6b14e7"
}
import {
  to = datadog_application_key.terraform_datadog_production
  id = "d88536b7-2ca5-4814-be25-ec55e79ecedb"
}
import {
  to = datadog_application_key.terraform_datadog_staging
  id = "4e7c7ab6-571b-4244-97e5-27735d4a2fae"
}
