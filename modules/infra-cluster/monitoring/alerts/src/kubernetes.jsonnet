local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local prometheusRule = po.monitoring.v1.prometheusRule;
local mixin = import 'github.com/kubernetes-monitoring/kubernetes-mixin/mixin.libsonnet';

local config = mixin {
  _config+:: {
    nodeExporterSelector: 'job="prometheus-node-exporter"',
  },
};

local unscraped = [
  'kube-apiserver-slos',
  'kubernetes-system-apiserver',
  'kubernetes-system-scheduler',
  'kubernetes-system-controller-manager',
  'kubernetes-system-kube-proxy',
];

local keep(groups) = [g for g in groups if !std.member(unscraped, g.name)];

prometheusRule.new('kubernetes')
+ prometheusRule.spec.withGroups(
  keep(config.prometheusAlerts.groups)
  + keep(config.prometheusRules.groups)
)
