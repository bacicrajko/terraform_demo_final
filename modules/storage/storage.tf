variable "storage_account_name" {
  description = "Name for the storage account"
}

variable "location" {
  description = "Location of this resource"
}
variable "resource_group_name" {
  description = "Resource group name where this resource will be placed"
}

#Storage account and setup
resource "azurerm_storage_account" "storage" {
  account_replication_type = "LRS"
  account_tier = "Standard"
  location = var.location
  name = var.storage_account_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_storage_share" "share" {
  name = "data"
  storage_account_name = azurerm_storage_account.storage.name
}

resource "azurerm_storage_share_directory" "data_dir" {

  name = "datadir"
  share_name = azurerm_storage_share.share.name
  storage_account_name = azurerm_storage_account.storage.name
}

resource "azurerm_storage_table" "users_table" {

  name = "userstable"
  storage_account_name = azurerm_storage_account.storage.name
}

output "blob_connection_string" {
  value = azurerm_storage_account.storage.primary_blob_connection_string
}

output "primary_table_endpoint" {
  value = azurerm_storage_account.storage.primary_table_endpoint
}