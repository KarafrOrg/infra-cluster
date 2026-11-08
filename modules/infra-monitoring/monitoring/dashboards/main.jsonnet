local k8s = import 'github.com/jsonnet-libs/k8s-libsonnet/1.35/main.libsonnet';
local configMap = k8s.core.v1.configMap;
local mixin = import 'github.com/grafana/mimir/operations/mimir-mixin/mixin.libsonnet';

local dashboards = mixin.grafanaDashboards;
local names = [
  'mimir-overview.json',
  'mimir-reads.json',
  'mimir-writes.json',
  'mimir-queries.json',
];

k8s.core.v1.list.new([
  local dashboard = dashboards[name];
  configMap.new(std.strReplace(name, '.json', ''))
  + configMap.metadata.withLabels({ grafana_dashboard: '1' })
  + configMap.metadata.withAnnotations({ grafana_folder: 'infrastructure/mimir' })
  + configMap.withData({
    [name]: std.manifestJson(dashboard {
      templating+: {
        list: [
          if variable.name == 'cluster' then {
            name: 'cluster',
            type: 'constant',
            hide: 2,
            query: '.*',
            current: { text: '.*', value: '.*' },
          } else variable
          for variable in dashboard.templating.list
        ],
      },
    }),
  })
  for name in names
])
