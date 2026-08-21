terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.5.0"
    }
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

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "kubectl" {
  host                   = "https://${var.k8s_cluster_host}:6443"
  client_certificate     = base64decode(var.k8s_cluster_client_certificate)
  client_key             = base64decode(var.k8s_cluster_token)
  cluster_ca_certificate = base64decode(var.k8s_cluster_certificate_authority)
  load_config_file       = false
}

provider "google" {}

provider "helm" {
  kubernetes {
    host = "https://${var.k8s_cluster_host}:6443"

    client_certificate     = base64decode(var.k8s_cluster_client_certificate)
    client_key             = base64decode(var.k8s_cluster_token)
    cluster_ca_certificate = base64decode(var.k8s_cluster_certificate_authority)
  }
}

