terraform {
  required_version = ">= 1.6, < 1.7"

  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}
