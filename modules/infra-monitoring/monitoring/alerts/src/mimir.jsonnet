local po = import 'github.com/jsonnet-libs/prometheus-operator-libsonnet/0.94/main.libsonnet';
local prometheusRule = po.monitoring.v1.prometheusRule;
local mixin = import 'github.com/grafana/mimir/operations/mimir-mixin/mixin.libsonnet';

local config = mixin {
  _config+:: {
    // The rollout-operator mixin reads these flags from its own config scope, which the Mimir mixin does not populate.
    rollout_operator_zpdb_config_observer_alert_enabled: false,
    rollout_operator_replica_template_observer_alert_enabled: false,
  },
};

prometheusRule.new('mimir')
+ prometheusRule.spec.withGroups(
  config.prometheusAlerts.groups
  + (if std.objectHasAll(config, 'prometheusRules') then config.prometheusRules.groups else [])
)
