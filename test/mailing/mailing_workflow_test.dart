import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:vanithabodhini/data/app_database.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/ui/mailing_list/view_models/mailing_list_view_model.dart';

const printChannel = MethodChannel('net.nfet.printing');
const fileChannel = MethodChannel('plugins.flutter.io/file_selector');
const codec = StandardMethodCodec();

Future<Object?> fromPrinter(
  String method,
  Map<String, Object?> arguments,
) async {
  final reply = Completer<ByteData?>();
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        printChannel.name,
        codec.encodeMethodCall(MethodCall(method, arguments)),
        reply.complete,
      );
  return codec.decodeEnvelope((await reply.future)!);
}

List<String> pageStreams(Uint8List bytes) {
  final pages = <String>[];
  for (final match in RegExp(
    r'stream\n(.*?)\nendstream',
    dotAll: true,
  ).allMatches(latin1.decode(bytes))) {
    try {
      final decoded = latin1.decode(zlib.decode(latin1.encode(match[1]!)));
      if (decoded.contains('BT')) pages.add(decoded);
    } on FormatException {
      // Other streams need not use the same compression as drawing commands.
    }
  }
  return pages;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase database;
  late SubscriberRepository repository;
  late MailingListViewModel model;
  late Directory directory;
  late List<Map<dynamic, dynamic>> jobs;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = SubscriberRepository(database);
    directory = await Directory.systemTemp.createTemp('mailing-workflow-');
    jobs = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(printChannel, (call) async {
          if (call.method == 'printingInfo') return {'canPrint': true};
          if (call.method == 'printPdf') {
            jobs.add(call.arguments as Map<dynamic, dynamic>);
          }
          return 0;
        });
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          fileChannel,
          (_) async => '${directory.path}/labels.pdf',
        );
    await Printing.info();
    model = MailingListViewModel(repository);
    await model.refresh();
  });

  tearDown(() async {
    model.dispose();
    await database.close();
    await directory.delete(recursive: true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(printChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(fileChannel, null);
  });

  Future<void> seed() async {
    await database.batch(
      (batch) => batch.insertAll(database.subscribers, [
        for (var i = 1; i <= 33; i++)
          SubscribersCompanion.insert(
            name: switch (i) {
              1 => 'Zally',
              2 => 'Anita',
              3 => 'Bela',
              4 => 'ANITA',
              _ => 'Reader ${(32 - i).toString().padLeft(2, '0')}',
            },
            postalAddress: Value(
              i == 5
                  ? null
                  : i == 6
                  ? ' \t '
                  : i == 7
                  ? List.filled(5, 'Long address line').join('\n')
                  : 'Street $i',
            ),
            postalCode: Value(
              i == 3
                  ? null
                  : i == 1
                  ? '999999'
                  : i == 2 || i == 4
                  ? '110001'
                  : '${682000 + i}',
            ),
            archivedAt: Value(i == 33 ? '2026-10-15T00:00:00Z' : null),
          ),
      ]),
    );
    await model.refresh();
  }

  for (final orientation in MailingOrientation.values) {
    for (final size in MailingLabelSize.values) {
      for (final ordering in MailingOrdering.values) {
        for (final guides in [true, false]) {
          test(
            '$orientation $size $ordering guides=$guides: real data → PDF → save → print',
            () async {
              await seed();
              model.changeOrientation(orientation);
              model.changeLabelSize(size);
              model.changeOrdering(ordering);
              model.changeCuttingGuides(guides);
              expect(model.total, 32);
              expect(model.incompleteCount, 3);
              expect(
                model.rows.map((row) => row.subscriberId),
                ordering == MailingOrdering.name
                    ? [2, 4, for (var i = 32; i >= 5; i--) i, 1, 3]
                    : [2, 4, for (var i = 5; i <= 32; i++) i, 1, 3],
              );
              await model.previewPdf();
              expect(model.previewError, isNull);
              final document = model.preview!;
              final layout = document.snapshot.layout;
              final pages = pageStreams(document.bytes);
              expect(pages, hasLength(document.snapshot.pageCount));
              var labels = 0;
              for (var page = 0; page < pages.length; page++) {
                final count = RegExp(
                  r'\((Reader|Zally|Anita|ANITA|Bela)\)',
                ).allMatches(pages[page]).length;
                expect(count, math.min(layout.labelsPerPage, 32 - labels));
                expect(pages[page].contains(' re S'), guides);
                labels += count;
              }
              expect(labels, 32);
              final boxes = RegExp(
                r'/MediaBox\[0 0 ([\d.]+) ([\d.]+)\]',
              ).allMatches(latin1.decode(document.bytes));
              expect(boxes, hasLength(pages.length));
              for (final box in boxes) {
                expect(
                  double.parse(box[1]!) / PdfPageFormat.mm,
                  closeTo(layout.pageWidthMm, 0.001),
                );
                expect(
                  double.parse(box[2]!) / PdfPageFormat.mm,
                  closeTo(layout.pageHeightMm, 0.001),
                );
              }
              await model.savePdf();
              expect(model.outputMessage, 'PDF saved.');
              expect(
                await File('${directory.path}/labels.pdf').readAsBytes(),
                document.bytes,
              );
              final printing = model.printPdf();
              await Future<void>.delayed(Duration.zero);
              final job = jobs.single;
              expect(job['dynamic'], isFalse);
              expect(job['width'], layout.pageWidthMm * PdfPageFormat.mm);
              expect(job['height'], layout.pageHeightMm * PdfPageFormat.mm);
              final printed = await fromPrinter('onLayout', {
                'job': job['job'],
                'width': PdfPageFormat.letter.width,
                'height': PdfPageFormat.letter.height,
                'marginLeft': 20.0,
                'marginTop': 20.0,
                'marginRight': 20.0,
                'marginBottom': 20.0,
              });
              expect(printed, document.bytes);
              await fromPrinter('onCompleted', {
                'job': job['job'],
                'completed': true,
                'error': null,
              });
              await printing;
              expect(model.outputMessage, 'Print job submitted.');
              expect(identical(model.preview, document), isTrue);
            },
          );
        }
      }
    }
  }

  test('zero subscribers cannot preview, save, or print', () async {
    expect(model.total, 0);
    expect(model.canPreview, isFalse);
    expect(model.canOutput, isFalse);
    await model.previewPdf();
    await model.savePdf();
    await model.printPdf();
    expect(model.preview, isNull);
    expect(jobs, isEmpty);
    expect(await directory.list().toList(), isEmpty);
  });

  test(
    'long addresses block output until a larger label fits, and impossible details remain blocked',
    () async {
      final subscriber = await repository.createSubscriber(
        name: 'Long address',
        postalAddress: List.filled(8, 'Address line').join('\n'),
        postalCode: '682001',
      );
      await model.refresh();
      await model.previewPdf();
      expect(model.fittingFailures.map((row) => row.subscriberId), [
        subscriber.id,
      ]);
      await model.savePdf();
      await model.printPdf();
      expect(jobs, isEmpty);
      expect(await directory.list().toList(), isEmpty);
      model.changeLabelSize(MailingLabelSize.large);
      await model.previewPdf();
      expect(model.canOutput, isTrue);
      await model.savePdf();
      expect(model.outputMessage, 'PDF saved.');
      await repository.updateSubscriber(
        subscriber.copyWith(
          postalAddress: Value(List.filled(100, 'Address line').join('\n')),
        ),
      );
      await model.refresh();
      expect(model.preview, isNull);
      await model.previewPdf();
      expect(model.canOutput, isFalse);
      expect(model.fittingFailures, hasLength(1));
    },
  );
}
