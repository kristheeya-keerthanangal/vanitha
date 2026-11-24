import '../../../data/repositories/subscriber_registration_repository.dart';
import 'subscriber_form_view_model.dart';

class AddSubscriberFormViewModel extends SubscriberFormViewModel {
  AddSubscriberFormViewModel(this._repository);

  final SubscriberRegistrationRepository _repository;

  String? edition;
  String? planType;
  String durationYears = '';
  DateTime? startDate;
  String? submitError;
  bool isSaving = false;

  bool get showsDuration => planType == 'multi_year';

  String get startDateLabel {
    final date = startDate;
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}';
  }

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

  void setDurationYears(String value) {
    durationYears = value;
    if (!isDisposed) notifyListeners();
  }

  void setStartDate(DateTime value) {
    startDate = value;
    notifyListeners();
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
    if (isDisposed || isSaving) return false;

    final selectedPlan = planType;
    final selectedStartDate = startDate;
    if (name.trim().isEmpty ||
        edition == null ||
        selectedPlan == null ||
        selectedStartDate == null) {
      submitError = 'Please complete all required fields.';
      if (!isDisposed) notifyListeners();
      return false;
    }

    final effectiveDuration = _durationForPlan(selectedPlan);
    if (effectiveDuration == null) {
      submitError = validateDuration(durationYears);
      if (!isDisposed) notifyListeners();
      return false;
    }

    isSaving = true;
    submitError = null;
    if (isDisposed) return false;
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
      if (isDisposed) return true;
      isSaving = false;
      notifyListeners();
      return true;
    } catch (_) {
      if (isDisposed) return false;
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
}
