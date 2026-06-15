class FeatureGraph {
  final String name;
  final String path;

  final List<LayerNode> layers;

  const FeatureGraph({
    required this.name,
    required this.path,
    required this.layers,
  });
}

class LayerNode {
  final String name;
  final List<String> dependencies;

  const LayerNode({
    required this.name,
    this.dependencies = const [],
  });
}