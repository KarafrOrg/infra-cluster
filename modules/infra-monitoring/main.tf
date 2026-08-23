resource "kubectl_manifest" "namespace" {
  for_each = toset([
    for ns in [
      var.metrics_server.enabled ? var.metrics_server.release_namespace : null,
      var.node_exporter.enabled ? var.node_exporter.release_namespace : null,
      var.prometheus_operator_crds.enabled ? var.prometheus_operator_crds.release_namespace : null,
      var.kube_state_metrics.enabled ? var.kube_state_metrics.release_namespace : null,
      var.eck_monitoring.enabled ? var.eck_monitoring.release_namespace : null,
      var.alloy.enabled ? var.alloy.release_namespace : null,
    ] : ns if ns != null
  ])
  yaml_body = templatefile("${path.module}/templates/manifests/namespace.tftpl.yaml", {
    infra_monitoring_namespace = each.value
  })
}

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
  create_namespace = false
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.metrics_server.release_namespace
}

resource "helm_release" "prometheus_operator_crds" {
  chart      = "prometheus-operator-crds"
  name       = var.prometheus_operator_crds.release_name
  repository = var.prometheus_operator_crds.release_repository
  values = [
    templatefile("${path.module}/templates/values/prometheus_operator_crds/values.tftpl.yaml", {
      prometheus_operator_crds_helm_release_namespace = var.prometheus_operator_crds.release_namespace
    })
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.prometheus_operator_crds.release_namespace
  count            = var.prometheus_operator_crds.enabled ? 1 : 0
}

resource "helm_release" "node_exporter" {
  count      = var.node_exporter.enabled ? 1 : 0
  chart      = "prometheus-node-exporter"
  name       = var.node_exporter.release_name
  repository = var.node_exporter.release_repository
  values = [
    templatefile("${path.module}/templates/values/node_exporter/values.tftpl.yaml", {
      node_exporter_helm_release_namespace = var.node_exporter.release_namespace
    })
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.node_exporter.release_namespace

  depends_on = [
    helm_release.prometheus_operator_crds,
  ]
}

resource "helm_release" "kube_state_metrics" {
  count      = var.kube_state_metrics.enabled ? 1 : 0
  chart      = "kube-state-metrics"
  name       = var.kube_state_metrics.release_name
  repository = var.kube_state_metrics.release_repository
  values = [
    templatefile("${path.module}/templates/values/kube_state_metrics/values.tftpl.yaml", {
      kube_state_metrics_helm_release_namespace = var.kube_state_metrics.release_namespace
    })
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.kube_state_metrics.release_namespace

  depends_on = [
    helm_release.prometheus_operator_crds,
  ]
}

resource "helm_release" "eck_monitoring" {
  count      = var.eck_monitoring.enabled ? 1 : 0
  chart      = "eck-stack"
  name       = var.eck_monitoring.release_name
  repository = var.eck_monitoring.release_repository
  values = [
    templatefile("${path.module}/templates/values/eck_stack/values.tftpl.yaml", {
      eck_monitoring_helm_release_namespace = var.eck_monitoring.release_namespace
    }),
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.eck_monitoring.release_namespace
}

resource "kubectl_manifest" "eck_monitoring_user_role" {
  yaml_body = templatefile("${path.module}/templates/manifests/eck_stack/role.tftpl.yaml", {
    alloy_helm_release_namespace = var.eck_monitoring.release_namespace
  })
  depends_on = [helm_release.eck_monitoring]
}

resource "kubectl_manifest" "eck_monitoring_otel_user" {
  yaml_body = templatefile("${path.module}/templates/manifests/eck_stack/user.tftpl.yaml", {
    alloy_helm_release_namespace = var.alloy.release_namespace
  })
  depends_on = [kubectl_manifest.eck_monitoring_otel_user]
}

resource "helm_release" "alloy" {
  chart      = "alloy"
  name       = var.alloy.release_name
  repository = var.alloy.release_repository
  values = [
    templatefile("${path.module}/templates/values/alloy/values.tftpl.yaml", {
      alloy_helm_release_namespace = var.alloy.release_namespace
    }),
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.alloy.release_namespace

  depends_on = [
    helm_release.eck_monitoring,
    kubectl_manifest.eck_monitoring_otel_user
  ]
}
