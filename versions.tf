terraform {
  required_version = ">= 1.15, <1.16"

  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
  }
}
