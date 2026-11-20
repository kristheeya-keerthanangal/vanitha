import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vanithabodhini/data/subscriber_export_file.dart';

const channel = MethodChannel('plugins.flutter.io/file_selector');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  String? location;
  late List<MethodCall> calls;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('subscriber-export-');
    location = '${directory.path}/subscribers.json';
    calls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return location;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await directory.delete(recursive: true);
  });

  test('saves exact UTF-8 JSON using the native JSON save dialog', () async {
    const contents = '[{"subscriber_name":"മലയാളം","pincode":"0682001"}]';
    expect(await saveSubscriberExportFile(contents), isTrue);
    expect(await File(location!).readAsString(), contents);
    expect(calls.single.method, 'getSavePath');
    final arguments = calls.single.arguments as Map<dynamic, dynamic>;
    expect(arguments['suggestedName'], 'subscribers.json');
    expect(arguments['acceptedTypeGroups'][0]['extensions'], ['json']);
  });

  test('canceling writes no file', () async {
    location = null;
    expect(await saveSubscriberExportFile('[]'), isFalse);
    expect(await directory.list().toList(), isEmpty);
  });

  test('propagates write errors for the view model to report', () async {
    location = '${directory.path}/missing/subscribers.json';
    await expectLater(
      saveSubscriberExportFile('[]'),
      throwsA(isA<FileSystemException>()),
    );
  });
}
