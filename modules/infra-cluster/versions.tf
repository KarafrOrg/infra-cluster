terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    helm = {
      source = "hashicorp/helm"
    }
    google = {
      source = "hashicorp/google"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
    }
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}
