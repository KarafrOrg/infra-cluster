resource "helm_release" "reloader" {
  count = var.reloader.enabled ? 1 : 0

  chart            = "reloader"
  name             = var.reloader.release_name
  namespace        = var.reloader.release_namespace
  repository       = var.reloader.release_repository
  version          = var.reloader.release_version
  values           = [file("${path.module}/templates/values/reloader.yaml")]
  upgrade_install  = true
  create_namespace = true
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true

  depends_on = [module.infra_argo]
}
