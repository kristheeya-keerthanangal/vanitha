import 'package:flutter/foundation.dart';

import '../../../data/repositories/subscription_repository.dart';
import '../../../data/subscription_renewal.dart';

class RenewSubscriptionViewModel extends ChangeNotifier {
  RenewSubscriptionViewModel(this.repository, this.subscriberId, this.rules)
    : startDate = rules.startDate;

  final SubscriptionRepository repository;
  final int subscriberId;
  final SubscriptionRenewal rules;
  DateTime startDate;
  String edition = 'online';
  String planType = 'annual';
  String duration = '2';
  bool isSaving = false;
  String? error;

  String? validateDuration(String? value) {
    final years = int.tryParse(value ?? '');
    return years != null && years >= 2 && years <= 50
        ? null
        : 'Enter 2 to 50 years';
  }

  void setPlan(String value) {
    planType = value;
    notifyListeners();
  }

  Future<bool> save() async {
    if (isSaving) return false;
    if (!rules.allows(startDate) ||
        (planType == 'multi_year' && validateDuration(duration) != null)) {
      error = 'Check the start date and duration.';
      notifyListeners();
      return false;
    }
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      await repository.renewSubscription(
        subscriberId: subscriberId,
        edition: edition,
        planType: planType,
        durationYears: planType == 'multi_year' ? int.parse(duration) : 1,
        startDate: startDate,
      );
      return true;
    } catch (_) {
      error =
          'Unable to renew. Check the details or reopen the form to refresh dates.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
