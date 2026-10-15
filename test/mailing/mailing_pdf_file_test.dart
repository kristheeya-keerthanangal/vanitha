import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:vanithabodhini/mailing/mailing_pdf_file.dart';

const channel = MethodChannel('plugins.flutter.io/file_selector');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  String? location;
  late List<MethodCall> calls;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('mailing-pdf-save-');
    location = '${directory.path}/labels.pdf';
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

  test('uses a PDF save dialog and writes the exact document bytes', () async {
    final pdf = pw.Document()
      ..addPage(pw.Page(build: (_) => pw.Text('Mailing label')));
    final bytes = await pdf.save();
    expect(await MailingPdfFile().save(bytes), isTrue);
    expect(await File(location!).readAsBytes(), bytes);
    expect(calls.single.method, 'getSavePath');
    final arguments = calls.single.arguments as Map<dynamic, dynamic>;
    expect(arguments['suggestedName'], 'mailing-labels.pdf');
    expect(arguments['acceptedTypeGroups'][0]['extensions'], ['pdf']);
  });

  test('canceling the save dialog writes no file', () async {
    location = null;
    expect(
      await MailingPdfFile().save(Uint8List.fromList([37, 80, 68, 70])),
      isFalse,
    );
    expect(await directory.list().toList(), isEmpty);
  });

  test(
    'propagates file errors so the page can offer a different location',
    () async {
      location = '${directory.path}/missing-directory/labels.pdf';
      await expectLater(
        MailingPdfFile().save(Uint8List(1)),
        throwsA(isA<FileSystemException>()),
      );
    },
  );
}
