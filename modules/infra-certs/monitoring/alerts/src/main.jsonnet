local k8s = import 'github.com/jsonnet-libs/k8s-libsonnet/1.35/main.libsonnet';

k8s.core.v1.list.new([
  import 'cert-manager/main.jsonnet',
  import 'certificates/main.jsonnet',
])
