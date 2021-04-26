terraform {
  required_version = ">= 0.13.6, < 0.14.0"

  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 2.25"
    }
  }
}
