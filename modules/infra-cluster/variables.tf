variable "k8s_cluster_token" {
  description = "The authentication token for the Kubernetes cluster."
  type        = string
}

variable "k8s_cluster_host" {
  description = "The host URL of the Kubernetes cluster."
  type        = string
}

variable "argocd" {
  description = "Whether to deploy Argo CD in the cluster."
  type = object({
    enabled            = optional(bool, true),
    release_name       = optional(string, "argocd"),
    release_namespace  = optional(string, "infra-cicd"),
    release_repository = optional(string, "https://argoproj.github.io/argo-helm"),
    ingress_domain     = string,
  })
}

variable "external_secrets" {
  description = "Whether to deploy External Secrets in the cluster."
  type = object({
    enabled            = optional(bool, true),
    release_name       = optional(string, "external-secrets"),
    release_namespace  = optional(string, "infra-secrets"),
    release_repository = optional(string, "https://charts.external-secrets.io"),
    gcp_sa_account_id  = string,
    gcp_project_id     = string,
  })
}

variable "metallb" {
  description = "MetalLB Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "metallb")
    release_namespace  = optional(string, "metallb-system")
    release_repository = optional(string, "https://metallb.github.io/metallb")
    internal_cidr      = optional(string, "10.44.0.0/24")
  })
  default = {}
}

variable "external_dns" {
  description = "ExternalDNS Helm release configuration with Cloudflare backend."
  type = object({
    enabled                     = optional(bool, true)
    release_name                = optional(string, "external-dns")
    release_namespace           = optional(string, "infra-network")
    release_repository          = optional(string, "https://kubernetes-sigs.github.io/external-dns/")
    domain_filter               = string
    txt_owner_id                = optional(string, "external-dns")
    cloudflare_api_token_secret = string
  })
}
