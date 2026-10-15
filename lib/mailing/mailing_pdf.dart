import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../data/repositories/subscriber_repository.dart';
import 'mailing_layout.dart';

class MailingTextFitFailure implements Exception {
  MailingTextFitFailure(List<MailingListEntry> subscribers)
    : subscribers = List.unmodifiable(subscribers);

  final List<MailingListEntry> subscribers;
}

class MailingPdf {
  static Future<ByteData>? _fontData;

  Future<pw.Font> _loadFont() async => pw.Font.ttf(
    await (_fontData ??= rootBundle.load(
      'assets/fonts/LiberationSans-Regular.ttf',
    )),
  );

  String labelText(MailingListEntry entry) =>
      [entry.name, entry.postalAddress ?? '', entry.postalCode ?? '']
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .join('\n')
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n')
          .replaceAll('\t', ' ');

  pw.Text _text(String text, double fontSize, pw.Font font) => pw.Text(
    text,
    style: pw.TextStyle(font: font, fontSize: fontSize, height: 1.2),
    textDirection: pw.TextDirection.ltr,
  );

  Future<double?> fittingFontSize(String text, MailingLayout layout) async {
    final font = await _loadFont();
    final document = pw.Document();
    return _fittingFontSize(text, layout, font, _context(document));
  }

  pw.Context _context(pw.Document document) => pw.Context(
    document: document.document,
  ).inheritFromAll([pw.ThemeData.base()]);

  double? _fittingFontSize(
    String text,
    MailingLayout layout,
    pw.Font font,
    pw.Context context,
  ) {
    final width = layout.contentWidthMm * PdfPageFormat.mm;
    final height = layout.contentHeightMm * PdfPageFormat.mm;
    for (
      var size = MailingLayout.maxFontSize;
      size >= MailingLayout.minFontSize;
      size -= 0.5
    ) {
      // Leave height unconstrained so overflowing text cannot appear to fit.
      final widget = _text(text, size, font)
        ..layout(context, pw.BoxConstraints(maxWidth: width));
      if (widget.box!.height <= height) return size;
    }
    return null;
  }

  Future<Uint8List> generate({
    required List<MailingListEntry> subscribers,
    required MailingLayout layout,
    required bool cuttingGuides,
  }) async {
    if (subscribers.isEmpty) throw ArgumentError('The mailing list is empty.');
    final font = await _loadFont();
    final document = pw.Document(
      title: 'Mailing labels',
      creator: 'Vanithabodhini',
    );
    final context = _context(document);
    // Validate every label before creating any pages.
    final sizes = <double>[];
    final failures = <MailingListEntry>[];
    for (final subscriber in subscribers) {
      final size = _fittingFontSize(
        labelText(subscriber),
        layout,
        font,
        context,
      );
      if (size == null) {
        failures.add(subscriber);
      } else {
        sizes.add(size);
      }
    }
    if (failures.isNotEmpty) throw MailingTextFitFailure(failures);

    for (var page = 0; page < layout.pageCount(subscribers.length); page++) {
      final labels = <pw.Widget>[];
      final start = page * layout.labelsPerPage;
      final end = math.min(start + layout.labelsPerPage, subscribers.length);
      for (var index = start; index < end; index++) {
        final position = layout.position(index);
        labels.add(
          pw.Positioned(
            left: position.leftMm * PdfPageFormat.mm,
            top: position.topMm * PdfPageFormat.mm,
            child: pw.Container(
              width: layout.labelSize.widthMm * PdfPageFormat.mm,
              height: layout.labelSize.heightMm * PdfPageFormat.mm,
              decoration: cuttingGuides
                  ? pw.BoxDecoration(
                      border: pw.Border.all(
                        color: PdfColors.grey300,
                        width: 0.25,
                      ),
                    )
                  : null,
              padding: pw.EdgeInsets.all(
                MailingLayout.paddingMm * PdfPageFormat.mm,
              ),
              child: _text(labelText(subscribers[index]), sizes[index], font),
            ),
          ),
        );
      }
      // Explicit pages and fixed positions keep each row and label indivisible.
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            layout.pageWidthMm * PdfPageFormat.mm,
            layout.pageHeightMm * PdfPageFormat.mm,
          ),
          margin: pw.EdgeInsets.zero,
          build: (_) => pw.Stack(children: labels),
        ),
      );
    }
    return document.save();
  }
}
