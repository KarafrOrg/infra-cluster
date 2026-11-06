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
}
