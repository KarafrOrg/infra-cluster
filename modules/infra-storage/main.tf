resource "kubectl_manifest" "namespace" {
  for_each = toset([
    for ns in [
      var.longhorn.enabled ? var.longhorn.release_namespace : null,
    ] : ns if ns != null
  ])
  yaml_body = templatefile("${path.module}/templates/manifests/namespace.tftpl.yaml", {
    infra_storage_namespace = each.value
  })
}

resource "helm_release" "longhorn" {
  chart      = "longhorn"
  name       = var.longhorn.release_name
  repository = var.longhorn.release_repository
  values = [
    templatefile("${path.module}/templates/values/longhorn/values.tftpl.yaml", {
      infra_storage_namespace = var.longhorn.release_namespace,
    })
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.longhorn.release_namespace
  depends_on       = [kubectl_manifest.namespace]
}
