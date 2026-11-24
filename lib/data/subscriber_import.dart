import 'dart:convert';

class SubscriberImportEntry {
  SubscriberImportEntry({
    required String name,
    required String address,
    required String pincode,
  }) : name = name.trim(),
       address = address.trim(),
       pincode = pincode.trim() {
    if (this.name.isEmpty || this.address.isEmpty || this.pincode.isEmpty) {
      throw ArgumentError('Import fields must not be blank');
    }
  }

  final String name;
  final String address;
  final String pincode;

  (String, String, String) get identity => (name, address, pincode);
}

List<SubscriberImportEntry> parseSubscriberImport(String contents) {
  final Object? decoded;
  try {
    decoded = jsonDecode(contents.replaceFirst(RegExp(r'^\uFEFF'), ''));
  } on FormatException {
    throw const FormatException('Invalid JSON. Select a valid JSON file.');
  }
  if (decoded is! List || decoded.isEmpty) {
    throw const FormatException(
      'Expected a nonempty JSON array of subscribers.',
    );
  }

  // Exports include IDs, contact details, timestamps, and archive state. The
  // importer deliberately uses only the subscriber fields it supports.
  const fields = {'name', 'postalAddress', 'postalCode'};
  final entries = <SubscriberImportEntry>[];
  for (var index = 0; index < decoded.length; index++) {
    final row = decoded[index];
    final label = 'Entry ${index + 1}';
    if (row is! Map<String, dynamic>) {
      throw FormatException('$label must be an object.');
    }
    for (final field in fields) {
      if (!row.containsKey(field)) {
        throw FormatException('$label: missing field "$field".');
      }
      final value = row[field];
      if (value is! String || value.trim().isEmpty) {
        throw FormatException('$label: "$field" must be a nonempty string.');
      }
    }
    entries.add(
      SubscriberImportEntry(
        name: row['name'] as String,
        address: row['postalAddress'] as String,
        pincode: row['postalCode'] as String,
      ),
    );
  }
  return List.unmodifiable(entries);
}

class SubscriberImportPreview {
  SubscriberImportPreview({
    required this.total,
    required List<SubscriberImportEntry> entries,
  }) : entries = List.unmodifiable(entries);

  final int total;
  final List<SubscriberImportEntry> entries;
  int get toInsert => entries.length;
  int get skipped => total - toInsert;
}

class SubscriberImportResult {
  const SubscriberImportResult({required this.inserted, required this.skipped});

  final int inserted;
  final int skipped;
}

class CompleteSubscriptionImportEntry {
  const CompleteSubscriptionImportEntry({
    required this.edition,
    required this.planType,
    required this.durationYears,
    required this.startDate,
    required this.expiryDate,
    this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  final String edition;
  final String planType;
  final int durationYears;
  final String startDate;
  final String expiryDate;
  final String? createdAt;
  final String? updatedAt;
  final String? archivedAt;
}

class CompleteSubscriberImportEntry {
  CompleteSubscriberImportEntry({
    required String name,
    this.email,
    this.phone,
    this.postalAddress,
    this.postalCode,
    this.isForeign = false,
    this.createdAt,
    this.updatedAt,
    this.archivedAt,
    this.subscriptions = const [],
  }) : name = name.trim() {
    if (this.name.isEmpty) {
      throw ArgumentError('Subscriber name must not be blank');
    }
  }

  final String name;
  final String? email;
  final String? phone;
  final String? postalAddress;
  final String? postalCode;
  final bool isForeign;
  final String? createdAt;
  final String? updatedAt;
  final String? archivedAt;
  final List<CompleteSubscriptionImportEntry> subscriptions;

  (String, String, String, String, String) get identity => (
    name,
    postalAddress?.trim() ?? '',
    postalCode?.trim() ?? '',
    email?.trim() ?? '',
    phone?.trim() ?? '',
  );
}

List<CompleteSubscriberImportEntry> parseCompleteSubscriberImport(
  String contents,
) {
  final Object? decoded;
  try {
    decoded = jsonDecode(contents.replaceFirst(RegExp(r'^\uFEFF'), ''));
  } on FormatException {
    throw const FormatException('Invalid JSON. Select a valid JSON file.');
  }

  final List<dynamic> list;
  if (decoded is List) {
    list = decoded;
  } else if (decoded is Map<String, dynamic> &&
      decoded['subscribers'] is List) {
    list = decoded['subscribers'] as List;
  } else {
    throw const FormatException(
      'Expected a nonempty JSON array of subscribers.',
    );
  }

  if (list.isEmpty) {
    throw const FormatException(
      'Expected a nonempty JSON array of subscribers.',
    );
  }

  final entries = <CompleteSubscriberImportEntry>[];
  for (var index = 0; index < list.length; index++) {
    final row = list[index];
    final label = 'Entry ${index + 1}';
    if (row is! Map<String, dynamic>) {
      throw FormatException('$label must be an object.');
    }

    if (!row.containsKey('name')) {
      throw FormatException('$label: missing field "name".');
    }
    final nameVal = row['name'];
    if (nameVal is! String || nameVal.trim().isEmpty) {
      throw FormatException('$label: "name" must be a nonempty string.');
    }

    String? parseOptionalString(String field) {
      if (!row.containsKey(field) || row[field] == null) return null;
      final val = row[field];
      if (val is! String) {
        throw FormatException('$label: "$field" must be a string or null.');
      }
      return val.trim().isEmpty ? null : val.trim();
    }

    final email = parseOptionalString('email');
    final phone = parseOptionalString('phone');
    final postalAddress = parseOptionalString('postalAddress');
    final postalCode = parseOptionalString('postalCode');

    bool isForeign = false;
    if (row.containsKey('isForeign') && row['isForeign'] != null) {
      final val = row['isForeign'];
      if (val is! bool) {
        throw FormatException('$label: "isForeign" must be a boolean.');
      }
      isForeign = val;
    }

    final createdAt = parseOptionalString('createdAt');
    final updatedAt = parseOptionalString('updatedAt');
    final archivedAt = parseOptionalString('archivedAt');

    final subscriptions = <CompleteSubscriptionImportEntry>[];
    if (row.containsKey('subscriptions') && row['subscriptions'] != null) {
      final subs = row['subscriptions'];
      if (subs is! List) {
        throw FormatException('$label: "subscriptions" must be an array.');
      }
      for (var subIndex = 0; subIndex < subs.length; subIndex++) {
        final sub = subs[subIndex];
        final subLabel = '$label, subscription ${subIndex + 1}';
        if (sub is! Map<String, dynamic>) {
          throw FormatException('$subLabel must be an object.');
        }

        final edition = sub['edition'];
        if (edition is! String || (edition != 'online' && edition != 'offline')) {
          throw FormatException(
            '$subLabel: "edition" must be "online" or "offline".',
          );
        }

        final planType = sub['planType'];
        if (planType is! String ||
            (planType != 'annual' &&
                planType != 'multi_year' &&
                planType != 'lifetime')) {
          throw FormatException(
            '$subLabel: "planType" must be "annual", "multi_year", or "lifetime".',
          );
        }

        final durationYears = sub['durationYears'];
        if (durationYears is! int) {
          throw FormatException(
            '$subLabel: "durationYears" must be an integer.',
          );
        }

        final validDuration = switch (planType) {
          'annual' => durationYears == 1,
          'lifetime' => durationYears == 15,
          'multi_year' => durationYears > 1 && durationYears <= 50,
          _ => false,
        };
        if (!validDuration) {
          throw FormatException(
            '$subLabel: invalid durationYears $durationYears for planType "$planType".',
          );
        }

        final startDate = sub['startDate'];
        if (startDate is! String || startDate.trim().isEmpty) {
          throw FormatException(
            '$subLabel: "startDate" must be a nonempty string.',
          );
        }

        final expiryDate = sub['expiryDate'];
        if (expiryDate is! String || expiryDate.trim().isEmpty) {
          throw FormatException(
            '$subLabel: "expiryDate" must be a nonempty string.',
          );
        }

        String? subOptString(String field) {
          if (!sub.containsKey(field) || sub[field] == null) return null;
          final val = sub[field];
          if (val is! String) {
            throw FormatException('$subLabel: "$field" must be a string or null.');
          }
          return val.trim().isEmpty ? null : val.trim();
        }

        subscriptions.add(
          CompleteSubscriptionImportEntry(
            edition: edition,
            planType: planType,
            durationYears: durationYears,
            startDate: startDate.trim(),
            expiryDate: expiryDate.trim(),
            createdAt: subOptString('createdAt'),
            updatedAt: subOptString('updatedAt'),
            archivedAt: subOptString('archivedAt'),
          ),
        );
      }
    }

    entries.add(
      CompleteSubscriberImportEntry(
        name: nameVal,
        email: email,
        phone: phone,
        postalAddress: postalAddress,
        postalCode: postalCode,
        isForeign: isForeign,
        createdAt: createdAt,
        updatedAt: updatedAt,
        archivedAt: archivedAt,
        subscriptions: subscriptions,
      ),
    );
  }

  return List.unmodifiable(entries);
}

class CompleteImportPreview {
  CompleteImportPreview({
    required this.totalSubscribers,
    required List<CompleteSubscriberImportEntry> entries,
  }) : entries = List.unmodifiable(entries);

  final int totalSubscribers;
  final List<CompleteSubscriberImportEntry> entries;

  int get subscribersToInsert => entries.length;
  int get subscribersSkipped => totalSubscribers - subscribersToInsert;

  int get totalSubscriptionsToInsert => entries.fold<int>(
    0,
    (count, entry) => count + entry.subscriptions.length,
  );
}

class CompleteImportResult {
  const CompleteImportResult({
    required this.subscribersInserted,
    required this.subscribersSkipped,
    required this.subscriptionsInserted,
  });

  final int subscribersInserted;
  final int subscribersSkipped;
  final int subscriptionsInserted;
}
