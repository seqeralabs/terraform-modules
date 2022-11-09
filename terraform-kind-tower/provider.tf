provider "kubernetes" {
  config_path = resource.kind_cluster.this.kubeconfig_path
}

provider "helm" {
  kubernetes {
    config_path = resource.kind_cluster.this.kubeconfig_path
  }
}

provider "argocd" {
  server_addr = "${var.argocd_ingress_host}:443"
  username    = "admin"
  password    = base64decode(data.kubernetes_secret_v1.argocd_admin.binary_data["password"])
  insecure    = true
}

provider "kubectl" {
  config_path = resource.kind_cluster.this.kubeconfig_path
}
