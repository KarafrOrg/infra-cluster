resource "random_password" "tunnel_secret" {
  length  = 32
  special = false
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "this" {
  account_id = var.cloudflare_account_id
  name       = var.tunnel_name
  secret     = base64encode(random_password.tunnel_secret.result)
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "this" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id

  config {
    dynamic "ingress_rule" {
      for_each = var.tunnel_ingress
      content {
        hostname = "${ingress_rule.value.subdomain}.${var.domain}"
        service  = "${ingress_rule.value.protocol}://${ingress_rule.value.ip}:${ingress_rule.value.port}"

        dynamic "origin_request" {
          for_each = ingress_rule.value.no_tls_verify ? [1] : []
          content {
            no_tls_verify = true
          }
        }
      }
    }

    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_zero_trust_tunnel_route" "private_network" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.this.id
  network    = var.private_network_cidr
  comment    = "Talos VM private network"
}

resource "cloudflare_zero_trust_access_application" "tcp" {
  for_each = { for entry in var.tunnel_ingress : entry.subdomain => entry if entry.protocol == "tcp" }

  account_id       = var.cloudflare_account_id
  name             = each.value.subdomain
  domain           = "${each.value.subdomain}.${var.domain}"
  type             = "self_hosted"
  session_duration = "24h"
}

resource "cloudflare_zero_trust_access_policy" "tcp_bypass" {
  for_each = cloudflare_zero_trust_access_application.tcp

  account_id     = var.cloudflare_account_id
  application_id = each.value.id
  name           = "bypass-${each.key}"
  precedence     = 1
  decision       = "bypass"

  include {
    everyone = true
  }
}

resource "cloudflare_record" "tunnel_dns" {
  for_each = { for entry in var.tunnel_ingress : entry.subdomain => entry }

  zone_id = var.cloudflare_zone_id
  name    = each.value.subdomain
  content = "${cloudflare_zero_trust_tunnel_cloudflared.this.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}

