import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/mailing/mailing_layout.dart';
import 'package:vanithabodhini/mailing/mailing_pdf.dart';
import 'package:vanithabodhini/mailing/mailing_pdf_preview.dart';
import 'package:vanithabodhini/mailing/mailing_pdf_printer.dart';

const channel = MethodChannel('net.nfet.printing');
const codec = StandardMethodCodec();

Future<Object?> fromPlatform(
  String method,
  Map<String, Object?> arguments,
) async {
  final reply = Completer<ByteData?>();
  await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
        channel.name,
        codec.encodeMethodCall(MethodCall(method, arguments)),
        reply.complete,
      );
  return codec.decodeEnvelope((await reply.future)!);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<Map<dynamic, dynamic>> jobs;

  setUp(() async {
    jobs = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'printingInfo') return {'canPrint': true};
          if (call.method == 'printPdf') {
            jobs.add(call.arguments as Map<dynamic, dynamic>);
          }
          return 0;
        });
    await Printing.info();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  Future<MailingPdfPreview> document(MailingOrientation orientation) async {
    final layout = MailingLayout(orientation: orientation);
    final snapshot = MailingPdfSnapshot(
      subscribers: const [
        MailingListEntry(
          subscriberId: 1,
          name: 'Reader',
          postalAddress: 'Street',
          postalCode: '682001',
        ),
      ],
      layout: layout,
      ordering: MailingOrdering.name,
      cuttingGuides: true,
    );
    return MailingPdfPreview(
      snapshot: snapshot,
      bytes: await MailingPdf().generate(
        subscribers: snapshot.subscribers,
        layout: snapshot.layout,
        cuttingGuides: snapshot.cuttingGuides,
      ),
    );
  }

  for (final orientation in MailingOrientation.values) {
    test(
      '$orientation opens the print dialog with exact preview bytes and dimensions',
      () async {
        final preview = await document(orientation);
        final pending = MailingPdfPrinter().printPdf(preview);
        await Future<void>.delayed(Duration.zero);
        final job = jobs.single;
        expect(job.containsKey('printer'), isFalse);
        expect(job['dynamic'], isFalse);
        expect(job['usePrinterSettings'], isFalse);
        expect(
          (job['width'] as double) / PdfPageFormat.mm,
          closeTo(preview.snapshot.layout.pageWidthMm, 0.001),
        );
        expect(
          (job['height'] as double) / PdfPageFormat.mm,
          closeTo(preview.snapshot.layout.pageHeightMm, 0.001),
        );
        for (final format in [
          PdfPageFormat.a4,
          PdfPageFormat.letter.landscape,
        ]) {
          final bytes = await fromPlatform('onLayout', {
            'job': job['job'],
            'width': format.width,
            'height': format.height,
            'marginLeft': 20.0,
            'marginTop': 20.0,
            'marginRight': 20.0,
            'marginBottom': 20.0,
          });
          expect(bytes, preview.bytes);
        }
        await fromPlatform('onCompleted', {
          'job': job['job'],
          'completed': true,
          'error': null,
        });
        expect(await pending, isTrue);
      },
    );
  }

  test('returns cancellation and propagates native printing errors', () async {
    final preview = await document(MailingOrientation.portrait);
    final canceled = MailingPdfPrinter().printPdf(preview);
    await Future<void>.delayed(Duration.zero);
    await fromPlatform('onCompleted', {
      'job': jobs.last['job'],
      'completed': false,
      'error': null,
    });
    expect(await canceled, isFalse);
    final failed = MailingPdfPrinter().printPdf(preview);
    final expectation = expectLater(failed, throwsA('Printer offline'));
    await Future<void>.delayed(Duration.zero);
    await fromPlatform('onCompleted', {
      'job': jobs.last['job'],
      'completed': false,
      'error': 'Printer offline',
    });
    await expectation;
  });
}
