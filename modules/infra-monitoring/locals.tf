locals {
  grafana_postgres_documents = split("\n---\n", templatefile("${path.module}/templates/manifests/grafana-postgres.tftpl.yaml", {
    name      = local.grafana_postgres_name
    namespace = var.grafana.release_namespace
  }))
  grafana_postgres_manifests = {
    password        = local.grafana_postgres_documents[0]
    external_secret = local.grafana_postgres_documents[1]
    service         = local.grafana_postgres_documents[2]
    statefulset     = local.grafana_postgres_documents[3]
  }

  istio_pod_monitors = {
    ztunnel = {
      selector = { app = "ztunnel" }
      endpoint = { port = "ztunnel-stats", path = "/stats/prometheus" }
    }
    istio-cni-node = {
      selector = { "k8s-app" = "istio-cni-node" }
      endpoint = { port = "metrics", path = "/metrics" }
    }
    istiod = {
      selector = { istio = "pilot" }
      endpoint = { port = "http-monitoring", path = "/metrics" }
    }
  }
  monitoring_gcs_enabled = {
    loki  = var.monitoring_gcs != null ? var.monitoring_gcs.loki_enabled && var.loki.enabled : false
    mimir = var.monitoring_gcs != null ? var.monitoring_gcs.mimir_enabled && var.mimir.enabled : false
    tempo = var.monitoring_gcs != null ? var.monitoring_gcs.tempo_enabled && var.tempo.enabled : false
  }
  monitoring_namespaces = {
    loki  = var.loki.release_namespace
    mimir = var.mimir.release_namespace
    tempo = var.tempo.release_namespace
  }
  monitoring_gcs_volumes = {
    for service in ["loki", "mimir", "tempo"] : service => [
      {
        name = "gcp-identity"
        projected = {
          sources = [
            { serviceAccountToken = { audience = "sts.googleapis.com", expirationSeconds = 3600, path = "token" } },
            { configMap = { name = "${service}-gcp-identity" } }
          ]
        }
      }
    ]
  }
  monitoring_gcs_mounts = [{ name = "gcp-identity", mountPath = "/var/run/gcp-identity", readOnly = true }]
  monitoring_gcs_env    = [{ name = "GOOGLE_APPLICATION_CREDENTIALS", value = "/var/run/gcp-identity/credentials.json" }]
}
