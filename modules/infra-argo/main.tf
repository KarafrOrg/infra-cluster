resource "helm_release" "argo_cd" {
  chart      = "argo-cd"
  name       = var.argo_cd_helm_release_name
  repository = var.argo_cd_helm_release_repository
  values = [
    templatefile("${path.module}/templates/values/argo_cd/values.tftpl.yaml", {
      argocd_ingress_domain          = var.argocd_ingress_domain,
      argo_cd_helm_release_namespace = var.argo_cd_helm_release_namespace,
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

# cert-manager issues and auto-renews a Let's Encrypt certificate for ArgoCD via DNS-01.
# The resulting argocd-server-tls secret is the origin certificate; ArgoCD
# loads it automatically when server.insecure is false.
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
