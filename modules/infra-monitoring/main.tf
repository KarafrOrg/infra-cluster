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

resource "helm_release" "prometheus_operator" {
  chart      = "prometheus-operator"
  name       = var.prometheus_operator.release_name
  repository = var.prometheus_operator.release_repository
  values = [
    templatefile("${path.module}/templates/values/prometheus_operator/values.tftpl.yaml", {
      prometheus_operator_helm_release_namespace = var.prometheus_operator.release_namespace
    })
  ]
  upgrade_install  = true
  create_namespace = true
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.prometheus_operator.release_namespace
  count            = var.prometheus_operator.enabled ? 1 : 0
}

resource "helm_release" "node_exporter" {
  count      = var.node_exporter.enabled ? 1 : 0
  chart      = "node-exporter"
  name       = var.node_exporter.release_name
  repository = var.node_exporter.release_repository
  values = [
    templatefile("${path.module}/templates/values/node_exporter/values.tftpl.yaml", {
      node_exporter_helm_release_namespace = var.node_exporter.release_namespace
    })
  ]
  upgrade_install  = true
  create_namespace = true
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.node_exporter.release_namespace

  depends_on = [
    helm_release.prometheus_operator,
  ]
}
