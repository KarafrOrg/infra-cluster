local k8s = import 'github.com/jsonnet-libs/k8s-libsonnet/1.35/main.libsonnet';
local configMap = k8s.core.v1.configMap;
local mixin = import 'github.com/grafana/mimir/operations/mimir-mixin/mixin.libsonnet';

local dashboards = mixin.grafanaDashboards;
local names = std.objectFields(dashboards);

k8s.core.v1.list.new([
  local dashboard = dashboards[name];
  configMap.new(std.strReplace(name, '.json', ''))
  + configMap.metadata.withLabels({ grafana_dashboard: '1' })
  + configMap.metadata.withAnnotations({ grafana_folder: 'infra/mimir' })
  + configMap.withData({
    [name]: std.manifestJson(dashboard {
      liveNow: true,
      templating+: {
        list: [
          if variable.name == 'cluster' then {
            name: 'cluster',
            type: 'constant',
            hide: 2,
            query: '.*',
            current: { text: '.*', value: '.*' },
          } else if variable.name == 'datasource' then variable + {
            type: 'constant',
            hide: 2,
            query: 'mimir',
            current: { text: 'Mimir', value: 'mimir' },
          } else if variable.name == 'namespace' then variable + {
            type: 'constant',
            hide: 2,
            query: 'infra-monitoring',
            current: { text: 'infra-monitoring', value: 'infra-monitoring' },
          } else variable
          for variable in dashboard.templating.list
        ],
      },
    }),
  })
  for name in names
])
