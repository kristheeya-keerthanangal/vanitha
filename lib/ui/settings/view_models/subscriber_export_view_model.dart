import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/subscriber_repository.dart';
import '../../../../data/subscriber_export_file.dart';
import '../../../../providers/database_provider.dart';

final subscriberExportFileSaverProvider =
    Provider<Future<bool> Function(String)>((ref) => saveSubscriberExportFile);

final subscriberExportViewModelProvider =
    Provider.autoDispose<SubscriberExportViewModel>((ref) {
      final model = SubscriberExportViewModel(
        ref.watch(subscriberRepositoryProvider),
        ref.watch(subscriberExportFileSaverProvider),
      );
      ref.onDispose(model.dispose);
      return model;
    });

class SubscriberExportViewModel extends ChangeNotifier {
  SubscriberExportViewModel(this._repository, this._saveFile);

  final SubscriberRepository _repository;
  final Future<bool> Function(String) _saveFile;
  bool isBusy = false;
  bool _disposed = false;
  String? message;
  String? error;

  Future<void> export() async {
    if (isBusy || _disposed) return;
    isBusy = true;
    message = null;
    error = null;
    notifyListeners();
    try {
      final contents = await _repository.exportSubscribers();
      if (_disposed) return;
      final saved = await _saveFile(contents);
      if (_disposed) return;
      message = saved ? 'Subscribers exported.' : 'Export canceled.';
    } catch (_) {
      if (!_disposed) {
        error =
            'Unable to export subscribers. Try again or choose a writable location.';
      }
    } finally {
      if (!_disposed) {
        isBusy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
