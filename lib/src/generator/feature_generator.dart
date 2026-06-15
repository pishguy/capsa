import 'dart:io';

class FeatureGenerator {
  Future<void> generate({required String featureName, required String targetPath}) async {
    final pascal = featureName[0].toUpperCase() + featureName.substring(1);
    final root = Directory('${Directory.current.path}/$targetPath');
    final pkg = _packageName();
    final baseImport = targetPath.replaceAll(RegExp(r'^lib/'), pkg.isNotEmpty ? 'package:$pkg/' : '') + '/';

    await root.create(recursive: true);

    final folders = ['view', 'screen_model', 'business', 'repository', 'datasource', 'state', 'model'];
    for (final folder in folders) {
      await Directory('${root.path}/$folder').create();
    }

    await _writeFile('${root.path}/${featureName}.dart', _featureFile(featureName, pascal, targetPath));
    await _writeFile('${root.path}/business/${featureName}_business.dart', _businessFile(featureName, pascal));
    await _writeFile('${root.path}/repository/${featureName}_repository.dart', _repositoryFile(featureName, pascal));
    await _writeFile('${root.path}/datasource/${featureName}_datasource.dart', _datasourceFile(featureName, pascal));
    await _writeFile('${root.path}/model/${featureName}_model.dart', _modelFile(featureName, pascal));
    await _writeFile('${root.path}/state/${featureName}_state.dart', _stateFile(featureName, pascal));
    await _writeFile('${root.path}/screen_model/${featureName}_screen_model.dart', _screenModelFile(featureName, pascal, baseImport));
    await _writeFile('${root.path}/view/${featureName}_screen.dart', _screenFile(featureName, pascal, baseImport));

    print('Feature "$featureName" created at: ${root.path}');
  }

  String _packageName() {
    final pubspec = File('${Directory.current.path}/pubspec.yaml');
    if (!pubspec.existsSync()) return '';
    for (final line in pubspec.readAsLinesSync()) {
      if (line.startsWith('name:')) return line.split(':')[1].trim();
    }
    return '';
  }

  Future<void> _writeFile(String path, String content) async {
    await File(path).writeAsString(content);
  }

  String _featureFile(String name, String pascal, String path) => '''
import 'package:capsa/capsa.dart';

export '${name}.capsa.dart';

@Capsa(path: '$path')
class $pascal {}
''';

  String _businessFile(String name, String pascal) => '''
import 'package:capsa/capsa.dart';

class ${pascal}Business extends Business {
  final Repository repository;

  ${pascal}Business({required this.repository});
}
''';

  String _repositoryFile(String name, String pascal) => '''
import 'package:capsa/capsa.dart';

class ${pascal}Repository extends Repository {
  final Datasource datasource;

  ${pascal}Repository(this.datasource);
}
''';

  String _datasourceFile(String name, String pascal) => '''
import 'package:capsa/capsa.dart';

class ${pascal}Datasource extends Datasource {
  ${pascal}Datasource();
}
''';

  String _modelFile(String name, String pascal) => '''
class ${pascal}Model {
  final String id;

  const ${pascal}Model({required this.id});
}
''';

  String _stateFile(String name, String pascal) => '''
class ${pascal}State {
  final bool isLoading;

  const ${pascal}State({this.isLoading = false});

  ${pascal}State copyWith({bool? isLoading}) {
    return ${pascal}State(isLoading: isLoading ?? this.isLoading);
  }
}
''';

  String _screenModelFile(String name, String pascal, String baseImport) => '''
import 'package:capsa/capsa.dart';
import '${baseImport}state/${name}_state.dart';
import '${baseImport}business/${name}_business.dart';

class ${pascal}ScreenModel extends ScreenModel {
  final ${pascal}Business business;
  final ${pascal}State state;

  ${pascal}ScreenModel({required this.business, required this.state});
}
''';

  String _screenFile(String name, String pascal, String baseImport) => '''
import 'package:flutter/material.dart';
import '${baseImport}screen_model/${name}_screen_model.dart';

class ${pascal}Screen extends StatelessWidget {
  final ${pascal}ScreenModel screenModel;

  const ${pascal}Screen({super.key, required this.screenModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$pascal')),
      body: const Center(child: Text('$pascal Screen')),
    );
  }
}
''';
}
