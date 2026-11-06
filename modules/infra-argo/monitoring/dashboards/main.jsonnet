local k8s = import 'github.com/jsonnet-libs/k8s-libsonnet/1.35/main.libsonnet';
local configMap = k8s.core.v1.configMap;

k8s.core.v1.list.new([
  configMap.new('infra-dashboards')
  + configMap.metadata.withLabels({ grafana_dashboard: '1' })
  + configMap.metadata.withAnnotations({ grafana_folder: 'infrastructure' })
  + configMap.withData({
    'hello-world.json': std.manifestJson(import 'src/hello-world.jsonnet'),
  }),
])
