// Flutter's desktop windowing API is experimental and still internal.
// Keep these imports isolated until Flutter exposes a public API.
// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/_features.dart' show isWindowingEnabled;
import 'package:flutter/src/widgets/_window.dart';

import '../../../mailing/mailing_pdf_preview.dart';
import '../../../theme/app_theme.dart';
import '../../../windowing/desktop_windowing.dart';
import '../view_models/mailing_list_view_model.dart';
import 'mailing_pdf_preview_pane.dart';

class MailingPreviewWindow extends StatefulWidget {
  const MailingPreviewWindow({
    super.key,
    required this.model,
    required this.child,
  });

  final MailingListViewModel model;
  final Widget child;

  @override
  State<MailingPreviewWindow> createState() => _MailingPreviewWindowState();
}

class _MailingPreviewWindowState extends State<MailingPreviewWindow> {
  RegularWindowController? _controller;
  MailingPdfPreview? _document;
  bool _dismissed = false;
  bool _disposing = false;

  bool get _useNativeWindow => isWindowingEnabled && isDesktopPlatform;

  @override
  void initState() {
    super.initState();
    _updateDocument();
  }

  @override
  void didUpdateWidget(covariant MailingPreviewWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateDocument();
  }

  void _updateDocument() {
    final document = widget.model.preview;
    if (identical(document, _document)) return;
    _document = document;
    _dismissed = false;
    if (document == null) {
      _destroyWindow();
    } else if (_useNativeWindow) {
      _controller ??= RegularWindowController(
        title: 'Mailing list · PDF preview',
        size: const Size(1000, 800),
        constraints: const BoxConstraints(minWidth: 400, minHeight: 400),
        delegate: _PreviewWindowDelegate(_onWindowDestroyed),
      );
      _controller!.activate();
    }
  }

  void _onWindowDestroyed() {
    if (_disposing || _controller == null) return;
    final controller = _controller!;
    setState(() {
      _controller = null;
      _dismissed = true;
    });
    // The Window widget must detach its listeners before disposal.
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
  }

  void _destroyWindow() {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    controller.destroy();
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());
  }

  void _close() {
    _destroyWindow();
    setState(() => _dismissed = true);
  }

  @override
  void dispose() {
    _disposing = true;
    _destroyWindow();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final document = _document;
    final preview = document == null || _dismissed
        ? null
        : _MailingPreviewPage(
            model: widget.model,
            document: document,
            onClose: _close,
          );
    if (!_useNativeWindow) {
      // Mobile, web, and builds without experimental windowing show a
      // separate preview screen with the same output actions.
      return preview ?? widget.child;
    }
    return ViewAnchor(
      view: _controller == null || preview == null
          ? null
          : RegularWindow(
              controller: _controller!,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: ThemeMode.system,
                home: preview,
              ),
            ),
      child: widget.child,
    );
  }
}

class _PreviewWindowDelegate extends RegularWindowControllerDelegate {
  _PreviewWindowDelegate(this.onDestroyed);

  final VoidCallback onDestroyed;

  @override
  void onWindowDestroyed() => onDestroyed();
}

class _MailingPreviewPage extends StatelessWidget {
  const _MailingPreviewPage({
    required this.model,
    required this.document,
    required this.onClose,
  });

  final MailingListViewModel model;
  final MailingPdfPreview document;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: const Text('Mailing list preview'),
      actions: [
        IconButton(
          tooltip: 'Close preview',
          onPressed: onClose,
          icon: const Icon(Icons.close),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: model.canOutput ? model.savePdf : null,
              icon: model.outputAction == PdfOutputAction.save
                  ? const _OutputProgress()
                  : const Icon(Icons.save_outlined),
              label: Text(
                model.outputAction == PdfOutputAction.save
                    ? 'Saving PDF…'
                    : 'Save PDF',
              ),
            ),
            OutlinedButton.icon(
              onPressed: model.canOutput ? model.printPdf : null,
              icon: model.outputAction == PdfOutputAction.print
                  ? const _OutputProgress()
                  : const Icon(Icons.print_outlined),
              label: Text(
                model.outputAction == PdfOutputAction.print
                    ? 'Printing PDF…'
                    : 'Print PDF',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Print at 100% / actual size. Turn off Fit to page to preserve label dimensions.',
        ),
        Semantics(
          liveRegion: true,
          child: Text(model.outputError ?? model.outputMessage ?? ''),
        ),
        const SizedBox(height: 24),
        MailingPdfPreviewPane(document: document, onRetry: model.previewPdf),
      ],
    ),
  );
}

class _OutputProgress extends StatelessWidget {
  const _OutputProgress();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 18,
    height: 18,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
