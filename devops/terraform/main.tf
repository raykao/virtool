terraform {
  required_version = ">= 0.12.24"
}

provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.9.0"
  features {}
}

resource random_string "suffix" {
  length = 4
  upper   = false
  special = false
}

locals {
  suffix = var.suffix !="" ? var.suffix : random_string.suffix.result
  environment = terraform.workspace
}

resource azurerm_resource_group "virtool" {
  name = "${local.environment}-core-virtool-rg"
  location = "canadacentral"
}