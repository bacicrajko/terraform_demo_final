#Variables declaration

variable "location" {
  description = "Azure location of the resource (West Eu)"
  validation {
    condition = contains(["West Europe", "North Europe"], var.location)
    error_message = "Location must be one of [West Europe, North Europe]!"
  }
}

variable "resource_group_name" {
  description = "Name of the resource group resource will be placed in"
}