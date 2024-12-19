terraform {
  required_providers {
    azapi = {
      source = "azure/azapi"
    }
  }
}

provider "azurerm" {
  subscription_id = "f4300d6a-9217-492f-a6b5-db16bfcf0259"
  features {}
}

provider "azapi" {

}

resource "azurerm_resource_group" "main" {
  location = "westeurope"
  name     = "aw40-demo-hub-rg"
}