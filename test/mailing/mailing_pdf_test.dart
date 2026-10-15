import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/mailing/mailing_layout.dart';
import 'package:vanithabodhini/mailing/mailing_pdf.dart';

MailingListEntry reader(int id, {String? address = 'Main Street'}) =>
    MailingListEntry(
      subscriberId: id,
      name: 'Reader $id',
      postalAddress: address,
      postalCode: '682001',
    );

// Inspect the producer's PDF dictionaries and decompressed drawing commands.
List<String> contentStreams(Uint8List bytes) {
  final source = latin1.decode(bytes);
  final streams = <String>[];
  for (final match in RegExp(
    r'stream\n(.*?)\nendstream',
    dotAll: true,
  ).allMatches(source)) {
    try {
      final decoded = latin1.decode(zlib.decode(latin1.encode(match[1]!)));
      if (decoded.contains('BT')) streams.add(decoded);
    } on FormatException {
      // Font streams may not use zlib compression.
    }
  }
  return streams;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final generator = MailingPdf();

  test('label text omits missing details and UI warnings', () {
    expect(
      generator.labelText(
        const MailingListEntry(
          subscriberId: 1,
          name: '  Anita  ',
          postalAddress: ' \t ',
          postalCode: null,
        ),
      ),
      'Anita',
    );
    expect(
      generator.labelText(reader(2, address: 'First\r\nSecond')),
      'Reader 2\nFirst\nSecond\n682001',
    );
  });

  test('refuses an empty document', () async {
    await expectLater(
      generator.generate(
        subscribers: [],
        layout: const MailingLayout(),
        cuttingGuides: true,
      ),
      throwsArgumentError,
    );
  });

  test(
    '930 addresses produce a complete document beyond the first page',
    () async {
      const layout = MailingLayout();
      final bytes = await generator.generate(
        subscribers: List.generate(930, (i) => reader(i + 1)),
        layout: layout,
        cuttingGuides: true,
      );
      final pages = contentStreams(bytes);
      expect(latin1.decode(bytes), isNot(contains('/Subtype/Image')));
      expect(bytes.length, lessThan(500000));
      expect(pages, hasLength(35));
      final labels = pages
          .map((page) => RegExp(r'\(Reader\)').allMatches(page).length)
          .toList();
      expect(labels.take(34), everyElement(27));
      expect(labels.last, 12);
      expect(labels.reduce((a, b) => a + b), 930);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );

  for (final orientation in MailingOrientation.values) {
    for (final size in MailingLabelSize.values) {
      test(
        'PDF $orientation $size preserves physical dimensions and whole rows',
        () async {
          final layout = MailingLayout(
            orientation: orientation,
            labelSize: size,
          );
          final count = layout.labelsPerPage + layout.columns + 1;
          final rows = List.generate(count, (i) => reader(i + 1));
          final bytes = await generator.generate(
            subscribers: rows,
            layout: layout,
            cuttingGuides: true,
          );
          final source = latin1.decode(bytes);
          expect(source, startsWith('%PDF-'));
          final mediaBoxes = RegExp(
            r'/MediaBox\[0 0 ([\d.]+) ([\d.]+)\]',
          ).allMatches(source).toList();
          expect(mediaBoxes, hasLength(2));
          for (final box in mediaBoxes) {
            expect(
              double.parse(box[1]!) / PdfPageFormat.mm,
              closeTo(layout.pageWidthMm, 0.001),
            );
            expect(
              double.parse(box[2]!) / PdfPageFormat.mm,
              closeTo(layout.pageHeightMm, 0.001),
            );
          }
          final pages = contentStreams(bytes);
          expect(pages, hasLength(2));
          final drawings = pages
              .map((page) => RegExp(r'\(Reader\)').allMatches(page).length)
              .toList();
          expect(drawings, [layout.labelsPerPage, layout.columns + 1]);

          for (var pageIndex = 0; pageIndex < pages.length; pageIndex++) {
            final page = pages[pageIndex];
            final borders = RegExp(
              r'0 0 ([\d.]+) ([\d.]+) re S',
            ).allMatches(page).toList();
            expect(borders, hasLength(drawings[pageIndex]));
            for (final border in borders) {
              expect(
                double.parse(border[1]!) / PdfPageFormat.mm,
                closeTo(size.widthMm, 0.001),
              );
              expect(
                double.parse(border[2]!) / PdfPageFormat.mm,
                closeTo(size.heightMm, 0.001),
              );
            }
            // Each label's translation precedes its local border and text.
            final positions = RegExp(
              r'q 1 0 0 1 ([\d.]+) ([\d.]+) cm q 1 0 0 1 0 0 cm q 1 0 0 1 0 0 cm 0 j',
            ).allMatches(page).toList();
            expect(positions, hasLength(drawings[pageIndex]));
            for (var i = 0; i < positions.length; i++) {
              final expected = layout.position(
                pageIndex * layout.labelsPerPage + i,
              );
              expect(
                double.parse(positions[i][1]!) / PdfPageFormat.mm,
                closeTo(expected.leftMm, 0.001),
              );
              final top =
                  layout.pageHeightMm -
                  size.heightMm -
                  double.parse(positions[i][2]!) / PdfPageFormat.mm;
              expect(top, closeTo(expected.topMm, 0.001));
            }
          }
        },
      );
    }
  }

  test(
    'draws light guides only when enabled and includes incomplete subscribers',
    () async {
      final rows = [reader(1, address: null)];
      final withGuides = await generator.generate(
        subscribers: rows,
        layout: const MailingLayout(),
        cuttingGuides: true,
      );
      final withoutGuides = await generator.generate(
        subscribers: rows,
        layout: const MailingLayout(),
        cuttingGuides: false,
      );
      expect(contentStreams(withGuides).single, contains('0.25 w'));
      expect(
        contentStreams(withGuides).single,
        contains('0.87843 0.87843 0.87843 RG'),
      );
      expect(contentStreams(withoutGuides).single, isNot(contains(' re S')));
      expect(
        RegExp(r'\(Reader\)').allMatches(contentStreams(withoutGuides).single),
        hasLength(1),
      );
    },
  );

  test(
    'uses native English text with built-in Helvetica and a fitting size',
    () async {
      const entry = MailingListEntry(
        subscriberId: 1,
        name: 'Sally',
        postalAddress: 'Kochi\nKerala',
        postalCode: '682001',
      );
      final bytes = await generator.generate(
        subscribers: [entry],
        layout: const MailingLayout(),
        cuttingGuides: false,
      );
      expect(contentStreams(bytes), hasLength(1));
      final source = latin1.decode(bytes);
      expect(source, isNot(contains('/Subtype/Image')));
      expect(source, contains('/BaseFont/Helvetica'));
      expect(source, isNot(contains('/FontFile')));
      expect(contentStreams(bytes).single, contains('(Sally)'));
      expect(contentStreams(bytes).single, contains('(Kerala)'));
      expect(
        await generator.fittingFontSize(
          generator.labelText(entry),
          const MailingLayout(),
        ),
        inInclusiveRange(8, 12),
      );
    },
  );

  test(
    'shrinks long text, blocks every unresolved failure, and fits a larger label',
    () async {
      const small = MailingLayout();
      const large = MailingLayout(labelSize: MailingLabelSize.large);
      final moderate = reader(
        1,
        address: List.filled(5, 'Address line').join('\n'),
      );
      await generator.generate(
        subscribers: [reader(9)],
        layout: small,
        cuttingGuides: false,
      );
      final fontSize = await generator.fittingFontSize(
        generator.labelText(moderate),
        small,
      );
      expect(fontSize, isNotNull);
      expect(fontSize, lessThan(12));
      final needsLarger = reader(2, address: List.filled(8, 'Line').join('\n'));
      final impossible = reader(
        3,
        address: List.filled(100, 'Line').join('\n'),
      );
      await expectLater(
        generator.generate(
          subscribers: [reader(1), needsLarger, impossible],
          layout: small,
          cuttingGuides: true,
        ),
        throwsA(
          isA<MailingTextFitFailure>().having(
            (error) =>
                error.subscribers.map((row) => row.subscriberId).toList(),
            'affected subscriber IDs',
            [2, 3],
          ),
        ),
      );
      final fitted = await generator.generate(
        subscribers: [needsLarger],
        layout: large,
        cuttingGuides: false,
      );
      expect(contentStreams(fitted), hasLength(1));
    },
  );
}
