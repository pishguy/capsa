import 'dart:io';

import 'package:capsa/src/generator/feature_generator.dart';

Future<void> main(
    List<String> args,
    ) async {
  if (args.isEmpty) {
    print(
      'Usage: dart run capsa <feature-name> <path>',
    );
    print('   or: dart run capsa <path>');

    return;
  }

  String featureName;
  String targetPath;

  if (args.length >= 2) {
    featureName = args[0];
    targetPath = args[1];
  } else {
    targetPath = args[0];
    featureName = targetPath
        .split(Platform.pathSeparator)
        .last;
  }

  await FeatureGenerator().generate(
    featureName: featureName,
    targetPath: targetPath,
  );
}