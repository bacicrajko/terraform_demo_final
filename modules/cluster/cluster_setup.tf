provider "kubernetes" {
  load_config_file = false
  host = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  client_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
  client_key = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = azurerm_kubernetes_cluster.k8s.kube_config[0].host
    client_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate)
    client_key = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate)
  }

}

variable "table_endpoint" {
  description = "Stored in config map. Endpoint for connecting to table service"
}
variable "blob_connection_string" {
  description = "Stored in config map. Connection string for blob service"
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = "microservices"
  }
}

resource "kubernetes_secret" "storage_secret" {
  metadata {
    name = "storagesecret"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  data = {
    connection_string = var.blob_connection_string
    table_endpoint = var.table_endpoint
  }
}

resource "helm_release" "ingress" {
  depends_on = [azurerm_kubernetes_cluster.k8s]

  chart = "nginx-stable/nginx-ingress"
  name = "ingressss"
}