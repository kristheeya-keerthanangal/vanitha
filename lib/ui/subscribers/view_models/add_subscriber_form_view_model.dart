import 'package:flutter/foundation.dart';

import '../../../data/repositories/subscriber_registration_repository.dart';

class AddSubscriberFormViewModel extends ChangeNotifier {
  AddSubscriberFormViewModel(this._repository);

  final SubscriberRegistrationRepository _repository;

  String? subscriberType;
  String name = '';
  String contactPersonName = '';
  String email = '';
  String phone = '';
  String postalAddress = '';
  String city = '';
  String state = '';
  String postalCode = '';
  String country = '';
  String? edition;
  String? planType;
  String durationYears = '2';
  DateTime? startDate;
  String? paymentStatus;
  String? submitError;
  bool isSaving = false;

  bool get showsDuration => planType == 'multi_year';

  String get startDateLabel {
    final date = startDate;
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  void setSubscriberType(String? value) {
    subscriberType = value;
    notifyListeners();
  }

  void setName(String value) => _set(() => name = value);

  void setContactPersonName(String value) =>
      _set(() => contactPersonName = value);

  void setEmail(String value) => _set(() => email = value);

  void setPhone(String value) => _set(() => phone = value);

  void setPostalAddress(String value) => _set(() => postalAddress = value);

  void setCity(String value) => _set(() => city = value);

  void setState(String value) => _set(() => state = value);

  void setPostalCode(String value) => _set(() => postalCode = value);

  void setCountry(String value) => _set(() => country = value);

  void setEdition(String? value) {
    edition = value;
    notifyListeners();
  }

  void setPlanType(String? value) {
    planType = value;
    durationYears = switch (value) {
      'annual' => '1',
      'lifetime' => '10',
      _ => '2',
    };
    notifyListeners();
  }

  void setDurationYears(String value) => _set(() => durationYears = value);

  void setStartDate(DateTime value) {
    startDate = value;
    notifyListeners();
  }

  void setPaymentStatus(String? value) {
    paymentStatus = value;
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
    return duration != null && duration > 1
        ? null
        : 'Enter a duration greater than one year';
  }

  String? validateSelection(String? value, String label) {
    return value == null ? 'Select $label'.toLowerCase() : null;
  }

  Future<bool> save() async {
    final selectedPlan = planType;
    final selectedStartDate = startDate;
    if (subscriberType == null ||
        name.trim().isEmpty ||
        edition == null ||
        selectedPlan == null ||
        paymentStatus == null ||
        selectedStartDate == null) {
      submitError = 'Please complete all required fields.';
      notifyListeners();
      return false;
    }

    final effectiveDuration = _durationForPlan(selectedPlan);
    if (effectiveDuration == null) {
      submitError = validateDuration(durationYears);
      notifyListeners();
      return false;
    }

    isSaving = true;
    submitError = null;
    notifyListeners();
    try {
      await _repository.registerSubscriber(
        subscriberType: subscriberType!,
        name: name,
        contactPersonName: contactPersonName,
        email: email,
        phone: phone,
        postalAddress: postalAddress,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        edition: edition!,
        planType: selectedPlan,
        durationYears: effectiveDuration,
        startDate: selectedStartDate,
        paymentStatus: paymentStatus!,
      );
      isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {
      isSaving = false;
      submitError = 'Unable to add subscriber. Please check the details.';
      notifyListeners();
      return false;
    }
  }

  int? _durationForPlan(String selectedPlan) {
    return switch (selectedPlan) {
      'annual' => 1,
      'lifetime' => 10,
      'multi_year' => int.tryParse(durationYears),
      _ => null,
    };
  }

  void _set(VoidCallback setter) {
    setter();
    notifyListeners();
  }
}
