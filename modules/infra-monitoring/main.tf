resource "helm_release" "metrics_server" {
  count      = var.metrics_server.enabled ? 1 : 0
  chart      = "metrics-server"
  name       = var.metrics_server.release_name
  repository = var.metrics_server.release_repository
  values = [
    templatefile("${path.module}/templates/values/metrics_server/values.tftpl.yaml", {
      metrics_server_helm_release_namespace = var.metrics_server.release_namespace
    })
  ]
  upgrade_install  = true
  create_namespace = true
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.metrics_server.release_namespace
}

