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
    gateway_api_crds_version     = optional(string, "1.6.1")
    namespace                    = optional(string, "infra-network")
    cloudflare_account_id_secret = string
    cloudflare_api_token_secret  = string
  })
}

variable "istio" {
  description = "Istio service mesh configuration (ambient mode) with CNI, ztunnel, and ingress gateway."
  type = object({
    enabled           = optional(bool, true)
    release_namespace = optional(string, "infra-network")
    version           = optional(string, "1.28.2")
    cni_platform      = optional(string)
    tracing_service   = optional(string, "infra-monitoring-tempo.infra-monitoring.svc.cluster.local")
    tracing_port      = optional(number, 4317)
    ingress_domain    = string
    cert_issuer_name  = optional(string, "letsencrypt-dns")
  })
}

variable "cloudflare_gateway_controller" {
  description = "Cloudflare Gateway Controller (matheuscscp/cloudflare-gateway-controller) configuration, running highly available tunnel replicas spread across zones and nodes."
  type = object({
    enabled                      = optional(bool, true)
    release_name                 = optional(string, "cloudflare-gateway-controller")
    release_namespace            = optional(string, "infra-network")
    chart_version                = optional(string, "0.16.0")
    cluster_name                 = string
    controller_replicas          = optional(number, 1)
    gateway_class_name           = optional(string, "cloudflare-tunnel")
    gateway_name                 = optional(string, "cloudflare-tunnel")
    tunnel_zones                 = list(string)
    cloudflare_account_id_secret = string
    cloudflare_api_token_secret  = string
  })

  validation {
    condition     = length(distinct(var.cloudflare_gateway_controller.tunnel_zones)) >= 3
    error_message = "tunnel_zones must contain at least 3 distinct zones for a highly available tunnel."
  }
}
