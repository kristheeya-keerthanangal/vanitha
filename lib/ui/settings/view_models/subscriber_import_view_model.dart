import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../subscribers/view_models/subscribers_view_model.dart';
import '../../../../data/repositories/subscriber_repository.dart';
import '../../../../data/subscriber_import.dart';
import '../../../../data/subscriber_import_file.dart';
import '../../../../providers/database_provider.dart';

final subscriberImportFilePickerProvider =
    Provider<Future<SubscriberImportFile?> Function()>((ref) {
      return selectSubscriberImportFile;
    });

final subscriberImportViewModelProvider =
    Provider.autoDispose<SubscriberImportViewModel>((ref) {
      final model = SubscriberImportViewModel(
        ref.watch(subscriberRepositoryProvider),
        ref.watch(subscriberImportFilePickerProvider),
        onImported: () => ref.read(subscribersViewModelProvider).refresh(),
      );
      ref.onDispose(model.dispose);
      return model;
    });

class SubscriberImportViewModel extends ChangeNotifier {
  SubscriberImportViewModel(
    this._repository,
    this._pickFile, {
    required this.onImported,
  });

  final SubscriberRepository _repository;
  final Future<SubscriberImportFile?> Function() _pickFile;
  final VoidCallback onImported;

  bool isBusy = false;
  bool _disposed = false;
  String? filename;
  String? error;
  SubscriberImportPreview? preview;
  SubscriberImportResult? result;
  CompleteImportPreview? completePreview;
  CompleteImportResult? completeResult;

  Future<void> selectFile() async {
    if (isBusy || _disposed) return;
    isBusy = true;
    error = null;
    result = null;
    preview = null;
    completeResult = null;
    completePreview = null;
    filename = null;
    notifyListeners();
    try {
      final file = await _pickFile();
      if (_disposed || file == null) return;
      final entries = parseSubscriberImport(file.contents);
      final prepared = await _repository.previewImport(entries);
      if (_disposed) return;
      filename = file.name;
      preview = prepared;
    } on FormatException catch (exception) {
      if (!_disposed) error = exception.message.toString();
    } catch (_) {
      if (!_disposed) {
        error = 'Unable to read or prepare the import. Try again.';
      }
    } finally {
      if (!_disposed) {
        isBusy = false;
        notifyListeners();
      }
    }
  }

  Future<void> selectCompleteFile() async {
    if (isBusy || _disposed) return;
    isBusy = true;
    error = null;
    result = null;
    preview = null;
    completeResult = null;
    completePreview = null;
    filename = null;
    notifyListeners();
    try {
      final file = await _pickFile();
      if (_disposed || file == null) return;
      final entries = parseCompleteSubscriberImport(file.contents);
      final prepared = await _repository.previewCompleteImport(entries);
      if (_disposed) return;
      filename = file.name;
      completePreview = prepared;
    } on FormatException catch (exception) {
      if (!_disposed) error = exception.message.toString();
    } catch (_) {
      if (!_disposed) {
        error = 'Unable to read or prepare the complete import. Try again.';
      }
    } finally {
      if (!_disposed) {
        isBusy = false;
        notifyListeners();
      }
    }
  }

  void cancel() {
    if (isBusy || _disposed) return;
    preview = null;
    completePreview = null;
    filename = null;
    error = null;
    notifyListeners();
  }

  void cancelComplete() {
    if (isBusy || _disposed) return;
    completePreview = null;
    filename = null;
    error = null;
    notifyListeners();
  }

  Future<void> import() async {
    final prepared = preview;
    if (isBusy || _disposed || prepared == null || prepared.toInsert == 0) {
      return;
    }
    isBusy = true;
    error = null;
    notifyListeners();
    try {
      final imported = await _repository.importSubscribers(prepared);
      if (_disposed) return;
      result = imported;
      preview = null;
      filename = null;
      onImported();
    } catch (_) {
      if (!_disposed) {
        error = 'Unable to import subscribers. No subscribers were added.';
      }
    } finally {
      if (!_disposed) {
        isBusy = false;
        notifyListeners();
      }
    }
  }

  Future<void> importComplete() async {
    final prepared = completePreview;
    if (isBusy ||
        _disposed ||
        prepared == null ||
        prepared.subscribersToInsert == 0) {
      return;
    }
    isBusy = true;
    error = null;
    notifyListeners();
    try {
      final imported = await _repository.importCompleteSubscribers(prepared);
      if (_disposed) return;
      completeResult = imported;
      completePreview = null;
      filename = null;
      onImported();
    } catch (_) {
      if (!_disposed) {
        error =
            'Unable to import subscribers and subscriptions. No records were added.';
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
