local k8s = import 'github.com/jsonnet-libs/k8s-libsonnet/1.35/main.libsonnet';

k8s.core.v1.list.new([
  import 'alloy.jsonnet',
  import 'grafana.jsonnet',
  import 'kube-state-metrics.jsonnet',
  import 'loki.jsonnet',
  import 'mimir.jsonnet',
  import 'node-exporter.jsonnet',
  import 'tempo.jsonnet',
])
