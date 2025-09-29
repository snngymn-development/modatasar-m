#!/usr/bin/env dart
// OpenAPI code generation script
//
// Usage:
// ```bash
// dart run scripts/generate_api.dart
// ```
// This script generates Dart client code from OpenAPI specification
// and creates DTOs, models, and API client classes.

import 'dart:io';

void main(List<String> args) async {
  // ignore: avoid_print
  print('🚀 Generating API client from OpenAPI specification...');

  // Check if openapi-generator is installed
  final result = await Process.run('openapi-generator', ['version']);
  if (result.exitCode != 0) {
    // ignore: avoid_print
    print('❌ OpenAPI Generator not found. Installing...');
    await _installOpenApiGenerator();
  }

  // Generate Dart client
  await _generateDartClient();

  // ignore: avoid_print
  print('✅ API client generation completed!');
}

Future<void> _installOpenApiGenerator() async {
  // Install via npm (requires Node.js)
  final installResult = await Process.run('npm', [
    'install',
    '-g',
    '@openapitools/openapi-generator-cli',
  ]);
  if (installResult.exitCode != 0) {
    // ignore: avoid_print
    print(
      '❌ Failed to install OpenAPI Generator. Please install Node.js and npm first.',
    );
    exit(1);
  }
}

Future<void> _generateDartClient() async {
  // Try npx first, then fallback to direct command
  List<String> command = [
    'npx',
    '@openapitools/openapi-generator-cli',
    'generate',
  ];
  List<String> args = [
    '-i',
    'api/openapi.yaml',
    '-g',
    'dart-dio',
    '-o',
    'lib/generated/api',
    '--additional-properties=pubName=deneme1_api,packageName=deneme1_api',
  ];

  final result = await Process.run(command[0], [
    ...command.sublist(1),
    ...args,
  ]);

  if (result.exitCode != 0) {
    // ignore: avoid_print
    print('❌ Failed to generate API client:');
    // ignore: avoid_print
    print(result.stderr);
    // ignore: avoid_print
    print(
      '💡 Note: OpenAPI Generator requires Java 11+. Please install Java 11+ and try again.',
    );
    exit(1);
  }

  // ignore: avoid_print
  print('📁 Generated files in lib/generated/api/');
}
