variable "k8s_cluster_token" {
  description = "The authentication token for the Kubernetes cluster."
  type        = string
}

variable "k8s_cluster_host" {
  description = "The host URL of the Kubernetes cluster."
  type        = string
}

variable "cloudflare_api_token" {
  description = "Cloudflare API token used to provision tunnels and DNS via the Cloudflare Terraform provider."
  type        = string
  sensitive   = true
}

variable "argocd" {
  description = "Whether to deploy Argo CD in the cluster."
  type = object({
    enabled                                  = optional(bool, true),
    release_name                             = optional(string, "argocd"),
    release_namespace                        = optional(string, "infra-cicd"),
    release_repository                       = optional(string, "https://argoproj.github.io/argo-helm"),
    ingress_domain                           = string,
    github_org                               = string,
    github_app_id_gcp_secret_id              = string,
    github_app_installation_id_gcp_secret_id = string,
    github_app_private_key_gcp_secret_id     = string,
    github_sso_client_id_gcp_secret_id       = string,
    github_sso_client_secret_gcp_secret_id   = string,
    github_sso_admin_team                    = optional(string, "argocd-admins"),
  })
}

variable "cert_manager" {
  description = "cert-manager configuration for automated TLS certificate management via Let's Encrypt DNS-01."
  type = object({
    enabled                            = optional(bool, true)
    release_name                       = optional(string, "cert-manager")
    release_namespace                  = optional(string, "infra-certs")
    release_version                    = optional(string, "v1.17.2")
    cluster_issuer_name                = optional(string, "letsencrypt-prod")
    acme_email                         = string
    cloudflare_api_token_gcp_secret_id = string
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
    release_namespace  = optional(string, "infra-network")
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

variable "gateway_api" {
  description = "Cloudflare Kubernetes Gateway API controller (pl4nty/cloudflare-kubernetes-gateway) configuration."
  type = object({
    enabled                      = optional(bool, true)
    version                      = optional(string, "v0.9.0")
    gateway_api_crds_version     = optional(string, "0.2.0")
    namespace                    = optional(string, "infra-network")
    cloudflare_account_id_secret = string
    cloudflare_api_token_secret  = string
  })
}

variable "cloudflared" {
  description = "cloudflared DaemonSet configuration for routing Cloudflare tunnel traffic to LoadBalancer services."
  type = object({
    enabled             = optional(bool, true)
    namespace           = optional(string, "infra-network")
    image               = optional(string, "docker.io/cloudflare/cloudflared:2026.6.0")
    tunnel_name         = optional(string, "cloudflared")
    tunnel_token_secret = string
    account_id          = string
  })
}

variable "eck_operator" {
  description = "Elastic Cloud on Kubernetes (ECK) operator Helm release configuration."
  type = object({
    enabled            = optional(bool, true)
    release_name       = optional(string, "eck-operator")
    release_namespace  = optional(string, "infra-elastic")
    release_repository = optional(string, "https://helm.elastic.co")
  })
  default = {}
}
