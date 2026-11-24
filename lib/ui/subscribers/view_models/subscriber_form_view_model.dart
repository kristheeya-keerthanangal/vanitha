import 'package:flutter/foundation.dart';

/// Shared state and validation for editing a subscriber's personal details.
class SubscriberFormViewModel extends ChangeNotifier {
  String name = '';
  String email = '';
  String phone = '';
  String postalAddress = '';
  String postalCode = '';
  bool isForeign = false;
  bool _disposed = false;

  bool get isDisposed => _disposed;

  void setName(String value) => _set(() => name = value);

  void setEmail(String value) => _set(() => email = value);

  void setPhone(String value) => _set(() => phone = value);

  void setPostalAddress(String value) => _set(() => postalAddress = value);

  void setPostalCode(String value) => _set(() => postalCode = value);

  void setIsForeign(bool value) => _set(() => isForeign = value);

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

  /// Trims optional text and treats a blank value as missing.
  String? normalizeOptional(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
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
