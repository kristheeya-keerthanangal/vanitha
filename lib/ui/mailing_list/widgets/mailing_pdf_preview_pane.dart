import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../mailing/mailing_layout.dart';
import '../../../mailing/mailing_pdf_preview.dart';
import '../../shared/error_state.dart';

class MailingPdfPreviewPane extends StatelessWidget {
  const MailingPdfPreviewPane({
    super.key,
    required this.document,
    required this.onRetry,
  });

  final MailingPdfPreview document;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final snapshot = document.snapshot;
    final layout = snapshot.layout;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'PDF preview · ${snapshot.pageCount} ${snapshot.pageCount == 1 ? 'page' : 'pages'}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          '${snapshot.subscribers.length} subscribers · A4 '
          '${layout.orientation == MailingOrientation.portrait ? 'Portrait' : 'Landscape'} · '
          '${layout.labelSize.label} · '
          '${snapshot.ordering == MailingOrdering.name ? 'Name' : 'PIN code'} ordering · '
          'Cutting guides ${snapshot.cuttingGuides ? 'On' : 'Off'}',
        ),
        const Text('Scroll inside the preview to view all pages.'),
        const SizedBox(height: 12),
        SizedBox(
          height: 600,
          child: PdfPreview(
            key: ObjectKey(document),
            build: (_) async => document.bytes,
            initialPageFormat: PdfPageFormat(
              layout.pageWidthMm * PdfPageFormat.mm,
              layout.pageHeightMm * PdfPageFormat.mm,
            ),
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            allowPrinting: false,
            allowSharing: false,
            useActions: false,
            dynamicLayout: false,
            loadingWidget: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Rendering PDF pages…'),
                ],
              ),
            ),
            onError: (_, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: ErrorState(
                message:
                    'Unable to display the PDF. Retry the preview, or use Save PDF to open it in a PDF viewer.',
                onRetry: onRetry,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
