terraform {
  required_providers {
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
