import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../mailing/mailing_layout.dart';
import '../../../mailing/mailing_pdf_preview.dart';
import '../../shared/error_state.dart';

class MailingPdfPreviewPane extends StatefulWidget {
  const MailingPdfPreviewPane({
    super.key,
    required this.document,
    required this.onRetry,
  });

  final MailingPdfPreview document;
  final VoidCallback onRetry;

  @override
  State<MailingPdfPreviewPane> createState() => _MailingPdfPreviewPaneState();
}

class _MailingPdfPreviewPaneState extends State<MailingPdfPreviewPane> {
  int _page = 0;

  @override
  void didUpdateWidget(covariant MailingPdfPreviewPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.document, widget.document)) _page = 0;
  }

  // Keep this callback stable when output actions rebuild the parent page.
  Future<Uint8List> _buildPdf(PdfPageFormat _) async => widget.document.bytes;

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.document.snapshot;
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: 'First page',
              onPressed: _page > 0 ? () => setState(() => _page = 0) : null,
              icon: const Icon(Icons.first_page),
            ),
            IconButton(
              tooltip: 'Previous page',
              onPressed: _page > 0 ? () => setState(() => _page--) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Text('Page ${_page + 1} of ${snapshot.pageCount}'),
            IconButton(
              tooltip: 'Next page',
              onPressed: _page + 1 < snapshot.pageCount
                  ? () => setState(() => _page++)
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
            IconButton(
              tooltip: 'Last page',
              onPressed: _page + 1 < snapshot.pageCount
                  ? () => setState(() => _page = snapshot.pageCount - 1)
                  : null,
              icon: const Icon(Icons.last_page),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 600,
          child: PdfPreview(
            key: ValueKey((widget.document, _page)),
            build: _buildPdf,
            // Rasterizing all pages retains a full-size image for every page.
            // Bound both the page count and resolution for large mailing lists.
            pages: [_page],
            dpi: 144,
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
                  Text('Rendering PDF page…'),
                ],
              ),
            ),
            onError: (_, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: ErrorState(
                message:
                    'Unable to display the PDF. Retry the preview, or use Save PDF to open it in a PDF viewer.',
                onRetry: widget.onRetry,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
