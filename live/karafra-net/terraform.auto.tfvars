argocd = {
  enabled        = true
  ingress_domain = "argocd.kubernetes.karafra.net"
}

cert_manager = {
  enabled                            = true
  acme_email                         = "admin@karafra.net"
  cloudflare_api_token_gcp_secret_id = "cert-manager-dns01-cloudflare-token"
}

external_secrets = {
  enabled           = true
  gcp_sa_account_id = "k8s-secret-reader"
  gcp_project_id    = "karafra-net"
}

metallb = {
  enabled       = true
  internal_cidr = "10.44.0.0/24"
}

external_dns = {
  enabled                     = true
  domain_filter               = "karafra.net"
  cloudflare_api_token_secret = "cloudflare-api-token"
}

gateway_api = {
  enabled                      = true
  cloudflare_account_id_secret = "cloudflare-account-id"
  cloudflare_api_token_secret  = "cloudflare-api-token"
}

cloudflared = {
  enabled             = true
  account_id          = "8a3ba4f6454120fd71c65e87612dd13c"
  tunnel_token_secret = "cloudflared-tunnel-token"
}
