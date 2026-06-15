import 'models/feature_graph.dart';

class CapsaGraphBuilder {
  FeatureGraph build({
    required String path,
    required String className,
  }) {
    final name =
    className.replaceAll(
      'Feature',
      '',
    ).toLowerCase();

    return FeatureGraph(
      name: name,
      path: path,
      layers: [
        const LayerNode(name: 'view'),
        const LayerNode(
          name: 'screen_model',
          dependencies: ['business'],
        ),
        const LayerNode(
          name: 'business',
          dependencies: ['repository'],
        ),
        const LayerNode(
          name: 'repository',
          dependencies: ['datasource'],
        ),
        const LayerNode(name: 'datasource'),
        const LayerNode(name: 'model'),
        const LayerNode(name: 'state'),
      ],
    );
  }
}