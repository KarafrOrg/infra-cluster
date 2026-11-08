local k8s = import 'github.com/jsonnet-libs/k8s-libsonnet/1.35/main.libsonnet';
local configMap = k8s.core.v1.configMap;
local mixin = (import 'github.com/prometheus/node_exporter/docs/node-mixin/mixin.libsonnet') {
  _config+: {
    nodeExporterSelector: 'job="prometheus-node-exporter"',
  },
};
local dashboards = mixin.grafanaDashboards;

k8s.core.v1.list.new([
  local dashboard = dashboards[name];
  configMap.new(std.strReplace(name, '.json', ''))
  + configMap.metadata.withLabels({ grafana_dashboard: '1' })
  + configMap.metadata.withAnnotations({ grafana_folder: 'infrastructure/node-exporter' })
  + configMap.withData({
    [name]: std.manifestJson(dashboard {
      liveNow: true,
      tags: std.set(dashboard.tags + ['infrastructure', 'node-exporter', 'nodes']),
      templating+: {
        list: [
          if variable.name == 'datasource' then variable { hide: 2 } else variable
          for variable in dashboard.templating.list
        ],
      },
    }),
  })
  for name in std.objectFields(dashboards)
  if name != 'nodes-aix.json' && name != 'nodes-darwin.json'
])
