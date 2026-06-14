resource "helm_release" "argo_cd" {
  chart      = "argo-cd"
  name       = var.argo_cd_helm_release_name
  repository = var.argo_cd_helm_release_repository
  values = [
    templatefile("${path.module}/templates/values/argo_cd/values.tftpl.yaml", {
      argocd_ingress_domain          = var.argocd_ingress_domain,
      argo_cd_helm_release_namespace = var.argo_cd_helm_release_namespace,
      github_org                     = var.argocd_github_org,
      github_sso_admin_team          = var.argocd_github_sso_admin_team,
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
    argocd_ingress_domain          = var.argocd_ingress_domain,
    cluster_issuer_name            = var.cluster_issuer_name,
  })
  depends_on = [helm_release.argo_cd]
}

resource "kubectl_manifest" "argocd_gateway" {
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/gateway.tftmpl.yaml", {
    argo_cd_helm_release_namespace = var.argo_cd_helm_release_namespace,
  })
  depends_on = [helm_release.argo_cd]
}

resource "kubectl_manifest" "argocd_httproute" {
  yaml_body = templatefile("${path.module}/templates/manifests/gateway_api/httproute.tftmpl.yaml", {
    argo_cd_helm_release_namespace = var.argo_cd_helm_release_namespace,
    argocd_ingress_domain          = var.argocd_ingress_domain,
  })
  depends_on = [kubectl_manifest.argocd_gateway]
}

resource "kubectl_manifest" "argocd_github_sso" {
  yaml_body = templatefile("${path.module}/templates/manifests/argocd/github-sso-external-secret.tftmpl.yaml", {
    argo_cd_helm_release_namespace       = var.argo_cd_helm_release_namespace,
    github_sso_client_id_gcp_secret_id   = var.argocd_github_sso_client_id_gcp_secret_id,
    github_sso_client_secret_gcp_secret_id = var.argocd_github_sso_client_secret_gcp_secret_id,
  })
  depends_on = [helm_release.argo_cd]
}

resource "kubectl_manifest" "argocd_github_repo_creds" {
  yaml_body = templatefile("${path.module}/templates/manifests/argocd/github-external-secret.tftmpl.yaml", {
    argo_cd_helm_release_namespace        = var.argo_cd_helm_release_namespace,
    github_org                            = var.argocd_github_org,
    github_app_id_gcp_secret_id           = var.argocd_github_app_id_gcp_secret_id,
    github_app_installation_id_gcp_secret_id = var.argocd_github_app_installation_id_gcp_secret_id,
    github_app_private_key_gcp_secret_id  = var.argocd_github_app_private_key_gcp_secret_id,
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
