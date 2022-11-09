output "argocd-initial-admin-secret" {
  value       = base64decode(data.kubernetes_secret_v1.argocd_admin.binary_data["password"])
  sensitive   = true
  description = "ArgoCD initial admin secret"
  depends_on = [
    resource.helm_release.argocd
  ]
}
