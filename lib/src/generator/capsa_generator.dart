import 'package:source_gen/source_gen.dart';
import 'package:build/build.dart';

import '../annotations/capsa.dart';
import 'capsa_graph_builder.dart';

class CapsaFeatureGenerator
    extends GeneratorForAnnotation<Capsa> {
  @override
  String generateForAnnotatedElement(
      element,
      ConstantReader annotation,
      BuildStep buildStep,
      ) {
    final path =
        annotation.peek('path')!.stringValue;

    final graph = CapsaGraphBuilder().build(
      path: path,
      className: element.displayName,
    );

    final buffer = StringBuffer();

    buffer.writeln("import 'package:rearch/rearch.dart';");
    buffer.writeln("import 'business/${graph.name}_business.dart';");
    buffer.writeln("import 'repository/${graph.name}_repository.dart';");
    buffer.writeln("import 'datasource/${graph.name}_datasource.dart';");
    buffer.writeln('');

    buffer.writeln('''
final ${graph.name}BusinessCapsule = capsule((use) {
  return ${_pascal(graph.name)}Business(
    repository: use(${graph.name}RepositoryCapsule),
  );
});

final ${graph.name}RepositoryCapsule = capsule((use) {
  return ${_pascal(graph.name)}Repository(
    use(${graph.name}DatasourceCapsule),
  );
});

final ${graph.name}DatasourceCapsule = capsule((use) {
  return ${_pascal(graph.name)}Datasource();
});
''');

    return buffer.toString();
  }

  String _pascal(String input) {
    return input[0].toUpperCase() + input.substring(1);
  }
}