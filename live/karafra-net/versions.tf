terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "7.36.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "karafra-net"

    workspaces {
      name = "infra-cluster"
    }
  }
}

provider "kubectl" {
  host             = var.k8s_cluster_host
  token            = var.k8s_cluster_token
  load_config_file = false
  insecure         = true
}

provider "google" {}

provider "helm" {
  kubernetes {
    host     = var.k8s_cluster_host
    token    = var.k8s_cluster_token
    insecure = true
  }
}
