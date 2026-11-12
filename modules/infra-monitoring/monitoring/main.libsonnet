local k8s = import 'github.com/jsonnet-libs/k8s-libsonnet/1.35/main.libsonnet';
local List = k8s.core.v1.list;

List.new(
  (import 'alerts/main.jsonnet').items + (import 'dashboards/main.jsonnet')
)
