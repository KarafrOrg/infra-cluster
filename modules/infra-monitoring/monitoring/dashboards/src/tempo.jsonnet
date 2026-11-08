local k8s = import 'github.com/jsonnet-libs/k8s-libsonnet/1.35/main.libsonnet';
local configMap = k8s.core.v1.configMap;
local mixin = import 'github.com/grafana/tempo/operations/tempo-mixin/mixin.libsonnet';
local dashboards = mixin.grafanaDashboards;

k8s.core.v1.list.new([
  local dashboard = dashboards[name];
  configMap.new(std.strReplace(name, '.json', ''))
  + configMap.metadata.withLabels({ grafana_dashboard: '1' })
  + configMap.metadata.withAnnotations({ grafana_folder: 'infrastructure/tempo' })
  + configMap.withData({ [name]: std.manifestJson(dashboard) })
  for name in std.objectFields(dashboards)
])
