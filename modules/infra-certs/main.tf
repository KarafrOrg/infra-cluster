resource "helm_release" "cert_manager" {
  name             = var.release_name
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.release_version
  namespace        = var.release_namespace
  create_namespace = true
  upgrade_install  = true
  timeout          = 600
  wait             = true
  cleanup_on_fail  = true
  atomic           = true

  values = [
    file("${path.module}/templates/values/cert_manager/values.yaml")
  ]

  set {
    name  = "crds.enabled"
    value = "true"
  }
}

resource "kubectl_manifest" "cloudflare_api_token_external_secret" {
  yaml_body = templatefile("${path.module}/templates/manifests/cert_manager/external-secret.tftmpl.yaml", {
    cert_manager_namespace             = var.release_namespace
    cloudflare_api_token_gcp_secret_id = var.cloudflare_api_token_gcp_secret_id
  })
  depends_on = [helm_release.cert_manager]
}

resource "kubectl_manifest" "cluster_issuer" {
  yaml_body = templatefile("${path.module}/templates/manifests/cert_manager/cluster-issuer.tftmpl.yaml", {
    acme_email          = var.acme_email
    cluster_issuer_name = var.cluster_issuer_name
  })
  depends_on = [kubectl_manifest.cloudflare_api_token_external_secret]
}

output "cluster_issuer_name" {
  value = var.cluster_issuer_name
}
