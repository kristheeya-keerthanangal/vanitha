import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/subscriber_repository.dart';
import '../../../mailing/mailing_layout.dart';
import '../../../mailing/mailing_pdf.dart';
import '../../../mailing/mailing_pdf_file.dart';
import '../../../providers/database_provider.dart';

export '../../../mailing/mailing_layout.dart';

final mailingPdfProvider = Provider<MailingPdf>((ref) => MailingPdf());
final mailingPdfFileProvider = Provider<MailingPdfFile>(
  (ref) => MailingPdfFile(),
);

final mailingListViewModelProvider = Provider.autoDispose<MailingListViewModel>(
  (ref) {
    final model = MailingListViewModel(
      ref.watch(subscriberRepositoryProvider),
      pdf: ref.watch(mailingPdfProvider),
      file: ref.watch(mailingPdfFileProvider),
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
  }) : _pdf = pdf ?? MailingPdf(),
       _file = file ?? MailingPdfFile() {
    refresh();
  }

  final SubscriberRepository _repository;
  final MailingPdf _pdf;
  final MailingPdfFile _file;
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
  bool generating = false;
  String? generationError;
  bool pdfSaved = false;
  List<MailingListEntry> fittingFailures = const [];
  bool get canGenerate =>
      !loading &&
      error == null &&
      total > 0 &&
      !generating &&
      fittingFailures.isEmpty;
  int _request = 0;
  bool _disposed = false;

  void changeOrientation(MailingOrientation value) {
    if (generating) return;
    orientation = value;
    _clearGenerationResult();
    notifyListeners();
  }

  void changeLabelSize(MailingLabelSize value) {
    if (generating) return;
    labelSize = value;
    _clearGenerationResult();
    notifyListeners();
  }

  void changeOrdering(MailingOrdering value) {
    if (generating) return;
    ordering = value;
    _orderRows();
    notifyListeners();
  }

  void changeCuttingGuides(bool value) {
    if (generating) return;
    cuttingGuides = value;
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
    if (generating) return;
    final request = ++_request;
    loading = true;
    error = null;
    _clearGenerationResult();
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

  void _clearGenerationResult() {
    fittingFailures = const [];
    generationError = null;
    pdfSaved = false;
  }

  Future<void> generatePdf() async {
    if (!canGenerate) return;
    generating = true;
    _clearGenerationResult();
    notifyListeners();
    try {
      final bytes = await _pdf.generate(
        subscribers: rows,
        layout: MailingLayout(orientation: orientation, labelSize: labelSize),
        cuttingGuides: cuttingGuides,
      );
      if (_disposed) return;
      final saved = await _file.save(bytes);
      if (_disposed) return;
      pdfSaved = saved;
    } on MailingTextFitFailure catch (failure) {
      if (_disposed) return;
      fittingFailures = failure.subscribers;
    } catch (_) {
      if (_disposed) return;
      generationError = 'Unable to generate or save the PDF. Please try again.';
    }
    generating = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _request++;
    super.dispose();
  }
}
