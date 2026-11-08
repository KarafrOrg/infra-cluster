local k8s = import 'github.com/jsonnet-libs/k8s-libsonnet/1.35/main.libsonnet';

k8s.core.v1.list.new(
  (import 'alloy.jsonnet').items
  + (import 'grafana.jsonnet')
  + (import 'loki.jsonnet').items
  + (import 'mimir.jsonnet').items
  + (import 'node-exporter.jsonnet')
  + (import 'tempo.jsonnet').items
)
