terraform {
  backend "local" {
  }
}

provider "azurerm" {
  version = "=2.27.0"
  features {}
}

variable "rg_name" {
  description = "resource group name"
}

variable "rg_location"{
  description = "resource group location"
}

resource "azurerm_resource_group" "simplerg" {
  location = var.rg_location
  name = var.rg_name
}