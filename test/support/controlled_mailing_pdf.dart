import 'dart:async';
import 'dart:typed_data';

import 'package:vanithabodhini/data/repositories/subscriber_repository.dart';
import 'package:vanithabodhini/mailing/mailing_layout.dart';
import 'package:vanithabodhini/mailing/mailing_pdf.dart';
import 'package:vanithabodhini/mailing/mailing_pdf_file.dart';
import 'package:vanithabodhini/mailing/mailing_pdf_preview.dart';
import 'package:vanithabodhini/mailing/mailing_pdf_printer.dart';

class ControlledMailingPdf extends MailingPdf {
  final requests =
      <
        ({
          List<MailingListEntry> subscribers,
          MailingLayout layout,
          bool cuttingGuides,
          Completer<Uint8List> result,
        })
      >[];

  @override
  Future<Uint8List> generate({
    required List<MailingListEntry> subscribers,
    required MailingLayout layout,
    required bool cuttingGuides,
  }) {
    final result = Completer<Uint8List>();
    requests.add((
      subscribers: subscribers,
      layout: layout,
      cuttingGuides: cuttingGuides,
      result: result,
    ));
    return result.future;
  }
}

class FakeMailingPdfFile extends MailingPdfFile {
  final savedBytes = <Uint8List>[];
  bool canceled = false;
  bool fail = false;
  Completer<bool>? pending;

  @override
  Future<bool> save(Uint8List bytes) async {
    savedBytes.add(bytes);
    if (fail) throw StateError('save failed');
    if (pending != null) return pending!.future;
    return !canceled;
  }
}

class FakeMailingPdfPrinter extends MailingPdfPrinter {
  final documents = <MailingPdfPreview>[];
  bool canceled = false;
  bool fail = false;
  Completer<bool>? pending;

  @override
  Future<bool> printPdf(MailingPdfPreview document) async {
    documents.add(document);
    if (fail) throw StateError('print failed');
    if (pending != null) return pending!.future;
    return !canceled;
  }
}
