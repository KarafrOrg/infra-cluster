local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';

g.dashboard.new('Hello World')
+ g.dashboard.withUid('hello-world')
+ g.dashboard.withPanels([
  g.panel.text.new('Hello')
  + g.panel.text.options.withContent('Hello, world!')
  + g.panel.text.panelOptions.withGridPos(h=4, w=12, x=0, y=0),
])
