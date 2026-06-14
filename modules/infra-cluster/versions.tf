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
    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}
