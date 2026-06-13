module "infra_cluster" {
  source            = "../../modules/infra-cluster"
  argocd            = var.argocd
  external_secrets  = var.external_secrets
  k8s_cluster_host  = var.k8s_cluster_host
  k8s_cluster_token = var.k8s_cluster_token
  metallb           = var.metallb
  external_dns      = var.external_dns
}
