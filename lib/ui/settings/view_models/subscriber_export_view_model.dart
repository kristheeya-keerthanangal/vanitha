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
    await _export(
      _repository.exportSubscribers,
      successMessage: 'Subscribers exported.',
      cancellationMessage: 'Export canceled.',
      errorMessage:
          'Unable to export subscribers. Try again or choose a writable location.',
    );
  }

  Future<void> completeExport() async {
    await _export(
      _repository.exportCompleteSubscribers,
      successMessage: 'Complete export saved.',
      cancellationMessage: 'Complete export canceled.',
      errorMessage:
          'Unable to complete the export. Try again or choose a writable location.',
    );
  }

  Future<void> _export(
    Future<String> Function() createContents, {
    required String successMessage,
    required String cancellationMessage,
    required String errorMessage,
  }) async {
    if (isBusy || _disposed) return;
    isBusy = true;
    message = null;
    error = null;
    notifyListeners();
    try {
      final contents = await createContents();
      if (_disposed) return;
      final saved = await _saveFile(contents);
      if (_disposed) return;
      message = saved ? successMessage : cancellationMessage;
    } catch (_) {
      if (!_disposed) {
        error = errorMessage;
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
