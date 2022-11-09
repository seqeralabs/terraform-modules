terraform {
  required_version = ">= 0.13.1"
  required_providers {
    kind = {
      source  = "unicell/kind"
      version = "0.0.2-u2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.15.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.7.1"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "4.1.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.13.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}
