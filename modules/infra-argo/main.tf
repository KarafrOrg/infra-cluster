resource "helm_release" "argo_cd" {
  chart      = "argo-cd"
  name       = var.argo_cd_helm_release_name
  repository = var.argo_cd_helm_release_repository
  version    = var.argo_cd_helm_release_version
  values = [
    templatefile("${path.module}/templates/values/argo_cd/values.tftpl.yaml", {
      argocd_ingress_domain          = var.argocd_ingress_domain,
      argo_cd_helm_release_namespace = var.argo_cd_helm_release_namespace,
      github_org                     = var.argocd_github_org,
      github_sso_admin_team          = var.argocd_github_sso_admin_team,
      otlp_address                   = "${var.faro_host}:4317",
    })
  ]
  upgrade_install  = true
  create_namespace = true
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.argo_cd_helm_release_namespace
}

resource "kubectl_manifest" "argocd_certificate" {
  yaml_body = templatefile("${path.module}/templates/manifests/cert_manager/certificate.tftmpl.yaml", {
    argo_cd_helm_release_namespace = var.argo_cd_helm_release_namespace,
    certificate_hosts              = var.edge_certificate_hosts,
    cluster_issuer_name            = var.cluster_issuer_name,
  })
  depends_on = [helm_release.argo_cd]
}

# Envoy (Faro injection) between the existing Argo CD Gateway and argocd-server.
module "argocd_published_service" {
  source = "../published-service"

  name            = "argocd"
  namespace       = var.argo_cd_helm_release_namespace
  hostnames       = [var.argocd_ingress_domain]
  upstream_host   = "argocd-server.${var.argo_cd_helm_release_namespace}.svc.cluster.local"
  faro_host       = var.faro_host
  create_gateway  = false
  private_gateway = var.private_gateway

  depends_on = [helm_release.argo_cd]
}

moved {
  from = kubectl_manifest.argocd_httproute
  to   = module.argocd_published_service.kubectl_manifest.httproute
}

resource "kubectl_manifest" "argocd_github_sso" {
  yaml_body = templatefile("${path.module}/templates/manifests/argocd/github-sso-external-secret.tftmpl.yaml", {
    argo_cd_helm_release_namespace         = var.argo_cd_helm_release_namespace,
    github_sso_client_id_gcp_secret_id     = var.argocd_github_sso_client_id_gcp_secret_id,
    github_sso_client_secret_gcp_secret_id = var.argocd_github_sso_client_secret_gcp_secret_id,
  })
  depends_on = [helm_release.argo_cd]
}

resource "kubectl_manifest" "argocd_github_repo_creds" {
  yaml_body = templatefile("${path.module}/templates/manifests/argocd/github-external-secret.tftmpl.yaml", {
    argo_cd_helm_release_namespace           = var.argo_cd_helm_release_namespace,
    github_org                               = var.argocd_github_org,
    github_app_id_gcp_secret_id              = var.argocd_github_app_id_gcp_secret_id,
    github_app_installation_id_gcp_secret_id = var.argocd_github_app_installation_id_gcp_secret_id,
    github_app_private_key_gcp_secret_id     = var.argocd_github_app_private_key_gcp_secret_id,
  })
  depends_on = [helm_release.argo_cd]
}

resource "kubectl_manifest" "argocd_application_set" {
  yaml_body = templatefile("${path.module}/templates/manifests/argocd/application-set.tftmpl.yaml", {
    argo_cd_helm_release_namespace = var.argo_cd_helm_release_namespace,
    argo_cd_github_org             = var.argocd_github_org,
  })
  depends_on = [helm_release.argo_cd]
}
