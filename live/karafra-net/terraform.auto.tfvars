argocd = {
  enabled                                  = true
  ingress_domain                           = "argocd.kubernetes.karafra.net"
  github_org                               = "KarafrOrg"
  github_app_id_gcp_secret_id              = "argocd-github-app-id"
  github_app_installation_id_gcp_secret_id = "argocd-github-app-installation-id"
  github_app_private_key_gcp_secret_id     = "argocd-github-app-private-key"
  github_sso_client_id_gcp_secret_id       = "argocd-github-sso-client-id"
  github_sso_client_secret_gcp_secret_id   = "argocd-github-sso-client-secret"
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
  enabled       = false
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
  enabled             = false
  account_id          = "8a3ba4f6454120fd71c65e87612dd13c"
  tunnel_token_secret = "cloudflared-tunnel-token"
}

istio = {
  enabled        = true
  ingress_domain = "karafra.net"
}
