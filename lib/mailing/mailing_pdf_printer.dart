import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'mailing_pdf_preview.dart';

class MailingPdfPrinter {
  Future<bool> printPdf(MailingPdfPreview document) {
    final layout = document.snapshot.layout;
    return Printing.layoutPdf(
      name: 'Mailing labels',
      format: PdfPageFormat(
        layout.pageWidthMm * PdfPageFormat.mm,
        layout.pageHeightMm * PdfPageFormat.mm,
      ),
      dynamicLayout: false,
      usePrinterSettings: false,
      onLayout: (_) => document.bytes,
    );
  }
}
