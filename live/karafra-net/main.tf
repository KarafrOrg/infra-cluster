module "infra_cluster" {
  source                            = "../../modules/infra-cluster"
  argocd                            = var.argocd
  cert_manager                      = var.cert_manager
  external_secrets                  = var.external_secrets
  k8s_cluster_host                  = var.k8s_cluster_host
  cloudflare_api_token              = var.cloudflare_api_token
  k8s_cluster_token                 = var.k8s_cluster_token
  metallb                           = var.metallb
  external_dns                      = var.external_dns
  gateway_api                       = var.gateway_api
  cloudflared                       = var.cloudflared
  istio                             = var.istio
  longhorn                          = var.longhorn
  k8s_cluster_client_certificate    = var.k8s_cluster_client_certificate
  k8s_cluster_certificate_authority = var.k8s_cluster_certificate_authority
}
