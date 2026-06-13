locals {
  metallb_ip_pool_name = "internal-pool"
  cloudflare_namespace = var.gateway_api.enabled ? var.gateway_api.namespace : var.cloudflared.namespace
}
