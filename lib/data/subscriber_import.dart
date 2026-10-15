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

  const fields = {'subscriber_name', 'address', 'pincode'};
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
    final extra = row.keys.toSet().difference(fields);
    if (extra.isNotEmpty) {
      throw FormatException('$label: unexpected field "${extra.first}".');
    }
    entries.add(
      SubscriberImportEntry(
        name: row['subscriber_name'] as String,
        address: row['address'] as String,
        pincode: row['pincode'] as String,
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
