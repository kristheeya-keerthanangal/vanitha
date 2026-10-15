import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/subscriber_repository.dart';
import '../../../providers/database_provider.dart';

final mailingListViewModelProvider = Provider.autoDispose<MailingListViewModel>(
  (ref) {
    final model = MailingListViewModel(ref.watch(subscriberRepositoryProvider));
    ref.onDispose(model.dispose);
    return model;
  },
);

enum MailingOrientation { portrait, landscape }

enum MailingOrdering { name, postalCode }

enum MailingLabelSize {
  small(60, 30),
  medium(65, 35),
  large(65, 40);

  const MailingLabelSize(this.widthMm, this.heightMm);

  final int widthMm;
  final int heightMm;

  String get label => '$widthMm × $heightMm mm';
}

class MailingListViewModel extends ChangeNotifier {
  MailingListViewModel(this._repository) {
    refresh();
  }

  final SubscriberRepository _repository;
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
  int _request = 0;
  bool _disposed = false;

  void changeOrientation(MailingOrientation value) {
    orientation = value;
    notifyListeners();
  }

  void changeLabelSize(MailingLabelSize value) {
    labelSize = value;
    notifyListeners();
  }

  void changeOrdering(MailingOrdering value) {
    ordering = value;
    _orderRows();
    notifyListeners();
  }

  void changeCuttingGuides(bool value) {
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
    final request = ++_request;
    loading = true;
    error = null;
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

  @override
  void dispose() {
    _disposed = true;
    _request++;
    super.dispose();
  }
}
