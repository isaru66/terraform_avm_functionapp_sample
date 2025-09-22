terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.42.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  subscription_id = "79e1d757-ecdb-4dc3-b0b4-035bac76053d"

  # set to true to use Azure AD authentication for the storage account instead of access keys
  storage_use_azuread = true
}