variable "datadog_api_key" {}
variable "datadog_app_key" {}
variable "datadog_jenkinsuser_password" {}
variable "artifact_caching_proxy_providers" {
  description = "Available artifact-caching-proxy providers"
  type        = list(string)
  default     = ["azure", "do"] # Omiting "aws" for now
}
