local k8s = import 'github.com/jsonnet-libs/k8s-libsonnet/1.35/main.libsonnet';

[
  (import 'alloy.jsonnet')
  + (import 'grafana.jsonnet')
  + (import 'mimir.jsonnet')
  + (import 'node-exporter.jsonnet')
  + (import 'loki.jsonnet').items
  + (import 'tempo.jsonnet').items,
]
