import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/subscriber_repository.dart';
import '../../../mailing/mailing_layout.dart';
import '../../../mailing/mailing_pdf.dart';
import '../../../mailing/mailing_pdf_file.dart';
import '../../../mailing/mailing_pdf_preview.dart';
import '../../../mailing/mailing_pdf_printer.dart';
import '../../../providers/database_provider.dart';

export '../../../mailing/mailing_layout.dart';

final mailingPdfProvider = Provider<MailingPdf>((ref) => MailingPdf());
final mailingPdfFileProvider = Provider<MailingPdfFile>(
  (ref) => MailingPdfFile(),
);
final mailingPdfPrinterProvider = Provider<MailingPdfPrinter>(
  (ref) => MailingPdfPrinter(),
);

enum PdfOutputAction { print, save }

final mailingListViewModelProvider = Provider.autoDispose<MailingListViewModel>(
  (ref) {
    final model = MailingListViewModel(
      ref.watch(subscriberRepositoryProvider),
      pdf: ref.watch(mailingPdfProvider),
      file: ref.watch(mailingPdfFileProvider),
      printer: ref.watch(mailingPdfPrinterProvider),
    );
    ref.onDispose(model.dispose);
    return model;
  },
);

class MailingListViewModel extends ChangeNotifier {
  MailingListViewModel(
    this._repository, {
    MailingPdf? pdf,
    MailingPdfFile? file,
    MailingPdfPrinter? printer,
  }) : _pdf = pdf ?? MailingPdf(),
       _file = file ?? MailingPdfFile(),
       _printer = printer ?? MailingPdfPrinter() {
    refresh();
  }

  final SubscriberRepository _repository;
  final MailingPdf _pdf;
  final MailingPdfFile _file;
  final MailingPdfPrinter _printer;
  List<MailingListEntry> _entries = [];
  List<MailingListEntry> _rows = [];
  List<MailingListEntry> get rows => _rows;
  List<MailingListEntry> get incompleteRows =>
      _rows.where((row) => row.hasIncompleteMailingDetails).toList();
  int get total => _rows.length;
  int get incompleteCount => incompleteRows.length;

  MailingOrientation orientation = MailingOrientation.portrait;
  MailingLabelSize labelSize = MailingLabelSize.small;
  MailingOrdering ordering = MailingOrdering.name;
  bool cuttingGuides = true;
  bool loading = true;
  String? error;
  PdfOutputAction? outputAction;
  bool get outputBusy => outputAction != null;
  String? outputMessage;
  String? outputError;
  MailingPdfPreview? preview;
  bool previewing = false;
  bool previewInvalidated = false;
  String? previewError;
  List<MailingListEntry> fittingFailures = const [];
  bool get canPreview =>
      !_disposed &&
      !loading &&
      error == null &&
      total > 0 &&
      !outputBusy &&
      !previewing &&
      fittingFailures.isEmpty;
  bool get canOutput => preview != null && canPreview;
  int _request = 0;
  int _previewRequest = 0;
  bool _disposed = false;

  void changeOrientation(MailingOrientation value) {
    if (outputBusy) return;
    orientation = value;
    _invalidatePreview();
    fittingFailures = const [];
    notifyListeners();
  }

  void changeLabelSize(MailingLabelSize value) {
    if (outputBusy) return;
    labelSize = value;
    _invalidatePreview();
    fittingFailures = const [];
    notifyListeners();
  }

  void changeOrdering(MailingOrdering value) {
    if (outputBusy) return;
    ordering = value;
    _invalidatePreview();
    _orderRows();
    notifyListeners();
  }

  void changeCuttingGuides(bool value) {
    if (outputBusy) return;
    cuttingGuides = value;
    _invalidatePreview();
    notifyListeners();
  }

  void _orderRows() {
    final sorted = [..._entries];
    if (ordering == MailingOrdering.postalCode) {
      sorted.sort((a, b) {
        if (a.isPostalCodeMissing != b.isPostalCodeMissing) {
          return a.isPostalCodeMissing ? 1 : -1;
        }
        final comparison = a.isPostalCodeMissing
            ? 0
            : a.postalCode!.trim().compareTo(b.postalCode!.trim());
        return comparison != 0
            ? comparison
            : a.subscriberId.compareTo(b.subscriberId);
      });
    }
    _rows = List.unmodifiable(sorted);
  }

  Future<void> refresh() async {
    if (outputBusy) return;
    final request = ++_request;
    loading = true;
    error = null;
    _invalidatePreview();
    fittingFailures = const [];
    notifyListeners();
    try {
      final entries = await _repository.getMailingList();
      if (_disposed || request != _request) return;
      _entries = entries;
      _orderRows();
    } catch (_) {
      if (_disposed || request != _request) return;
      error = 'Unable to load the mailing list.';
    }
    loading = false;
    notifyListeners();
  }

  void _invalidatePreview() {
    _previewRequest++;
    previewInvalidated = previewInvalidated || preview != null || previewing;
    preview = null;
    previewing = false;
    previewError = null;
    outputMessage = null;
    outputError = null;
  }

  Future<void> previewPdf() async {
    if (!canPreview) return;
    final snapshot = MailingPdfSnapshot(
      subscribers: rows,
      layout: MailingLayout(orientation: orientation, labelSize: labelSize),
      ordering: ordering,
      cuttingGuides: cuttingGuides,
    );
    final request = ++_previewRequest;
    preview = null;
    previewing = true;
    previewError = null;
    outputMessage = null;
    outputError = null;
    notifyListeners();
    try {
      final bytes = await _pdf.generate(
        subscribers: snapshot.subscribers,
        layout: snapshot.layout,
        cuttingGuides: snapshot.cuttingGuides,
      );
      if (_disposed || request != _previewRequest) return;
      preview = MailingPdfPreview(snapshot: snapshot, bytes: bytes);
      previewInvalidated = false;
    } on MailingTextFitFailure catch (failure) {
      if (_disposed || request != _previewRequest) return;
      fittingFailures = failure.subscribers;
      previewError =
          'Preview blocked. Correct the listed subscribers or choose a larger label.';
    } catch (_) {
      if (_disposed || request != _previewRequest) return;
      previewError =
          'Unable to generate the preview. Select Generate list to try again.';
    }
    previewing = false;
    notifyListeners();
  }

  Future<void> savePdf() => _outputPdf(PdfOutputAction.save);

  Future<void> printPdf() => _outputPdf(PdfOutputAction.print);

  Future<void> _outputPdf(PdfOutputAction action) async {
    if (!canOutput) return;
    final document = preview!;
    outputAction = action;
    outputMessage = null;
    outputError = null;
    notifyListeners();
    try {
      final completed = action == PdfOutputAction.print
          ? await _printer.printPdf(document)
          : await _file.save(document.bytes);
      if (_disposed) return;
      outputMessage = action == PdfOutputAction.print
          ? (completed ? 'Print job submitted.' : 'Print canceled.')
          : (completed ? 'PDF saved.' : 'Save canceled.');
    } catch (_) {
      if (_disposed) return;
      outputError = action == PdfOutputAction.print
          ? 'Unable to print the PDF. Check your printer and try Print PDF again.'
          : 'Unable to save the PDF. Choose a writable location and try Save PDF again.';
    } finally {
      if (!_disposed) {
        outputAction = null;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _request++;
    _previewRequest++;
    super.dispose();
  }
}
