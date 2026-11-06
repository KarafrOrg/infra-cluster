local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local prometheusRule = po.monitoring.v1.prometheusRule;
local mixin = import 'github.com/adinhodovic/argo-cd-mixin/mixin.libsonnet';

local config = mixin {
  _config+:: {
    grafanaUrl: 'https://grafana.kubernetes.karafra.net',
  },
};

prometheusRule.new('argo-cd')
+ prometheusRule.spec.withGroups(config.prometheusAlerts.groups)
