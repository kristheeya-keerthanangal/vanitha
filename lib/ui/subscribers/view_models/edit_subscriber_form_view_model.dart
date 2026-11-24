import 'package:drift/drift.dart' show Value;

import '../../../data/app_database.dart';
import '../../../data/repositories/subscriber_repository.dart';
import 'subscriber_form_view_model.dart';

class EditSubscriberFormViewModel extends SubscriberFormViewModel {
  EditSubscriberFormViewModel(this._repository, this._subscriber) {
    name = _subscriber.name;
    email = _subscriber.email ?? '';
    phone = _subscriber.phone ?? '';
    postalAddress = _subscriber.postalAddress ?? '';
    postalCode = _subscriber.postalCode ?? '';
    isForeign = _subscriber.isForeign;
  }

  final SubscriberRepository _repository;
  final Subscriber _subscriber;

  String? submitError;
  bool isSaving = false;

  Future<bool> save() async {
    if (isDisposed || isSaving) return false;

    if (name.trim().isEmpty) {
      submitError = 'Enter a subscriber name.';
      notifyListeners();
      return false;
    }

    isSaving = true;
    submitError = null;
    notifyListeners();
    try {
      await _repository.updateSubscriber(
        _subscriber.copyWith(
          name: name.trim(),
          email: Value(normalizeOptional(email)),
          phone: Value(normalizeOptional(phone)),
          postalAddress: Value(normalizeOptional(postalAddress)),
          postalCode: Value(normalizeOptional(postalCode)),
          isForeign: isForeign,
        ),
      );
      if (isDisposed) return true;
      isSaving = false;
      notifyListeners();
      return true;
    } on StateError {
      if (isDisposed) return false;
      isSaving = false;
      submitError =
          'This subscriber was changed elsewhere. Reload and try again.';
      notifyListeners();
      return false;
    } catch (_) {
      if (isDisposed) return false;
      isSaving = false;
      submitError = 'Unable to update subscriber. Please check the details.';
      notifyListeners();
      return false;
    }
  }
}
