import 'package:flutter/foundation.dart';

import '../../../data/repositories/subscriber_registration_repository.dart';

class AddSubscriberFormViewModel extends ChangeNotifier {
  AddSubscriberFormViewModel(this._repository);

  final SubscriberRegistrationRepository _repository;

  String name = '';
  String email = '';
  String phone = '';
  String postalAddress = '';
  String postalCode = '';
  bool isForeign = false;
  String? edition;
  String? planType;
  String durationYears = '';
  DateTime? startDate;
  String? submitError;
  bool isSaving = false;
  bool _disposed = false;

  bool get showsDuration => planType == 'multi_year';

  String get startDateLabel {
    final date = startDate;
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}';
  }

  void setName(String value) => _set(() => name = value);

  void setEmail(String value) => _set(() => email = value);

  void setPhone(String value) => _set(() => phone = value);

  void setPostalAddress(String value) => _set(() => postalAddress = value);

  void setPostalCode(String value) => _set(() => postalCode = value);

  void setIsForeign(bool value) => _set(() => isForeign = value);

  void setEdition(String? value) {
    edition = value;
    notifyListeners();
  }

  void setPlanType(String? value) {
    planType = value;
    durationYears = switch (value) {
      'annual' => '1',
      'lifetime' => '15',
      _ => '',
    };
    notifyListeners();
  }

  void setDurationYears(String value) => _set(() => durationYears = value);

  void setStartDate(DateTime value) {
    startDate = value;
    notifyListeners();
  }

  String? validateRequired(String? value, String message) {
    return value == null || value.trim().isEmpty ? message : null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())
        ? null
        : 'Enter a valid email address';
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 7 && digits.length <= 15
        ? null
        : 'Enter a valid phone number';
  }

  String? validateDuration(String? value) {
    final duration = int.tryParse(value?.trim() ?? '');
    if (duration == null || duration <= 1) {
      return 'Enter a duration greater than one year';
    }
    return duration <= 50 ? null : 'Enter a duration of 50 years or less';
  }

  String? validateSelection(String? value, String label) {
    return value == null ? 'Select $label'.toLowerCase() : null;
  }

  Future<bool> save() async {
    if (_disposed || isSaving) return false;

    final selectedPlan = planType;
    final selectedStartDate = startDate;
    if (name.trim().isEmpty ||
        edition == null ||
        selectedPlan == null ||
        selectedStartDate == null) {
      submitError = 'Please complete all required fields.';
      if (!_disposed) notifyListeners();
      return false;
    }

    final effectiveDuration = _durationForPlan(selectedPlan);
    if (effectiveDuration == null) {
      submitError = validateDuration(durationYears);
      if (!_disposed) notifyListeners();
      return false;
    }

    isSaving = true;
    submitError = null;
    if (_disposed) return false;
    notifyListeners();
    try {
      await _repository.registerSubscriber(
        name: name,
        email: email,
        phone: phone,
        postalAddress: postalAddress,
        postalCode: postalCode,
        isForeign: isForeign,
        edition: edition!,
        planType: selectedPlan,
        durationYears: effectiveDuration,
        startYear: selectedStartDate.year,
        startMonth: selectedStartDate.month,
      );
      if (_disposed) return true;
      isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {
      if (_disposed) return false;
      isSaving = false;
      submitError = 'Unable to add subscriber. Please check the details.';
      notifyListeners();
      return false;
    }
  }

  int? _durationForPlan(String selectedPlan) {
    return switch (selectedPlan) {
      'annual' => 1,
      'lifetime' => 15,
      'multi_year' =>
        validateDuration(durationYears) == null
            ? int.tryParse(durationYears.trim())
            : null,
      _ => null,
    };
  }

  void _set(VoidCallback setter) {
    setter();
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
