import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'capsa_generator.dart';

Builder capsaFeatureBuilder(BuilderOptions options) {
  return LibraryBuilder(
    CapsaFeatureGenerator(),
    generatedExtension: '.capsa.dart',
    options: options,
  );
}