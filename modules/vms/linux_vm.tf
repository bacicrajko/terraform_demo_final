variable "resource_group_name" {
}
variable "location" {
}
variable "size" {
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.passkey1.public_key_openssh
  }

  allow_extension_operations = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  network_interface_ids = [azurerm_network_interface.example.id]

  provisioner "remote-exec" {
    inline = ["sudo apt-get -y install nginx"]
    connection {
      host = azurerm_public_ip.example.ip_address
      user = azurerm_linux_virtual_machine.example.admin_username
      password = azurerm_linux_virtual_machine.example.admin_password
      private_key = tls_private_key.passkey1.private_key_pem
    }
  }
}

resource "tls_private_key" "passkey1" {
  algorithm   = "RSA"
  rsa_bits = "2048"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "example" {
  allocation_method = "Static"
  location = var.location
  name = "public_ip_linux_vm"
  resource_group_name = var.resource_group_name
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.example.id
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_virtual_machine_extension" "customscriptex" {
  name = "customex"
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.0"
  virtual_machine_id = azurerm_linux_virtual_machine.example.id

  settings = <<SETTINGS
    {
        "script": "${base64encode(templatefile("../modules/vms/setup.sh", {
          test="test_var"
        }))}"
    }
    SETTINGS
}