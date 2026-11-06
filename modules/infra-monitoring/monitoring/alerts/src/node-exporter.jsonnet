local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local prometheusRule = po.monitoring.v1.prometheusRule;
local mixin = import 'github.com/prometheus/node_exporter/docs/node-mixin/mixin.libsonnet';

local config = mixin {
  _config+:: {
    nodeExporterSelector: 'job="prometheus-node-exporter"',
  },
};

prometheusRule.new('node-exporter')
+ prometheusRule.spec.withGroups(
  config.prometheusAlerts.groups
  + (if std.objectHasAll(config, 'prometheusRules') then config.prometheusRules.groups else [])
)
