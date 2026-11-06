local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local prometheusRule = po.monitoring.v1.prometheusRule;
local mixin = import 'github.com/grafana/loki/production/loki-mixin/mixin.libsonnet';

prometheusRule.new('loki')
+ prometheusRule.spec.withGroups(
  mixin.prometheusAlerts.groups
  + (if std.objectHasAll(mixin, 'prometheusRules') then mixin.prometheusRules.groups else [])
)
