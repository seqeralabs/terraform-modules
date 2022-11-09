data "kubernetes_secret_v1" "argocd_admin" {
  metadata {
    namespace = "argocd"
    name      = "argocd-initial-admin-secret"
  }

  binary_data = {
    "password" = ""
  }

  depends_on = [
    resource.kind_cluster.this,
    resource.helm_release.argocd
  ]
}