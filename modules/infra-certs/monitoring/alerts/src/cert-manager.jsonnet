local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local prometheusRule = po.monitoring.v1.prometheusRule;
local mixin = import 'github.com/imusmanmalik/cert-manager-mixin/mixin.libsonnet';

local config = mixin {
  _config+:: {
    grafanaExternalUrl: 'https://grafana.kubernetes.karafra.net',
  },
};

prometheusRule.new('cert-manager')
+ prometheusRule.spec.withGroups(config.prometheusAlerts.groups)
