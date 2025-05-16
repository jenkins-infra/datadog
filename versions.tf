terraform {
  required_version = ">= 1.12, < 1.13"

  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}
