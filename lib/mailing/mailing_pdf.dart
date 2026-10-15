import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
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
  static const _fontFamily = 'MailingSans';
  static const _pixelsPerPoint = 300 / 72;
  static Future<void>? _fontLoading;

  static Future<void> _loadFont() => _fontLoading ??= () async {
    final loader = FontLoader(_fontFamily)
      ..addFont(rootBundle.load('assets/fonts/NotoSansMalayalam.ttf'));
    await loader.load();
  }();

  String labelText(MailingListEntry entry) =>
      [entry.name, entry.postalAddress ?? '', entry.postalCode ?? '']
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .join('\n')
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n')
          .replaceAll('\t', ' ');

  TextPainter _painter(String text, double fontSize, double width) =>
      TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: _fontFamily,
            fontSize: fontSize,
            height: 1.2,
            color: const ui.Color(0xff000000),
          ),
        ),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
      )..layout(maxWidth: width);

  Future<double?> fittingFontSize(String text, MailingLayout layout) async {
    await _loadFont();
    return _fittingFontSize(text, layout);
  }

  double? _fittingFontSize(String text, MailingLayout layout) {
    final width = layout.contentWidthMm * PdfPageFormat.mm;
    final height = layout.contentHeightMm * PdfPageFormat.mm;
    for (
      var size = MailingLayout.maxFontSize;
      size >= MailingLayout.minFontSize;
      size -= 0.5
    ) {
      final painter = _painter(text, size, width);
      final fits =
          painter.height <= height &&
          painter.computeLineMetrics().every(
            (line) => line.width <= width + 0.001,
          );
      painter.dispose();
      if (fits) return size;
    }
    return null;
  }

  Future<Uint8List> generate({
    required List<MailingListEntry> subscribers,
    required MailingLayout layout,
    required bool cuttingGuides,
  }) async {
    if (subscribers.isEmpty) throw ArgumentError('The mailing list is empty.');
    await _loadFont();
    // Validate every label before creating any pages or raster images.
    final sizes = <double>[];
    final failures = <MailingListEntry>[];
    for (final subscriber in subscribers) {
      final size = _fittingFontSize(labelText(subscriber), layout);
      if (size == null) {
        failures.add(subscriber);
      } else {
        sizes.add(size);
      }
    }
    if (failures.isNotEmpty) throw MailingTextFitFailure(failures);

    final document = pw.Document(
      title: 'Mailing labels',
      creator: 'Vanithabodhini',
    );
    for (var page = 0; page < layout.pageCount(subscribers.length); page++) {
      final labels = <pw.Widget>[];
      final start = page * layout.labelsPerPage;
      final end = math.min(start + layout.labelsPerPage, subscribers.length);
      for (var index = start; index < end; index++) {
        final position = layout.position(index);
        final image = await _renderText(
          labelText(subscribers[index]),
          sizes[index],
          layout,
        );
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
              child: pw.Image(pw.MemoryImage(image), fit: pw.BoxFit.fill),
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

  Future<Uint8List> _renderText(
    String text,
    double fontSize,
    MailingLayout layout,
  ) async {
    final width = layout.contentWidthMm * PdfPageFormat.mm;
    final height = layout.contentHeightMm * PdfPageFormat.mm;
    final painter = _painter(text, fontSize, width);
    final pixelWidth = (width * _pixelsPerPoint).ceil();
    final pixelHeight = (height * _pixelsPerPoint).ceil();
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder)
      ..scale(pixelWidth / width, pixelHeight / height);
    painter.paint(canvas, ui.Offset.zero);
    final picture = recorder.endRecording();
    painter.dispose();
    final image = await picture.toImage(pixelWidth, pixelHeight);
    picture.dispose();
    try {
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      return bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    } finally {
      image.dispose();
    }
  }
}
