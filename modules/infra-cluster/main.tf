module "infra_argo" {
  source = "../infra-argo"
  count  = var.argocd.enabled ? 1 : 0
  // region ArgoCD Helm release configuration
  argo_cd_helm_release_name       = var.argocd.release_name
  argo_cd_helm_release_namespace  = var.argocd.release_namespace
  argo_cd_helm_release_repository = var.argocd.release_repository
  argocd_ingress_domain           = var.argocd.ingress_domain
  // endregion
  depends_on = [module.infra_secrets, module.infra_network]
}

module "infra_secrets" {
  source = "../infra-secrets"
  count  = var.external_secrets.enabled ? 1 : 0
  // region External Secrets Helm release configuration
  external_secrets_helm_release_name       = var.external_secrets.release_name
  external_secrets_helm_release_namespace  = var.external_secrets.release_namespace
  external_secrets_helm_release_repository = var.external_secrets.release_repository
  external_secrets_gcp_sa_account_id       = var.external_secrets.gcp_sa_account_id
  gcp_project_id                           = var.external_secrets.gcp_project_id
  // endregion
}

module "infra_network" {
  source = "../infra-network"
  // region Network-related Helm release configurations
  metallb      = var.metallb
  external_dns = var.external_dns
  // endregion
  depends_on = [module.infra_secrets]
}
