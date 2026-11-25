import 'package:drift/drift.dart' hide isNull;
import 'package:flutter/widgets.dart';

import '../../../data/app_database.dart';
import '../../../data/pincode_matcher.dart';
import '../../../data/repositories/postal_office_repository.dart';

class RuleDraft {
  RuleDraft({
    this.id,
    this.operation = 'include',
    this.matchMethod = 'prefix',
    String startValue = '',
    String endValue = '',
  })  : startController = TextEditingController(text: startValue),
        endController = TextEditingController(text: endValue);

  final int? id;
  String operation;
  String matchMethod;
  final TextEditingController startController;
  final TextEditingController endController;

  void dispose() {
    startController.dispose();
    endController.dispose();
  }

  PostalOfficeRule toRule(int officeId, int tempId) {
    return PostalOfficeRule(
      id: id ?? tempId,
      postalOfficeId: officeId,
      operation: operation,
      matchMethod: matchMethod,
      startValue: startController.text.trim(),
      endValue: matchMethod == 'range' ? endController.text.trim() : null,
    );
  }

  String? validate() {
    final start = startController.text.trim();
    if (start.isEmpty) {
      return 'Pincode value is required.';
    }

    switch (matchMethod) {
      case 'prefix':
        if (!RegExp(r'^\d{1,6}$').hasMatch(start)) {
          return 'Prefix must be 1 to 6 digits.';
        }
        break;
      case 'exact':
        if (!RegExp(r'^\d{6}$').hasMatch(start)) {
          return 'Exact pincode must be 6 digits.';
        }
        break;
      case 'range':
        if (!RegExp(r'^\d{6}$').hasMatch(start)) {
          return 'Start pincode must be 6 digits.';
        }
        final end = endController.text.trim();
        if (!RegExp(r'^\d{6}$').hasMatch(end)) {
          return 'End pincode must be 6 digits.';
        }
        if (start.compareTo(end) > 0) {
          return 'Start pincode cannot be greater than end pincode.';
        }
        break;
    }
    return null;
  }
}

class PostalOfficeFormViewModel extends ChangeNotifier {
  PostalOfficeFormViewModel(
    this._repository, {
    this.officeId,
  }) {
    if (officeId != null) {
      _loadOffice(officeId!);
    } else {
      loading = false;
    }
  }

  final PostalOfficeRepository _repository;
  final int? officeId;

  bool loading = true;
  bool isSaving = false;
  String? loadError;
  String? saveError;

  final nameController = TextEditingController();
  bool isActive = true;
  final List<RuleDraft> rules = [];

  final testPincodeController = TextEditingController();
  PincodeMatchResult? testResult;

  bool get isEdit => officeId != null;

  Future<void> _loadOffice(int id) async {
    loading = true;
    notifyListeners();
    try {
      final office = await _repository.getOffice(id);
      if (office == null) {
        loadError = 'Postal office not found.';
        loading = false;
        notifyListeners();
        return;
      }

      nameController.text = office.name;
      isActive = office.isActive;

      final existingRules = await _repository.getRulesForOffice(id);
      for (final rule in existingRules) {
        rules.add(RuleDraft(
          id: rule.id,
          operation: rule.operation,
          matchMethod: rule.matchMethod,
          startValue: rule.startValue,
          endValue: rule.endValue ?? '',
        ));
      }
    } catch (_) {
      loadError = 'Failed to load postal office details.';
    }
    loading = false;
    notifyListeners();
  }

  void setIsActive(bool value) {
    isActive = value;
    notifyListeners();
  }

  void addRule() {
    rules.add(RuleDraft());
    notifyListeners();
  }

  void removeRule(int index) {
    if (index >= 0 && index < rules.length) {
      final removed = rules.removeAt(index);
      removed.dispose();
      notifyListeners();
    }
  }

  void setRuleOperation(int index, String operation) {
    if (index >= 0 && index < rules.length) {
      rules[index].operation = operation;
      notifyListeners();
    }
  }

  void setRuleMatchMethod(int index, String matchMethod) {
    if (index >= 0 && index < rules.length) {
      rules[index].matchMethod = matchMethod;
      notifyListeners();
    }
  }

  void runPincodeTest() {
    final pincode = testPincodeController.text.trim();
    final compiledRules = <PostalOfficeRule>[];
    for (var i = 0; i < rules.length; i++) {
      if (rules[i].validate() == null) {
        compiledRules.add(rules[i].toRule(officeId ?? 0, i + 1));
      }
    }
    testResult = const PincodeMatcher().testPincode(pincode, compiledRules);
    notifyListeners();
  }

  Future<bool> save() async {
    saveError = null;
    final trimmedName = nameController.text.trim();
    if (trimmedName.isEmpty) {
      saveError = 'Office name cannot be empty.';
      notifyListeners();
      return false;
    }

    for (var i = 0; i < rules.length; i++) {
      final err = rules[i].validate();
      if (err != null) {
        saveError = 'Rule ${i + 1}: $err';
        notifyListeners();
        return false;
      }
    }

    isSaving = true;
    notifyListeners();

    try {
      final companions = rules.map((r) {
        return PostalOfficeRulesCompanion.insert(
          postalOfficeId: officeId ?? -1,
          operation: r.operation,
          matchMethod: r.matchMethod,
          startValue: r.startController.text.trim(),
          endValue: r.matchMethod == 'range'
              ? Value(r.endController.text.trim())
              : const Value(null),
        );
      }).toList();

      await _repository.saveOfficeWithRules(
        id: officeId,
        name: trimmedName,
        isActive: isActive,
        rules: companions,
      );

      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      saveError = 'Unable to save postal office.';
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    testPincodeController.dispose();
    for (final rule in rules) {
      rule.dispose();
    }
    super.dispose();
  }
}
