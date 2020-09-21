terraform {
  backend "local" {
  }
}

provider "azurerm" {
  version = "=2.27.0"
  features {}
}

resource "azurerm_resource_group" "test_rg" {
  location = "West Europe"
  name = "emktestresourcegroup"
}

module "vm" {
  source = "../modules/vms"

  location = "West Europe"
  resource_group_name = azurerm_resource_group.test_rg.name
  size = "Standard_B1ms"
}