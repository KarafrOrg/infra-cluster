resource "kubectl_manifest" "namespace" {
  yaml_body = templatefile(
    "${path.module}/templates/manifests/external_secrets/ns.tftmpl.yaml",
    {
      external_secrets_helm_release_namespace = var.external_secrets_helm_release_namespace
    }
  )
}

resource "helm_release" "external_secrets" {
  chart      = "external-secrets"
  name       = var.external_secrets_helm_release_name
  repository = var.external_secrets_helm_release_repository
  values = [
    templatefile("${path.module}/templates/values/external_secrets/values.tftpl.yaml", {
      external_secrets_helm_release_namespace = var.external_secrets_helm_release_namespace,
    })
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.external_secrets_helm_release_namespace
  depends_on       = [kubectl_manifest.namespace, kubectl_manifest.gcp_sa_sm_secret]
}

data "google_service_account" "external_secrets" {
  account_id = var.external_secrets_gcp_sa_account_id
  project    = var.gcp_project_id
}

resource "google_service_account_key" "gcp_sa_sm_secret_key" {
  service_account_id = data.google_service_account.external_secrets.name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "kubectl_manifest" "gcp_sa_sm_secret" {
  yaml_body = templatefile(
    "${path.module}/templates/manifests/external_secrets/gcp-sm-sa-key.tftmpl.yaml",
    {
      gcp_sa_sm_secret_name                   = local.gcp_sa_sm_secret_name,
      external_secrets_helm_release_namespace = var.external_secrets_helm_release_namespace
      credentials_json_b64                    = google_service_account_key.gcp_sa_sm_secret_key.private_key
    }
  )
  depends_on = [kubectl_manifest.namespace]
}

resource "kubectl_manifest" "cluster_secret_store" {
  yaml_body = templatefile("${path.module}/templates/manifests/external_secrets/cluster-secret-store.tftmpl.yaml", {
    gcp_sa_sm_secret_name                   = local.gcp_sa_sm_secret_name,
    gcp_project_id                          = var.gcp_project_id,
    external_secrets_helm_release_namespace = var.external_secrets_helm_release_namespace
  })
  depends_on = [kubectl_manifest.gcp_sa_sm_secret, helm_release.external_secrets, kubectl_manifest.namespace]
}
