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

cloudflare_gateway_controller = {
  enabled      = true
  cluster_name = "karafra-net"
  tunnel_replicas = [
    { name = "eu-central-vienna-1", zone = "VIE" },
    { name = "eu-central-vienna-2", zone = "VIE" },
    { name = "eu-central-budapest-1", zone = "BUD" },
    { name = "eu-central-budapest-2", zone = "BUD" },
    { name = "eu-central-prague-1", zone = "PRG" },
    { name = "eu-central-prague-2", zone = "PRG" },
  ]
  cloudflare_account_id_secret = "cloudflare-account-id"
  cloudflare_api_token_secret  = "cloudflare-api-token"
}

istio = {
  enabled        = true
  ingress_domain = "kubernetes.karafra.net"
}

metrics_server = { enabled = true }

node_exporter = { enabled = true }

prometheus_operator_crds = { enabled = true }

kube_state_metrics = { enabled = true }

longhorn = { enabled = true }


alloy = { enabled = true }

mimir     = { enabled = true }
grafana   = { enabled = true }
loki      = { enabled = true }
tempo     = { enabled = true }
pyroscope = { enabled = true }

blackbox_exporter = {
  targets = [
    { name = "github-api", url = "https://www.githubstatus.com/api/v2/status.json", module = "github_status" },
    { name = "example-tcp", url = "example.com:443", module = "tcp_connect" },
  ]
}