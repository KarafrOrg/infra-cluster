module "infra_cluster" {
  source               = "../../modules/infra-cluster"
  argocd               = var.argocd
  cert_manager         = var.cert_manager
  external_secrets     = var.external_secrets
  k8s_cluster_host     = var.k8s_cluster_host
  cloudflare_api_token = var.cloudflare_api_token
  k8s_cluster_token    = var.k8s_cluster_token
  metallb              = var.metallb
  external_dns         = var.external_dns
  gateway_api          = var.gateway_api
  cloudflared          = var.cloudflared
  eck_operator         = var.eck_operator
}
