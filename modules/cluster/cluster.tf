#Kubernetes cluster

variable "vm_size" {
  description = "VM size for the clusters default pool"
  validation {
    condition = contains(["Standard_B2ms", "Standard_B2s"], var.vm_size)
    error_message = "VM size must be one of: [Standard_B2ms, Standard_B2s]!"
  }
}

variable "cluster_name" {
  description = "Name and dns prefix of the cluster"
}

#Module resource members
resource "azurerm_kubernetes_cluster" "k8s" {
  location = var.location
  resource_group_name = var.resource_group_name

  dns_prefix = var.cluster_name
  name = var.cluster_name

  addon_profile {
    kube_dashboard {
      enabled = true
    }
  }
  default_node_pool {

    name = "default"
    vm_size = var.vm_size
    node_count = 1
  }

  service_principal {
    client_id = data.azurerm_key_vault_secret.principal_id.value
    client_secret = data.azurerm_key_vault_secret.principal_secret.value
  }

  linux_profile {
    admin_username = "emkAdmin"
    ssh_key {
      key_data = tls_private_key.passkey.public_key_openssh
    }
  }
}

resource "tls_private_key" "passkey" {
  algorithm   = "RSA"
  rsa_bits = "2048"
}

data "azurerm_key_vault" "tfkeyvault" {
  name = "terra-key-vault"
  resource_group_name = "terraform-state"
}

data "azurerm_key_vault_secret" "principal_id" {
  key_vault_id = data.azurerm_key_vault.tfkeyvault.id
  name = "service-principal"
}

data "azurerm_key_vault_secret" "principal_secret" {
  key_vault_id = data.azurerm_key_vault.tfkeyvault.id
  name = "principal-key"
}
#Module outputs