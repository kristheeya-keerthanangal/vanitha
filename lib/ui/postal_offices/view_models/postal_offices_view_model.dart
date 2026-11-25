import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/app_database.dart';
import '../../../data/repositories/postal_office_repository.dart';
import '../../../providers/database_provider.dart';

final postalOfficesViewModelProvider =
    Provider.autoDispose<PostalOfficesViewModel>((ref) {
  final model = PostalOfficesViewModel(ref.watch(postalOfficeRepositoryProvider));
  ref.onDispose(model.dispose);
  return model;
});

class PostalOfficesViewModel extends ChangeNotifier {
  PostalOfficesViewModel(this._repository) {
    refresh();
  }

  final PostalOfficeRepository _repository;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  List<PostalOffice> offices = [];
  Map<int, int> ruleCounts = {};
  bool loading = true;
  String? error;
  bool isDeleting = false;

  Future<void> refresh() async {
    if (_disposed) return;
    loading = true;
    error = null;
    notifyListeners();

    try {
      final fetchedOffices = await _repository.getAllOffices();
      final fetchedCounts = await _repository.getRuleCountsByOffice();
      if (_disposed) return;
      offices = fetchedOffices;
      ruleCounts = fetchedCounts;
    } catch (_) {
      if (_disposed) return;
      error = 'Unable to load postal offices.';
    }

    if (!_disposed) {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteOffice(int id) async {
    isDeleting = true;
    notifyListeners();
    try {
      await _repository.deleteOffice(id);
      await refresh();
      isDeleting = false;
      return true;
    } catch (_) {
      error = 'Unable to delete postal office.';
      isDeleting = false;
      notifyListeners();
      return false;
    }
  }
}
