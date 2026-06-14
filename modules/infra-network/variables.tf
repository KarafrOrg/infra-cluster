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

variable "gcp_project_id" {
  description = "The GCP project ID where Secret Manager secrets are stored."
  type        = string
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
