local k8s = import 'github.com/jsonnet-libs/k8s-libsonnet/1.35/main.libsonnet';
local configMap = k8s.core.v1.configMap;
local mixin = import 'github.com/grafana/grafana/grafana-mixin/mixin.libsonnet';
local dashboards = mixin.grafanaDashboards;

[
  local dashboard = dashboards[name];
  configMap.new(std.strReplace(name, '.json', ''))
  + configMap.metadata.withLabels({ grafana_dashboard: '1' })
  + configMap.metadata.withAnnotations({ grafana_folder: 'infrastructure/grafana' })
  + configMap.withData({
    [name]: std.manifestJson(dashboard {
      liveNow: true,
      tags: std.set(dashboard.tags + ['infrastructure', 'grafana']),
      templating+: {
        list: [
          if variable.name == 'datasource' then variable { hide: 2 } else
            if variable.name == 'job' then variable { hide: 2 }
            else variable
          for variable in dashboard.templating.list
        ],
      },
    }),
  })
  for name in std.objectFields(dashboards)
]
