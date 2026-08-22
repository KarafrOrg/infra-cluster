resource "kubernetes_cluster_role_v1" "unauthenticated_oidc_jwks" {
  metadata {
    name = "unauthenticated-oidc-jwks"
  }

  rule {
    non_resource_urls = [
      "/.well-known/openid-configuration",
      "/openid/v1/jwks",
    ]

    verbs = ["get"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "unauthenticated_oidc_jwks" {
  metadata {
    name = "unauthenticated-oidc-jwks"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.unauthenticated_oidc_jwks.metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "system:unauthenticated"
    api_group = "rbac.authorization.k8s.io"
  }
}

module "infra_argo" {
  source = "../infra-argo"
  count  = var.argocd.enabled ? 1 : 0
  // region ArgoCD Helm release configuration
  argo_cd_helm_release_name                       = var.argocd.release_name
  argo_cd_helm_release_namespace                  = var.argocd.release_namespace
  argo_cd_helm_release_repository                 = var.argocd.release_repository
  argocd_ingress_domain                           = var.argocd.ingress_domain
  argocd_github_org                               = var.argocd.github_org
  argocd_github_app_id_gcp_secret_id              = var.argocd.github_app_id_gcp_secret_id
  argocd_github_app_installation_id_gcp_secret_id = var.argocd.github_app_installation_id_gcp_secret_id
  argocd_github_app_private_key_gcp_secret_id     = var.argocd.github_app_private_key_gcp_secret_id
  argocd_github_sso_client_id_gcp_secret_id       = var.argocd.github_sso_client_id_gcp_secret_id
  argocd_github_sso_client_secret_gcp_secret_id   = var.argocd.github_sso_client_secret_gcp_secret_id
  argocd_github_sso_admin_team                    = var.argocd.github_sso_admin_team
  cluster_issuer_name                             = var.cert_manager.cluster_issuer_name
  // endregion
  depends_on = [module.infra_secrets, module.infra_network, module.infra_certs]
}

module "infra_certs" {
  source                             = "../infra-certs"
  count                              = var.cert_manager.enabled ? 1 : 0
  release_name                       = var.cert_manager.release_name
  release_namespace                  = var.cert_manager.release_namespace
  release_version                    = var.cert_manager.release_version
  cluster_issuer_name                = var.cert_manager.cluster_issuer_name
  acme_email                         = var.cert_manager.acme_email
  cloudflare_api_token_gcp_secret_id = var.cert_manager.cloudflare_api_token_gcp_secret_id
  depends_on                         = [module.infra_secrets]
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
  gcp_project_id = var.external_secrets.gcp_project_id
  metallb        = var.metallb
  external_dns   = var.external_dns
  gateway_api    = var.gateway_api
  cloudflared    = var.cloudflared
  istio          = var.istio
  // endregion
  depends_on = [module.infra_secrets]
}

module "infra_monitoring" {
  source = "../infra-monitoring"
  // region Monitoring-related Helm release configurations
  gcp_project_id = var.external_secrets.gcp_project_id
  metrics_server = var.metrics_server
  // endregion
  depends_on = [module.infra_secrets]
}
