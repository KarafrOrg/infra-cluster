local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local prometheusRule = po.monitoring.v1.prometheusRule;
local mixin = import 'github.com/grafana/grafana/grafana-mixin/mixin.libsonnet';

prometheusRule.new('grafana')
+ prometheusRule.spec.withGroups(
  mixin.prometheusAlerts.groups
  + (if std.objectHasAll(mixin, 'prometheusRules') then mixin.prometheusRules.groups else [])
)
