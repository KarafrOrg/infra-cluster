local k8s = import 'github.com/jsonnet-libs/k8s-libsonnet/1.35/main.libsonnet';
local configMap = k8s.core.v1.configMap;
local mixin = (import 'github.com/grafana/alloy/operations/alloy-mixin/mixin.libsonnet') {
  _config+: {
    enableLokiLogs: false,
    k8sClusterSelector: 'namespace=~"$namespace"',
  },
};
local dashboards = mixin.grafanaDashboards;
local excludedDashboards = ['alloy-otel-engine-overview.json'];
local hiddenVariables = ['datasource', 'job', 'cluster', 'loki_datasource', 'namespace'];

[
  local dashboard = dashboards[name];
  configMap.new(std.strReplace(name, '.json', ''))
  + configMap.metadata.withLabels({ grafana_dashboard: '1' })
  + configMap.metadata.withAnnotations({ grafana_folder: 'infrastructure/alloy' })
  + configMap.withData({
    [name]: std.manifestJson(dashboard {
      liveNow: true,
      tags: std.set(dashboard.tags + ['infrastructure', 'alloy']),
      templating+: {
        list: [
          if std.member(hiddenVariables, variable.name) then variable { hide: 2 }
          else variable
          for variable in dashboard.templating.list
        ],
      },
    }),
  })
  for name in std.objectFields(dashboards)
  if !std.member(excludedDashboards, name)
]
