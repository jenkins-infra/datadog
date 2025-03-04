terraform {
  required_version = ">= 1.11, < 1.12"

  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}
