terraform {
  backend "local" {
  }
}

provider "azurerm" {
  version = "=2.27.0"
  features {}
}

resource "azurerm_resource_group" "stagingrg" {
  location = "West Europe"
  name = "emk-stg-demo"
}

locals {
  location = "West Europe"
}

module "cluster"{

  source = "../modules/cluster"

  location = local.location
  resource_group_name = azurerm_resource_group.stagingrg.name
  vm_size = "Standard_B2s"
  cluster_name = "emk-stg-cluster"
  blob_connection_string = module.storage.blob_connection_string
  table_endpoint = module.storage.primary_table_endpoint
}

module "storage" {
  source= "../modules/storage"

  storage_account_name = "emkstagingaccount"
  location = local.location
  resource_group_name = azurerm_resource_group.stagingrg.name
}