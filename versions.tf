terraform {
  required_version = ">= 1.10, < 1.11"

  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}
