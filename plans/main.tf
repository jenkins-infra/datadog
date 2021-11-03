terraform {
  required_version = ">= 1.0, < 1.1"

  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.5"
    }
  }
}
