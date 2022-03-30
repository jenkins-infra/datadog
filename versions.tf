terraform {
  required_version = ">= 1.1, < 1.2"

  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "3.10.0"
    }
  }
}
