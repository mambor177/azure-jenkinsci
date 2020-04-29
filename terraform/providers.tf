provider "azurerm" {
  version         = "=2.7.0"
  subscription_id = "b3185911-c383-4d02-8fab-ef0ae53f9312"
  tenant_id       = "c5dfe39d-8c38-4b78-bde6-226c2caf434e"
  features {}
}

provider "azuread" {
  version = "=0.8.0"
}

provider "random" {
  version = "~>2.2"
}

provider "tls" {
  version = "~>2.1"
}