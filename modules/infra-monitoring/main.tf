resource "kubectl_manifest" "namespace" {
  for_each = toset([
    for ns in [
      var.metrics_server.enabled ? var.metrics_server.release_namespace : null,
      var.node_exporter.enabled ? var.node_exporter.release_namespace : null,
      var.prometheus_operator_crds.enabled ? var.prometheus_operator_crds.release_namespace : null,
      var.kube_state_metrics.enabled ? var.kube_state_metrics.release_namespace : null,
      var.alloy.enabled ? var.alloy.release_namespace : null,
      var.mimir.enabled ? var.mimir.release_namespace : null,
      var.grafana.enabled ? var.grafana.release_namespace : null,
      var.loki.enabled ? var.loki.release_namespace : null,
      var.tempo.enabled ? var.tempo.release_namespace : null,
      var.pyroscope.enabled ? var.pyroscope.release_namespace : null,
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

resource "helm_release" "alloy" {
  chart      = "alloy"
  name       = var.alloy.release_name
  repository = var.alloy.release_repository
  values = [
    templatefile("${path.module}/templates/values/alloy/values.tftpl.yaml", {
      alloy_helm_release_namespace = var.alloy.release_namespace
      mimir_release_name           = var.mimir.release_name
      mimir_namespace              = var.mimir.release_namespace
      loki_release_name            = var.loki.release_name
      loki_namespace               = var.loki.release_namespace
      tempo_release_name           = var.tempo.release_name
      tempo_namespace              = var.tempo.release_namespace
    }),
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  # Adding Alloy's persistent storage changes the StatefulSet's immutable claim templates.
  force_update = true
  namespace    = var.alloy.release_namespace

  depends_on = [
    helm_release.mimir,
    helm_release.loki,
    helm_release.tempo
  ]
}

resource "helm_release" "mimir" {
  count      = var.mimir.enabled ? 1 : 0
  chart      = "mimir-distributed"
  name       = var.mimir.release_name
  repository = var.mimir.release_repository
  values = [
    templatefile("${path.module}/templates/values/mimir/values.tftpl.yaml", {
      mimir_helm_release_namespace = var.mimir.release_namespace
    }),
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  # Bucket-creating MinIO hooks only run after install, but pods need the buckets to become ready,
  # so waiting for readiness (or atomic) would deadlock until timeout.
  wait            = false
  cleanup_on_fail = true
  atomic          = false
  namespace       = var.mimir.release_namespace

  depends_on = [kubectl_manifest.namespace]
}

resource "helm_release" "grafana" {
  count      = var.grafana.enabled ? 1 : 0
  chart      = "grafana"
  name       = var.grafana.release_name
  repository = var.grafana.release_repository
  values = [
    templatefile("${path.module}/templates/values/grafana/values.tftpl.yaml", {
      mimir_release_name     = var.mimir.release_name
      mimir_namespace        = var.mimir.release_namespace
      loki_release_name      = var.loki.release_name
      loki_namespace         = var.loki.release_namespace
      tempo_release_name     = var.tempo.release_name
      tempo_namespace        = var.tempo.release_namespace
      root_url               = var.grafana.root_url
      postgres_host          = local.grafana_postgres_name
      alloy_release_name     = var.alloy.release_name
      alloy_namespace        = var.alloy.release_namespace
      github_oauth_enabled   = var.grafana.github_oauth.enabled
      carto_enabled          = var.grafana.carto.enabled
      github_org             = var.grafana.github_oauth.org
      github_admin_team      = var.grafana.github_oauth.admin_team
      github_viewer_team     = var.grafana.github_oauth.viewer_team
      pyroscope_enabled      = var.pyroscope.enabled
      pyroscope_release_name = var.pyroscope.release_name
      pyroscope_namespace    = var.pyroscope.release_namespace
    }),
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.grafana.release_namespace

  depends_on = [
    kubectl_manifest.namespace,
    helm_release.mimir,
    helm_release.loki,
    helm_release.tempo,
    helm_release.pyroscope,
    kubectl_manifest.grafana_github_oauth,
    kubectl_manifest.grafana_carto,
    kubectl_manifest.grafana_postgres,
  ]
}

locals {
  grafana_postgres_name = "${var.grafana.release_name}-postgres"
}

# Shared session/user store so Grafana can run multiple replicas behind one login.
# Keys are static so for_each stays plannable; only the values depend on rendered YAML.
moved {
  from = kubectl_manifest.grafana_postgres["/apis/generators.external-secrets.io/v1alpha1/namespaces/infra-monitoring/passwords/grafana-postgres-password"]
  to   = kubectl_manifest.grafana_postgres["password"]
}

moved {
  from = kubectl_manifest.grafana_postgres["/apis/external-secrets.io/v1/namespaces/infra-monitoring/externalsecrets/grafana-postgres"]
  to   = kubectl_manifest.grafana_postgres["external_secret"]
}

moved {
  from = kubectl_manifest.grafana_postgres["/api/v1/namespaces/infra-monitoring/services/grafana-postgres"]
  to   = kubectl_manifest.grafana_postgres["service"]
}

moved {
  from = kubectl_manifest.grafana_postgres["/apis/apps/v1/namespaces/infra-monitoring/statefulsets/grafana-postgres"]
  to   = kubectl_manifest.grafana_postgres["statefulset"]
}

resource "kubectl_manifest" "grafana_postgres" {
  for_each   = var.grafana.enabled ? local.grafana_postgres_manifests : {}
  yaml_body  = each.value
  depends_on = [kubectl_manifest.namespace]
}

resource "kubectl_manifest" "grafana_github_oauth" {
  count = var.grafana.enabled && var.grafana.github_oauth.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/grafana-github-oauth-external-secret.tftpl.yaml", {
    namespace                   = var.grafana.release_namespace
    secret_store_name           = var.grafana.github_oauth.secret_store_name
    client_id_gcp_secret_id     = var.grafana.github_oauth.client_id_gcp_secret_id
    client_secret_gcp_secret_id = var.grafana.github_oauth.client_secret_gcp_secret_id
  })
  depends_on = [kubectl_manifest.namespace]
}

resource "kubectl_manifest" "grafana_carto" {
  count = var.grafana.enabled && var.grafana.carto.enabled ? 1 : 0
  yaml_body = templatefile("${path.module}/templates/manifests/grafana-carto-external-secret.tftpl.yaml", {
    namespace             = var.grafana.release_namespace
    secret_store_name     = var.grafana.carto.secret_store_name
    api_key_gcp_secret_id = var.grafana.carto.api_key_gcp_secret_id
  })
  depends_on = [kubectl_manifest.namespace]
}

resource "helm_release" "pyroscope" {
  count      = var.pyroscope.enabled ? 1 : 0
  chart      = "pyroscope"
  name       = var.pyroscope.release_name
  repository = var.pyroscope.release_repository
  values = [
    templatefile("${path.module}/templates/values/pyroscope/values.tftpl.yaml", {}),
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.pyroscope.release_namespace

  depends_on = [kubectl_manifest.namespace]
}

resource "helm_release" "alloy_ebpf" {
  count      = var.pyroscope.enabled ? 1 : 0
  chart      = "alloy"
  name       = "${var.alloy.release_name}-ebpf"
  repository = var.alloy.release_repository
  values = [
    templatefile("${path.module}/templates/values/alloy-ebpf/values.tftpl.yaml", {
      pyroscope_release_name = var.pyroscope.release_name
      pyroscope_namespace    = var.pyroscope.release_namespace
      alloy_release_name     = var.alloy.release_name
      alloy_namespace        = var.alloy.release_namespace
      monitoring_namespaces  = "{${join(",", distinct([var.alloy.release_namespace, var.mimir.release_namespace, var.loki.release_namespace, var.tempo.release_namespace, var.grafana.release_namespace, var.pyroscope.release_namespace]))}}"
    }),
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  wait             = true
  cleanup_on_fail  = true
  atomic           = true
  namespace        = var.pyroscope.release_namespace

  depends_on = [helm_release.pyroscope, helm_release.alloy]
}

# Dedicated Gateway + Envoy (Faro injection) in front of Grafana.
module "grafana_published_service" {
  source = "../published-service"
  count  = var.grafana.enabled ? 1 : 0

  name          = var.grafana.release_name
  namespace     = var.grafana.release_namespace
  hostnames     = ["grafana.kubernetes.karafra.net"]
  upstream_host = "${var.grafana.release_name}.${var.grafana.release_namespace}.svc.cluster.local"
  faro_host     = "${var.alloy.release_name}.${var.alloy.release_namespace}.svc.cluster.local"

  private_gateway = var.private_gateway

  gateway_class_name           = var.gateway_class_name
  tunnel_replicas              = var.gateway_tunnel_replicas
  cloudflare_account_id_secret = var.gateway_cloudflare_account_id_secret
  cloudflare_api_token_secret  = var.gateway_cloudflare_api_token_secret

  depends_on = [helm_release.grafana, kubectl_manifest.namespace]
}

resource "helm_release" "loki" {
  count      = var.loki.enabled ? 1 : 0
  chart      = "loki"
  name       = var.loki.release_name
  repository = var.loki.release_repository
  values = [
    templatefile("${path.module}/templates/values/loki/values.tftpl.yaml", {
    }),
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  # Bucket-creating MinIO hooks only run after install, but pods need the buckets to become ready,
  # so waiting for readiness (or atomic) would deadlock until timeout.
  wait            = false
  cleanup_on_fail = true
  atomic          = false
  namespace       = var.loki.release_namespace

  depends_on = [kubectl_manifest.namespace]
}

resource "helm_release" "tempo" {
  count      = var.tempo.enabled ? 1 : 0
  chart      = "tempo-distributed"
  name       = var.tempo.release_name
  repository = var.tempo.release_repository
  values = [
    templatefile("${path.module}/templates/values/tempo/values.tftpl.yaml", {
      release_name = var.tempo.release_name
    }),
  ]
  upgrade_install  = true
  create_namespace = false
  timeout          = 900
  # Bucket-creating MinIO hooks only run after install, but pods need the buckets to become ready,
  # so waiting for readiness (or atomic) would deadlock until timeout.
  wait            = false
  cleanup_on_fail = true
  atomic          = false
  namespace       = var.tempo.release_namespace

  depends_on = [kubectl_manifest.namespace]
}
