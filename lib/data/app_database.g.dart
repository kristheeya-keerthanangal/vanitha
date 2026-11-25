// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SubscribersTable extends Subscribers
    with TableInfo<$SubscribersTable, Subscriber> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscribersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (LENGTH(TRIM(name)) > 0)',
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postalAddressMeta = const VerificationMeta(
    'postalAddress',
  );
  @override
  late final GeneratedColumn<String> postalAddress = GeneratedColumn<String>(
    'postal_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postalCodeMeta = const VerificationMeta(
    'postalCode',
  );
  @override
  late final GeneratedColumn<String> postalCode = GeneratedColumn<String>(
    'postal_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isForeignMeta = const VerificationMeta(
    'isForeign',
  );
  @override
  late final GeneratedColumn<bool> isForeign = GeneratedColumn<bool>(
    'is_foreign',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_foreign" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
    defaultValue: const CustomExpression('CURRENT_TIMESTAMP'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
    defaultValue: const CustomExpression('CURRENT_TIMESTAMP'),
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<String> archivedAt = GeneratedColumn<String>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    phone,
    postalAddress,
    postalCode,
    isForeign,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscribers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subscriber> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('postal_address')) {
      context.handle(
        _postalAddressMeta,
        postalAddress.isAcceptableOrUnknown(
          data['postal_address']!,
          _postalAddressMeta,
        ),
      );
    }
    if (data.containsKey('postal_code')) {
      context.handle(
        _postalCodeMeta,
        postalCode.isAcceptableOrUnknown(data['postal_code']!, _postalCodeMeta),
      );
    }
    if (data.containsKey('is_foreign')) {
      context.handle(
        _isForeignMeta,
        isForeign.isAcceptableOrUnknown(data['is_foreign']!, _isForeignMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subscriber map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subscriber(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      postalAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postal_address'],
      ),
      postalCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postal_code'],
      ),
      isForeign: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_foreign'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $SubscribersTable createAlias(String alias) {
    return $SubscribersTable(attachedDatabase, alias);
  }
}

class Subscriber extends DataClass implements Insertable<Subscriber> {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? postalAddress;
  final String? postalCode;
  final bool isForeign;
  final String createdAt;
  final String updatedAt;
  final String? archivedAt;
  const Subscriber({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.postalAddress,
    this.postalCode,
    required this.isForeign,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || postalAddress != null) {
      map['postal_address'] = Variable<String>(postalAddress);
    }
    if (!nullToAbsent || postalCode != null) {
      map['postal_code'] = Variable<String>(postalCode);
    }
    map['is_foreign'] = Variable<bool>(isForeign);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<String>(archivedAt);
    }
    return map;
  }

  SubscribersCompanion toCompanion(bool nullToAbsent) {
    return SubscribersCompanion(
      id: Value(id),
      name: Value(name),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      postalAddress: postalAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(postalAddress),
      postalCode: postalCode == null && nullToAbsent
          ? const Value.absent()
          : Value(postalCode),
      isForeign: Value(isForeign),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Subscriber.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subscriber(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      postalAddress: serializer.fromJson<String?>(json['postalAddress']),
      postalCode: serializer.fromJson<String?>(json['postalCode']),
      isForeign: serializer.fromJson<bool>(json['isForeign']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      archivedAt: serializer.fromJson<String?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'postalAddress': serializer.toJson<String?>(postalAddress),
      'postalCode': serializer.toJson<String?>(postalCode),
      'isForeign': serializer.toJson<bool>(isForeign),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'archivedAt': serializer.toJson<String?>(archivedAt),
    };
  }

  Subscriber copyWith({
    int? id,
    String? name,
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> postalAddress = const Value.absent(),
    Value<String?> postalCode = const Value.absent(),
    bool? isForeign,
    String? createdAt,
    String? updatedAt,
    Value<String?> archivedAt = const Value.absent(),
  }) => Subscriber(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    postalAddress: postalAddress.present
        ? postalAddress.value
        : this.postalAddress,
    postalCode: postalCode.present ? postalCode.value : this.postalCode,
    isForeign: isForeign ?? this.isForeign,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Subscriber copyWithCompanion(SubscribersCompanion data) {
    return Subscriber(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      postalAddress: data.postalAddress.present
          ? data.postalAddress.value
          : this.postalAddress,
      postalCode: data.postalCode.present
          ? data.postalCode.value
          : this.postalCode,
      isForeign: data.isForeign.present ? data.isForeign.value : this.isForeign,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subscriber(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('postalAddress: $postalAddress, ')
          ..write('postalCode: $postalCode, ')
          ..write('isForeign: $isForeign, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    phone,
    postalAddress,
    postalCode,
    isForeign,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscriber &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.postalAddress == this.postalAddress &&
          other.postalCode == this.postalCode &&
          other.isForeign == this.isForeign &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class SubscribersCompanion extends UpdateCompanion<Subscriber> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> postalAddress;
  final Value<String?> postalCode;
  final Value<bool> isForeign;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> archivedAt;
  const SubscribersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.postalAddress = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.isForeign = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  });
  SubscribersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.postalAddress = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.isForeign = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Subscriber> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? postalAddress,
    Expression<String>? postalCode,
    Expression<bool>? isForeign,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? archivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (postalAddress != null) 'postal_address': postalAddress,
      if (postalCode != null) 'postal_code': postalCode,
      if (isForeign != null) 'is_foreign': isForeign,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
    });
  }

  SubscribersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String?>? postalAddress,
    Value<String?>? postalCode,
    Value<bool>? isForeign,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? archivedAt,
  }) {
    return SubscribersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      postalAddress: postalAddress ?? this.postalAddress,
      postalCode: postalCode ?? this.postalCode,
      isForeign: isForeign ?? this.isForeign,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (postalAddress.present) {
      map['postal_address'] = Variable<String>(postalAddress.value);
    }
    if (postalCode.present) {
      map['postal_code'] = Variable<String>(postalCode.value);
    }
    if (isForeign.present) {
      map['is_foreign'] = Variable<bool>(isForeign.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<String>(archivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscribersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('postalAddress: $postalAddress, ')
          ..write('postalCode: $postalCode, ')
          ..write('isForeign: $isForeign, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _subscriberIdMeta = const VerificationMeta(
    'subscriberId',
  );
  @override
  late final GeneratedColumn<int> subscriberId = GeneratedColumn<int>(
    'subscriber_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subscribers (id)',
    ),
  );
  static const VerificationMeta _previousValuesMeta = const VerificationMeta(
    'previousValues',
  );
  @override
  late final GeneratedColumn<String> previousValues = GeneratedColumn<String>(
    'previous_values',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedValuesMeta = const VerificationMeta(
    'updatedValues',
  );
  @override
  late final GeneratedColumn<String> updatedValues = GeneratedColumn<String>(
    'updated_values',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modifiedAtMeta = const VerificationMeta(
    'modifiedAt',
  );
  @override
  late final GeneratedColumn<String> modifiedAt = GeneratedColumn<String>(
    'modified_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
    defaultValue: const CustomExpression('CURRENT_TIMESTAMP'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subscriberId,
    previousValues,
    updatedValues,
    modifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subscriber_id')) {
      context.handle(
        _subscriberIdMeta,
        subscriberId.isAcceptableOrUnknown(
          data['subscriber_id']!,
          _subscriberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscriberIdMeta);
    }
    if (data.containsKey('previous_values')) {
      context.handle(
        _previousValuesMeta,
        previousValues.isAcceptableOrUnknown(
          data['previous_values']!,
          _previousValuesMeta,
        ),
      );
    }
    if (data.containsKey('updated_values')) {
      context.handle(
        _updatedValuesMeta,
        updatedValues.isAcceptableOrUnknown(
          data['updated_values']!,
          _updatedValuesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedValuesMeta);
    }
    if (data.containsKey('modified_at')) {
      context.handle(
        _modifiedAtMeta,
        modifiedAt.isAcceptableOrUnknown(data['modified_at']!, _modifiedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      subscriberId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subscriber_id'],
      )!,
      previousValues: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_values'],
      ),
      updatedValues: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_values'],
      )!,
      modifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}modified_at'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final int id;
  final int subscriberId;
  final String? previousValues;
  final String updatedValues;
  final String modifiedAt;
  const AuditLog({
    required this.id,
    required this.subscriberId,
    this.previousValues,
    required this.updatedValues,
    required this.modifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subscriber_id'] = Variable<int>(subscriberId);
    if (!nullToAbsent || previousValues != null) {
      map['previous_values'] = Variable<String>(previousValues);
    }
    map['updated_values'] = Variable<String>(updatedValues);
    map['modified_at'] = Variable<String>(modifiedAt);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      subscriberId: Value(subscriberId),
      previousValues: previousValues == null && nullToAbsent
          ? const Value.absent()
          : Value(previousValues),
      updatedValues: Value(updatedValues),
      modifiedAt: Value(modifiedAt),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<int>(json['id']),
      subscriberId: serializer.fromJson<int>(json['subscriberId']),
      previousValues: serializer.fromJson<String?>(json['previousValues']),
      updatedValues: serializer.fromJson<String>(json['updatedValues']),
      modifiedAt: serializer.fromJson<String>(json['modifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subscriberId': serializer.toJson<int>(subscriberId),
      'previousValues': serializer.toJson<String?>(previousValues),
      'updatedValues': serializer.toJson<String>(updatedValues),
      'modifiedAt': serializer.toJson<String>(modifiedAt),
    };
  }

  AuditLog copyWith({
    int? id,
    int? subscriberId,
    Value<String?> previousValues = const Value.absent(),
    String? updatedValues,
    String? modifiedAt,
  }) => AuditLog(
    id: id ?? this.id,
    subscriberId: subscriberId ?? this.subscriberId,
    previousValues: previousValues.present
        ? previousValues.value
        : this.previousValues,
    updatedValues: updatedValues ?? this.updatedValues,
    modifiedAt: modifiedAt ?? this.modifiedAt,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      subscriberId: data.subscriberId.present
          ? data.subscriberId.value
          : this.subscriberId,
      previousValues: data.previousValues.present
          ? data.previousValues.value
          : this.previousValues,
      updatedValues: data.updatedValues.present
          ? data.updatedValues.value
          : this.updatedValues,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('subscriberId: $subscriberId, ')
          ..write('previousValues: $previousValues, ')
          ..write('updatedValues: $updatedValues, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, subscriberId, previousValues, updatedValues, modifiedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.subscriberId == this.subscriberId &&
          other.previousValues == this.previousValues &&
          other.updatedValues == this.updatedValues &&
          other.modifiedAt == this.modifiedAt);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<int> id;
  final Value<int> subscriberId;
  final Value<String?> previousValues;
  final Value<String> updatedValues;
  final Value<String> modifiedAt;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.subscriberId = const Value.absent(),
    this.previousValues = const Value.absent(),
    this.updatedValues = const Value.absent(),
    this.modifiedAt = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    this.id = const Value.absent(),
    required int subscriberId,
    this.previousValues = const Value.absent(),
    required String updatedValues,
    this.modifiedAt = const Value.absent(),
  }) : subscriberId = Value(subscriberId),
       updatedValues = Value(updatedValues);
  static Insertable<AuditLog> custom({
    Expression<int>? id,
    Expression<int>? subscriberId,
    Expression<String>? previousValues,
    Expression<String>? updatedValues,
    Expression<String>? modifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subscriberId != null) 'subscriber_id': subscriberId,
      if (previousValues != null) 'previous_values': previousValues,
      if (updatedValues != null) 'updated_values': updatedValues,
      if (modifiedAt != null) 'modified_at': modifiedAt,
    });
  }

  AuditLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? subscriberId,
    Value<String?>? previousValues,
    Value<String>? updatedValues,
    Value<String>? modifiedAt,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      subscriberId: subscriberId ?? this.subscriberId,
      previousValues: previousValues ?? this.previousValues,
      updatedValues: updatedValues ?? this.updatedValues,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subscriberId.present) {
      map['subscriber_id'] = Variable<int>(subscriberId.value);
    }
    if (previousValues.present) {
      map['previous_values'] = Variable<String>(previousValues.value);
    }
    if (updatedValues.present) {
      map['updated_values'] = Variable<String>(updatedValues.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<String>(modifiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('subscriberId: $subscriberId, ')
          ..write('previousValues: $previousValues, ')
          ..write('updatedValues: $updatedValues, ')
          ..write('modifiedAt: $modifiedAt')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionsTable extends Subscriptions
    with TableInfo<$SubscriptionsTable, Subscription> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _subscriberIdMeta = const VerificationMeta(
    'subscriberId',
  );
  @override
  late final GeneratedColumn<int> subscriberId = GeneratedColumn<int>(
    'subscriber_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subscribers (id)',
    ),
  );
  static const VerificationMeta _editionMeta = const VerificationMeta(
    'edition',
  );
  @override
  late final GeneratedColumn<String> edition = GeneratedColumn<String>(
    'edition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (edition IN (\'online\', \'offline\'))',
  );
  static const VerificationMeta _planTypeMeta = const VerificationMeta(
    'planType',
  );
  @override
  late final GeneratedColumn<String> planType = GeneratedColumn<String>(
    'plan_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (plan_type IN (\'annual\', \'multi_year\', \'lifetime\'))',
  );
  static const VerificationMeta _durationYearsMeta = const VerificationMeta(
    'durationYears',
  );
  @override
  late final GeneratedColumn<int> durationYears = GeneratedColumn<int>(
    'duration_years',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints:
        '    NOT NULL CHECK (\n      (plan_type = \'annual\' AND duration_years = 1) OR\n      (plan_type = \'multi_year\' AND duration_years > 1 AND duration_years <= 50) OR\n      (plan_type = \'lifetime\' AND duration_years = 15)\n    )\n  ',
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiryDateMeta = const VerificationMeta(
    'expiryDate',
  );
  @override
  late final GeneratedColumn<String> expiryDate = GeneratedColumn<String>(
    'expiry_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
    defaultValue: const CustomExpression('CURRENT_TIMESTAMP'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
    defaultValue: const CustomExpression('CURRENT_TIMESTAMP'),
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<String> archivedAt = GeneratedColumn<String>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subscriberId,
    edition,
    planType,
    durationYears,
    startDate,
    expiryDate,
    createdAt,
    updatedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscriptions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subscription> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subscriber_id')) {
      context.handle(
        _subscriberIdMeta,
        subscriberId.isAcceptableOrUnknown(
          data['subscriber_id']!,
          _subscriberIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscriberIdMeta);
    }
    if (data.containsKey('edition')) {
      context.handle(
        _editionMeta,
        edition.isAcceptableOrUnknown(data['edition']!, _editionMeta),
      );
    } else if (isInserting) {
      context.missing(_editionMeta);
    }
    if (data.containsKey('plan_type')) {
      context.handle(
        _planTypeMeta,
        planType.isAcceptableOrUnknown(data['plan_type']!, _planTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_planTypeMeta);
    }
    if (data.containsKey('duration_years')) {
      context.handle(
        _durationYearsMeta,
        durationYears.isAcceptableOrUnknown(
          data['duration_years']!,
          _durationYearsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationYearsMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('expiry_date')) {
      context.handle(
        _expiryDateMeta,
        expiryDate.isAcceptableOrUnknown(data['expiry_date']!, _expiryDateMeta),
      );
    } else if (isInserting) {
      context.missing(_expiryDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subscription map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subscription(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      subscriberId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subscriber_id'],
      )!,
      edition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}edition'],
      )!,
      planType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plan_type'],
      )!,
      durationYears: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_years'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      expiryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expiry_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archived_at'],
      ),
    );
  }

  @override
  $SubscriptionsTable createAlias(String alias) {
    return $SubscriptionsTable(attachedDatabase, alias);
  }
}

class Subscription extends DataClass implements Insertable<Subscription> {
  final int id;
  final int subscriberId;
  final String edition;
  final String planType;
  final int durationYears;
  final String startDate;
  final String expiryDate;
  final String createdAt;
  final String updatedAt;
  final String? archivedAt;
  const Subscription({
    required this.id,
    required this.subscriberId,
    required this.edition,
    required this.planType,
    required this.durationYears,
    required this.startDate,
    required this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subscriber_id'] = Variable<int>(subscriberId);
    map['edition'] = Variable<String>(edition);
    map['plan_type'] = Variable<String>(planType);
    map['duration_years'] = Variable<int>(durationYears);
    map['start_date'] = Variable<String>(startDate);
    map['expiry_date'] = Variable<String>(expiryDate);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<String>(archivedAt);
    }
    return map;
  }

  SubscriptionsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionsCompanion(
      id: Value(id),
      subscriberId: Value(subscriberId),
      edition: Value(edition),
      planType: Value(planType),
      durationYears: Value(durationYears),
      startDate: Value(startDate),
      expiryDate: Value(expiryDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory Subscription.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subscription(
      id: serializer.fromJson<int>(json['id']),
      subscriberId: serializer.fromJson<int>(json['subscriberId']),
      edition: serializer.fromJson<String>(json['edition']),
      planType: serializer.fromJson<String>(json['planType']),
      durationYears: serializer.fromJson<int>(json['durationYears']),
      startDate: serializer.fromJson<String>(json['startDate']),
      expiryDate: serializer.fromJson<String>(json['expiryDate']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      archivedAt: serializer.fromJson<String?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subscriberId': serializer.toJson<int>(subscriberId),
      'edition': serializer.toJson<String>(edition),
      'planType': serializer.toJson<String>(planType),
      'durationYears': serializer.toJson<int>(durationYears),
      'startDate': serializer.toJson<String>(startDate),
      'expiryDate': serializer.toJson<String>(expiryDate),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'archivedAt': serializer.toJson<String?>(archivedAt),
    };
  }

  Subscription copyWith({
    int? id,
    int? subscriberId,
    String? edition,
    String? planType,
    int? durationYears,
    String? startDate,
    String? expiryDate,
    String? createdAt,
    String? updatedAt,
    Value<String?> archivedAt = const Value.absent(),
  }) => Subscription(
    id: id ?? this.id,
    subscriberId: subscriberId ?? this.subscriberId,
    edition: edition ?? this.edition,
    planType: planType ?? this.planType,
    durationYears: durationYears ?? this.durationYears,
    startDate: startDate ?? this.startDate,
    expiryDate: expiryDate ?? this.expiryDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Subscription copyWithCompanion(SubscriptionsCompanion data) {
    return Subscription(
      id: data.id.present ? data.id.value : this.id,
      subscriberId: data.subscriberId.present
          ? data.subscriberId.value
          : this.subscriberId,
      edition: data.edition.present ? data.edition.value : this.edition,
      planType: data.planType.present ? data.planType.value : this.planType,
      durationYears: data.durationYears.present
          ? data.durationYears.value
          : this.durationYears,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      expiryDate: data.expiryDate.present
          ? data.expiryDate.value
          : this.expiryDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subscription(')
          ..write('id: $id, ')
          ..write('subscriberId: $subscriberId, ')
          ..write('edition: $edition, ')
          ..write('planType: $planType, ')
          ..write('durationYears: $durationYears, ')
          ..write('startDate: $startDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subscriberId,
    edition,
    planType,
    durationYears,
    startDate,
    expiryDate,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscription &&
          other.id == this.id &&
          other.subscriberId == this.subscriberId &&
          other.edition == this.edition &&
          other.planType == this.planType &&
          other.durationYears == this.durationYears &&
          other.startDate == this.startDate &&
          other.expiryDate == this.expiryDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class SubscriptionsCompanion extends UpdateCompanion<Subscription> {
  final Value<int> id;
  final Value<int> subscriberId;
  final Value<String> edition;
  final Value<String> planType;
  final Value<int> durationYears;
  final Value<String> startDate;
  final Value<String> expiryDate;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> archivedAt;
  const SubscriptionsCompanion({
    this.id = const Value.absent(),
    this.subscriberId = const Value.absent(),
    this.edition = const Value.absent(),
    this.planType = const Value.absent(),
    this.durationYears = const Value.absent(),
    this.startDate = const Value.absent(),
    this.expiryDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  });
  SubscriptionsCompanion.insert({
    this.id = const Value.absent(),
    required int subscriberId,
    required String edition,
    required String planType,
    required int durationYears,
    required String startDate,
    required String expiryDate,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  }) : subscriberId = Value(subscriberId),
       edition = Value(edition),
       planType = Value(planType),
       durationYears = Value(durationYears),
       startDate = Value(startDate),
       expiryDate = Value(expiryDate);
  static Insertable<Subscription> custom({
    Expression<int>? id,
    Expression<int>? subscriberId,
    Expression<String>? edition,
    Expression<String>? planType,
    Expression<int>? durationYears,
    Expression<String>? startDate,
    Expression<String>? expiryDate,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? archivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subscriberId != null) 'subscriber_id': subscriberId,
      if (edition != null) 'edition': edition,
      if (planType != null) 'plan_type': planType,
      if (durationYears != null) 'duration_years': durationYears,
      if (startDate != null) 'start_date': startDate,
      if (expiryDate != null) 'expiry_date': expiryDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
    });
  }

  SubscriptionsCompanion copyWith({
    Value<int>? id,
    Value<int>? subscriberId,
    Value<String>? edition,
    Value<String>? planType,
    Value<int>? durationYears,
    Value<String>? startDate,
    Value<String>? expiryDate,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? archivedAt,
  }) {
    return SubscriptionsCompanion(
      id: id ?? this.id,
      subscriberId: subscriberId ?? this.subscriberId,
      edition: edition ?? this.edition,
      planType: planType ?? this.planType,
      durationYears: durationYears ?? this.durationYears,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subscriberId.present) {
      map['subscriber_id'] = Variable<int>(subscriberId.value);
    }
    if (edition.present) {
      map['edition'] = Variable<String>(edition.value);
    }
    if (planType.present) {
      map['plan_type'] = Variable<String>(planType.value);
    }
    if (durationYears.present) {
      map['duration_years'] = Variable<int>(durationYears.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (expiryDate.present) {
      map['expiry_date'] = Variable<String>(expiryDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<String>(archivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionsCompanion(')
          ..write('id: $id, ')
          ..write('subscriberId: $subscriberId, ')
          ..write('edition: $edition, ')
          ..write('planType: $planType, ')
          ..write('durationYears: $durationYears, ')
          ..write('startDate: $startDate, ')
          ..write('expiryDate: $expiryDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }
}

class $MigrationSnapshotsTable extends MigrationSnapshots
    with TableInfo<$MigrationSnapshotsTable, MigrationSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MigrationSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceTableMeta = const VerificationMeta(
    'sourceTable',
  );
  @override
  late final GeneratedColumn<String> sourceTable = GeneratedColumn<String>(
    'source_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<int> rowId = GeneratedColumn<int>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceVersionMeta = const VerificationMeta(
    'sourceVersion',
  );
  @override
  late final GeneratedColumn<int> sourceVersion = GeneratedColumn<int>(
    'source_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valuesJsonMeta = const VerificationMeta(
    'valuesJson',
  );
  @override
  late final GeneratedColumn<String> valuesJson = GeneratedColumn<String>(
    'values_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceTable,
    rowId,
    sourceVersion,
    valuesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'migration_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<MigrationSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_table')) {
      context.handle(
        _sourceTableMeta,
        sourceTable.isAcceptableOrUnknown(
          data['source_table']!,
          _sourceTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceTableMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('source_version')) {
      context.handle(
        _sourceVersionMeta,
        sourceVersion.isAcceptableOrUnknown(
          data['source_version']!,
          _sourceVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceVersionMeta);
    }
    if (data.containsKey('values_json')) {
      context.handle(
        _valuesJsonMeta,
        valuesJson.isAcceptableOrUnknown(data['values_json']!, _valuesJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_valuesJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceTable, rowId, sourceVersion};
  @override
  MigrationSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MigrationSnapshot(
      sourceTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_table'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}row_id'],
      )!,
      sourceVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_version'],
      )!,
      valuesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}values_json'],
      )!,
    );
  }

  @override
  $MigrationSnapshotsTable createAlias(String alias) {
    return $MigrationSnapshotsTable(attachedDatabase, alias);
  }
}

class MigrationSnapshot extends DataClass
    implements Insertable<MigrationSnapshot> {
  final String sourceTable;
  final int rowId;
  final int sourceVersion;
  final String valuesJson;
  const MigrationSnapshot({
    required this.sourceTable,
    required this.rowId,
    required this.sourceVersion,
    required this.valuesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_table'] = Variable<String>(sourceTable);
    map['row_id'] = Variable<int>(rowId);
    map['source_version'] = Variable<int>(sourceVersion);
    map['values_json'] = Variable<String>(valuesJson);
    return map;
  }

  MigrationSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return MigrationSnapshotsCompanion(
      sourceTable: Value(sourceTable),
      rowId: Value(rowId),
      sourceVersion: Value(sourceVersion),
      valuesJson: Value(valuesJson),
    );
  }

  factory MigrationSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MigrationSnapshot(
      sourceTable: serializer.fromJson<String>(json['sourceTable']),
      rowId: serializer.fromJson<int>(json['rowId']),
      sourceVersion: serializer.fromJson<int>(json['sourceVersion']),
      valuesJson: serializer.fromJson<String>(json['valuesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceTable': serializer.toJson<String>(sourceTable),
      'rowId': serializer.toJson<int>(rowId),
      'sourceVersion': serializer.toJson<int>(sourceVersion),
      'valuesJson': serializer.toJson<String>(valuesJson),
    };
  }

  MigrationSnapshot copyWith({
    String? sourceTable,
    int? rowId,
    int? sourceVersion,
    String? valuesJson,
  }) => MigrationSnapshot(
    sourceTable: sourceTable ?? this.sourceTable,
    rowId: rowId ?? this.rowId,
    sourceVersion: sourceVersion ?? this.sourceVersion,
    valuesJson: valuesJson ?? this.valuesJson,
  );
  MigrationSnapshot copyWithCompanion(MigrationSnapshotsCompanion data) {
    return MigrationSnapshot(
      sourceTable: data.sourceTable.present
          ? data.sourceTable.value
          : this.sourceTable,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      sourceVersion: data.sourceVersion.present
          ? data.sourceVersion.value
          : this.sourceVersion,
      valuesJson: data.valuesJson.present
          ? data.valuesJson.value
          : this.valuesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MigrationSnapshot(')
          ..write('sourceTable: $sourceTable, ')
          ..write('rowId: $rowId, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('valuesJson: $valuesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sourceTable, rowId, sourceVersion, valuesJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MigrationSnapshot &&
          other.sourceTable == this.sourceTable &&
          other.rowId == this.rowId &&
          other.sourceVersion == this.sourceVersion &&
          other.valuesJson == this.valuesJson);
}

class MigrationSnapshotsCompanion extends UpdateCompanion<MigrationSnapshot> {
  final Value<String> sourceTable;
  final Value<int> rowId;
  final Value<int> sourceVersion;
  final Value<String> valuesJson;
  final Value<int> rowid;
  const MigrationSnapshotsCompanion({
    this.sourceTable = const Value.absent(),
    this.rowId = const Value.absent(),
    this.sourceVersion = const Value.absent(),
    this.valuesJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MigrationSnapshotsCompanion.insert({
    required String sourceTable,
    required int rowId,
    required int sourceVersion,
    required String valuesJson,
    this.rowid = const Value.absent(),
  }) : sourceTable = Value(sourceTable),
       rowId = Value(rowId),
       sourceVersion = Value(sourceVersion),
       valuesJson = Value(valuesJson);
  static Insertable<MigrationSnapshot> custom({
    Expression<String>? sourceTable,
    Expression<int>? rowId,
    Expression<int>? sourceVersion,
    Expression<String>? valuesJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceTable != null) 'source_table': sourceTable,
      if (rowId != null) 'row_id': rowId,
      if (sourceVersion != null) 'source_version': sourceVersion,
      if (valuesJson != null) 'values_json': valuesJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MigrationSnapshotsCompanion copyWith({
    Value<String>? sourceTable,
    Value<int>? rowId,
    Value<int>? sourceVersion,
    Value<String>? valuesJson,
    Value<int>? rowid,
  }) {
    return MigrationSnapshotsCompanion(
      sourceTable: sourceTable ?? this.sourceTable,
      rowId: rowId ?? this.rowId,
      sourceVersion: sourceVersion ?? this.sourceVersion,
      valuesJson: valuesJson ?? this.valuesJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceTable.present) {
      map['source_table'] = Variable<String>(sourceTable.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<int>(rowId.value);
    }
    if (sourceVersion.present) {
      map['source_version'] = Variable<int>(sourceVersion.value);
    }
    if (valuesJson.present) {
      map['values_json'] = Variable<String>(valuesJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MigrationSnapshotsCompanion(')
          ..write('sourceTable: $sourceTable, ')
          ..write('rowId: $rowId, ')
          ..write('sourceVersion: $sourceVersion, ')
          ..write('valuesJson: $valuesJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PostalOfficesTable extends PostalOffices
    with TableInfo<$PostalOfficesTable, PostalOffice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostalOfficesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (LENGTH(TRIM(name)) > 0)',
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
    defaultValue: const CustomExpression('CURRENT_TIMESTAMP'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
    defaultValue: const CustomExpression('CURRENT_TIMESTAMP'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'postal_offices';
  @override
  VerificationContext validateIntegrity(
    Insertable<PostalOffice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostalOffice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostalOffice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PostalOfficesTable createAlias(String alias) {
    return $PostalOfficesTable(attachedDatabase, alias);
  }
}

class PostalOffice extends DataClass implements Insertable<PostalOffice> {
  final int id;
  final String name;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  const PostalOffice({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  PostalOfficesCompanion toCompanion(bool nullToAbsent) {
    return PostalOfficesCompanion(
      id: Value(id),
      name: Value(name),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PostalOffice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostalOffice(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  PostalOffice copyWith({
    int? id,
    String? name,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) => PostalOffice(
    id: id ?? this.id,
    name: name ?? this.name,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PostalOffice copyWithCompanion(PostalOfficesCompanion data) {
    return PostalOffice(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostalOffice(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostalOffice &&
          other.id == this.id &&
          other.name == this.name &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PostalOfficesCompanion extends UpdateCompanion<PostalOffice> {
  final Value<int> id;
  final Value<String> name;
  final Value<bool> isActive;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  const PostalOfficesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PostalOfficesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PostalOffice> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<bool>? isActive,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PostalOfficesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<bool>? isActive,
    Value<String>? createdAt,
    Value<String>? updatedAt,
  }) {
    return PostalOfficesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostalOfficesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PostalOfficeRulesTable extends PostalOfficeRules
    with TableInfo<$PostalOfficeRulesTable, PostalOfficeRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostalOfficeRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _postalOfficeIdMeta = const VerificationMeta(
    'postalOfficeId',
  );
  @override
  late final GeneratedColumn<int> postalOfficeId = GeneratedColumn<int>(
    'postal_office_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES postal_offices (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (operation IN (\'include\', \'exclude\'))',
  );
  static const VerificationMeta _matchMethodMeta = const VerificationMeta(
    'matchMethod',
  );
  @override
  late final GeneratedColumn<String> matchMethod = GeneratedColumn<String>(
    'match_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (match_method IN (\'prefix\', \'range\', \'exact\'))',
  );
  static const VerificationMeta _startValueMeta = const VerificationMeta(
    'startValue',
  );
  @override
  late final GeneratedColumn<String> startValue = GeneratedColumn<String>(
    'start_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (LENGTH(start_value) >= 1 AND LENGTH(start_value) <= 6)',
  );
  static const VerificationMeta _endValueMeta = const VerificationMeta(
    'endValue',
  );
  @override
  late final GeneratedColumn<String> endValue = GeneratedColumn<String>(
    'end_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints:
        'NULL CHECK (end_value IS NULL OR (LENGTH(end_value) = 6))',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    postalOfficeId,
    operation,
    matchMethod,
    startValue,
    endValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'postal_office_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<PostalOfficeRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('postal_office_id')) {
      context.handle(
        _postalOfficeIdMeta,
        postalOfficeId.isAcceptableOrUnknown(
          data['postal_office_id']!,
          _postalOfficeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_postalOfficeIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('match_method')) {
      context.handle(
        _matchMethodMeta,
        matchMethod.isAcceptableOrUnknown(
          data['match_method']!,
          _matchMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_matchMethodMeta);
    }
    if (data.containsKey('start_value')) {
      context.handle(
        _startValueMeta,
        startValue.isAcceptableOrUnknown(data['start_value']!, _startValueMeta),
      );
    } else if (isInserting) {
      context.missing(_startValueMeta);
    }
    if (data.containsKey('end_value')) {
      context.handle(
        _endValueMeta,
        endValue.isAcceptableOrUnknown(data['end_value']!, _endValueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostalOfficeRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostalOfficeRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      postalOfficeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}postal_office_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      matchMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_method'],
      )!,
      startValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_value'],
      )!,
      endValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_value'],
      ),
    );
  }

  @override
  $PostalOfficeRulesTable createAlias(String alias) {
    return $PostalOfficeRulesTable(attachedDatabase, alias);
  }
}

class PostalOfficeRule extends DataClass
    implements Insertable<PostalOfficeRule> {
  final int id;
  final int postalOfficeId;
  final String operation;
  final String matchMethod;
  final String startValue;
  final String? endValue;
  const PostalOfficeRule({
    required this.id,
    required this.postalOfficeId,
    required this.operation,
    required this.matchMethod,
    required this.startValue,
    this.endValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['postal_office_id'] = Variable<int>(postalOfficeId);
    map['operation'] = Variable<String>(operation);
    map['match_method'] = Variable<String>(matchMethod);
    map['start_value'] = Variable<String>(startValue);
    if (!nullToAbsent || endValue != null) {
      map['end_value'] = Variable<String>(endValue);
    }
    return map;
  }

  PostalOfficeRulesCompanion toCompanion(bool nullToAbsent) {
    return PostalOfficeRulesCompanion(
      id: Value(id),
      postalOfficeId: Value(postalOfficeId),
      operation: Value(operation),
      matchMethod: Value(matchMethod),
      startValue: Value(startValue),
      endValue: endValue == null && nullToAbsent
          ? const Value.absent()
          : Value(endValue),
    );
  }

  factory PostalOfficeRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostalOfficeRule(
      id: serializer.fromJson<int>(json['id']),
      postalOfficeId: serializer.fromJson<int>(json['postalOfficeId']),
      operation: serializer.fromJson<String>(json['operation']),
      matchMethod: serializer.fromJson<String>(json['matchMethod']),
      startValue: serializer.fromJson<String>(json['startValue']),
      endValue: serializer.fromJson<String?>(json['endValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'postalOfficeId': serializer.toJson<int>(postalOfficeId),
      'operation': serializer.toJson<String>(operation),
      'matchMethod': serializer.toJson<String>(matchMethod),
      'startValue': serializer.toJson<String>(startValue),
      'endValue': serializer.toJson<String?>(endValue),
    };
  }

  PostalOfficeRule copyWith({
    int? id,
    int? postalOfficeId,
    String? operation,
    String? matchMethod,
    String? startValue,
    Value<String?> endValue = const Value.absent(),
  }) => PostalOfficeRule(
    id: id ?? this.id,
    postalOfficeId: postalOfficeId ?? this.postalOfficeId,
    operation: operation ?? this.operation,
    matchMethod: matchMethod ?? this.matchMethod,
    startValue: startValue ?? this.startValue,
    endValue: endValue.present ? endValue.value : this.endValue,
  );
  PostalOfficeRule copyWithCompanion(PostalOfficeRulesCompanion data) {
    return PostalOfficeRule(
      id: data.id.present ? data.id.value : this.id,
      postalOfficeId: data.postalOfficeId.present
          ? data.postalOfficeId.value
          : this.postalOfficeId,
      operation: data.operation.present ? data.operation.value : this.operation,
      matchMethod: data.matchMethod.present
          ? data.matchMethod.value
          : this.matchMethod,
      startValue: data.startValue.present
          ? data.startValue.value
          : this.startValue,
      endValue: data.endValue.present ? data.endValue.value : this.endValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PostalOfficeRule(')
          ..write('id: $id, ')
          ..write('postalOfficeId: $postalOfficeId, ')
          ..write('operation: $operation, ')
          ..write('matchMethod: $matchMethod, ')
          ..write('startValue: $startValue, ')
          ..write('endValue: $endValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    postalOfficeId,
    operation,
    matchMethod,
    startValue,
    endValue,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostalOfficeRule &&
          other.id == this.id &&
          other.postalOfficeId == this.postalOfficeId &&
          other.operation == this.operation &&
          other.matchMethod == this.matchMethod &&
          other.startValue == this.startValue &&
          other.endValue == this.endValue);
}

class PostalOfficeRulesCompanion extends UpdateCompanion<PostalOfficeRule> {
  final Value<int> id;
  final Value<int> postalOfficeId;
  final Value<String> operation;
  final Value<String> matchMethod;
  final Value<String> startValue;
  final Value<String?> endValue;
  const PostalOfficeRulesCompanion({
    this.id = const Value.absent(),
    this.postalOfficeId = const Value.absent(),
    this.operation = const Value.absent(),
    this.matchMethod = const Value.absent(),
    this.startValue = const Value.absent(),
    this.endValue = const Value.absent(),
  });
  PostalOfficeRulesCompanion.insert({
    this.id = const Value.absent(),
    required int postalOfficeId,
    required String operation,
    required String matchMethod,
    required String startValue,
    this.endValue = const Value.absent(),
  }) : postalOfficeId = Value(postalOfficeId),
       operation = Value(operation),
       matchMethod = Value(matchMethod),
       startValue = Value(startValue);
  static Insertable<PostalOfficeRule> custom({
    Expression<int>? id,
    Expression<int>? postalOfficeId,
    Expression<String>? operation,
    Expression<String>? matchMethod,
    Expression<String>? startValue,
    Expression<String>? endValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (postalOfficeId != null) 'postal_office_id': postalOfficeId,
      if (operation != null) 'operation': operation,
      if (matchMethod != null) 'match_method': matchMethod,
      if (startValue != null) 'start_value': startValue,
      if (endValue != null) 'end_value': endValue,
    });
  }

  PostalOfficeRulesCompanion copyWith({
    Value<int>? id,
    Value<int>? postalOfficeId,
    Value<String>? operation,
    Value<String>? matchMethod,
    Value<String>? startValue,
    Value<String?>? endValue,
  }) {
    return PostalOfficeRulesCompanion(
      id: id ?? this.id,
      postalOfficeId: postalOfficeId ?? this.postalOfficeId,
      operation: operation ?? this.operation,
      matchMethod: matchMethod ?? this.matchMethod,
      startValue: startValue ?? this.startValue,
      endValue: endValue ?? this.endValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (postalOfficeId.present) {
      map['postal_office_id'] = Variable<int>(postalOfficeId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (matchMethod.present) {
      map['match_method'] = Variable<String>(matchMethod.value);
    }
    if (startValue.present) {
      map['start_value'] = Variable<String>(startValue.value);
    }
    if (endValue.present) {
      map['end_value'] = Variable<String>(endValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostalOfficeRulesCompanion(')
          ..write('id: $id, ')
          ..write('postalOfficeId: $postalOfficeId, ')
          ..write('operation: $operation, ')
          ..write('matchMethod: $matchMethod, ')
          ..write('startValue: $startValue, ')
          ..write('endValue: $endValue')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubscribersTable subscribers = $SubscribersTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $SubscriptionsTable subscriptions = $SubscriptionsTable(this);
  late final $MigrationSnapshotsTable migrationSnapshots =
      $MigrationSnapshotsTable(this);
  late final $PostalOfficesTable postalOffices = $PostalOfficesTable(this);
  late final $PostalOfficeRulesTable postalOfficeRules =
      $PostalOfficeRulesTable(this);
  late final Index idxSubscribersName = Index(
    'idx_subscribers_name',
    'CREATE INDEX idx_subscribers_name ON subscribers (name COLLATE NOCASE)',
  );
  late final Index idxSubscriptionsSubscriber = Index(
    'idx_subscriptions_subscriber',
    'CREATE INDEX idx_subscriptions_subscriber ON subscriptions (subscriber_id)',
  );
  late final Index idxSubscriptionsExpiryDate = Index(
    'idx_subscriptions_expiry_date',
    'CREATE INDEX idx_subscriptions_expiry_date ON subscriptions (expiry_date)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    subscribers,
    auditLogs,
    subscriptions,
    migrationSnapshots,
    postalOffices,
    postalOfficeRules,
    idxSubscribersName,
    idxSubscriptionsSubscriber,
    idxSubscriptionsExpiryDate,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'postal_offices',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('postal_office_rules', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$SubscribersTableCreateCompanionBuilder =
    SubscribersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> postalAddress,
      Value<String?> postalCode,
      Value<bool> isForeign,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> archivedAt,
    });
typedef $$SubscribersTableUpdateCompanionBuilder =
    SubscribersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> postalAddress,
      Value<String?> postalCode,
      Value<bool> isForeign,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> archivedAt,
    });

final class $$SubscribersTableReferences
    extends BaseReferences<_$AppDatabase, $SubscribersTable, Subscriber> {
  $$SubscribersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AuditLogsTable, List<AuditLog>>
  _auditLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.auditLogs,
    aliasName: 'subscribers__id__audit_logs__subscriber_id',
  );

  $$AuditLogsTableProcessedTableManager get auditLogsRefs {
    final manager = $$AuditLogsTableTableManager(
      $_db,
      $_db.auditLogs,
    ).filter((f) => f.subscriberId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_auditLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SubscriptionsTable, List<Subscription>>
  _subscriptionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.subscriptions,
    aliasName: 'subscribers__id__subscriptions__subscriber_id',
  );

  $$SubscriptionsTableProcessedTableManager get subscriptionsRefs {
    final manager = $$SubscriptionsTableTableManager(
      $_db,
      $_db.subscriptions,
    ).filter((f) => f.subscriberId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_subscriptionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubscribersTableFilterComposer
    extends Composer<_$AppDatabase, $SubscribersTable> {
  $$SubscribersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postalAddress => $composableBuilder(
    column: $table.postalAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isForeign => $composableBuilder(
    column: $table.isForeign,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> auditLogsRefs(
    Expression<bool> Function($$AuditLogsTableFilterComposer f) f,
  ) {
    final $$AuditLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditLogs,
      getReferencedColumn: (t) => t.subscriberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditLogsTableFilterComposer(
            $db: $db,
            $table: $db.auditLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> subscriptionsRefs(
    Expression<bool> Function($$SubscriptionsTableFilterComposer f) f,
  ) {
    final $$SubscriptionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.subscriberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableFilterComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubscribersTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscribersTable> {
  $$SubscribersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postalAddress => $composableBuilder(
    column: $table.postalAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isForeign => $composableBuilder(
    column: $table.isForeign,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscribersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscribersTable> {
  $$SubscribersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get postalAddress => $composableBuilder(
    column: $table.postalAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isForeign =>
      $composableBuilder(column: $table.isForeign, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  Expression<T> auditLogsRefs<T extends Object>(
    Expression<T> Function($$AuditLogsTableAnnotationComposer a) f,
  ) {
    final $$AuditLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.auditLogs,
      getReferencedColumn: (t) => t.subscriberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AuditLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.auditLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> subscriptionsRefs<T extends Object>(
    Expression<T> Function($$SubscriptionsTableAnnotationComposer a) f,
  ) {
    final $$SubscriptionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subscriptions,
      getReferencedColumn: (t) => t.subscriberId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscriptionsTableAnnotationComposer(
            $db: $db,
            $table: $db.subscriptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubscribersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscribersTable,
          Subscriber,
          $$SubscribersTableFilterComposer,
          $$SubscribersTableOrderingComposer,
          $$SubscribersTableAnnotationComposer,
          $$SubscribersTableCreateCompanionBuilder,
          $$SubscribersTableUpdateCompanionBuilder,
          (Subscriber, $$SubscribersTableReferences),
          Subscriber,
          PrefetchHooks Function({bool auditLogsRefs, bool subscriptionsRefs})
        > {
  $$SubscribersTableTableManager(_$AppDatabase db, $SubscribersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscribersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscribersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscribersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> postalAddress = const Value.absent(),
                Value<String?> postalCode = const Value.absent(),
                Value<bool> isForeign = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
              }) => SubscribersCompanion(
                id: id,
                name: name,
                email: email,
                phone: phone,
                postalAddress: postalAddress,
                postalCode: postalCode,
                isForeign: isForeign,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> postalAddress = const Value.absent(),
                Value<String?> postalCode = const Value.absent(),
                Value<bool> isForeign = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
              }) => SubscribersCompanion.insert(
                id: id,
                name: name,
                email: email,
                phone: phone,
                postalAddress: postalAddress,
                postalCode: postalCode,
                isForeign: isForeign,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubscribersTable, Subscriber>(table),
                  $$SubscribersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({auditLogsRefs = false, subscriptionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (auditLogsRefs) db.auditLogs,
                    if (subscriptionsRefs) db.subscriptions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (auditLogsRefs)
                        await $_getPrefetchedDataByColumns<
                          Subscriber,
                          $SubscribersTable,
                          AuditLog,
                          $AuditLogsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SubscribersTableReferences
                              ._auditLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubscribersTableReferences(
                                db,
                                table,
                                p0,
                              ).auditLogsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'subscriber_id',
                          typedResults: items,
                        ),
                      if (subscriptionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Subscriber,
                          $SubscribersTable,
                          Subscription,
                          $SubscriptionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SubscribersTableReferences
                              ._subscriptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubscribersTableReferences(
                                db,
                                table,
                                p0,
                              ).subscriptionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'subscriber_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SubscribersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscribersTable,
      Subscriber,
      $$SubscribersTableFilterComposer,
      $$SubscribersTableOrderingComposer,
      $$SubscribersTableAnnotationComposer,
      $$SubscribersTableCreateCompanionBuilder,
      $$SubscribersTableUpdateCompanionBuilder,
      (Subscriber, $$SubscribersTableReferences),
      Subscriber,
      PrefetchHooks Function({bool auditLogsRefs, bool subscriptionsRefs})
    >;
typedef $$AuditLogsTableCreateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<int> id,
      required int subscriberId,
      Value<String?> previousValues,
      required String updatedValues,
      Value<String> modifiedAt,
    });
typedef $$AuditLogsTableUpdateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<int> id,
      Value<int> subscriberId,
      Value<String?> previousValues,
      Value<String> updatedValues,
      Value<String> modifiedAt,
    });

final class $$AuditLogsTableReferences
    extends BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog> {
  $$AuditLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubscribersTable _subscriberIdTable(_$AppDatabase db) =>
      db.subscribers.createAlias('audit_logs__subscriber_id__subscribers__id');

  $$SubscribersTableProcessedTableManager get subscriberId {
    final $_column = $_itemColumn<int>('subscriber_id')!;

    final manager = $$SubscribersTableTableManager(
      $_db,
      $_db.subscribers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subscriberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousValues => $composableBuilder(
    column: $table.previousValues,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedValues => $composableBuilder(
    column: $table.updatedValues,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SubscribersTableFilterComposer get subscriberId {
    final $$SubscribersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriberId,
      referencedTable: $db.subscribers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscribersTableFilterComposer(
            $db: $db,
            $table: $db.subscribers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousValues => $composableBuilder(
    column: $table.previousValues,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedValues => $composableBuilder(
    column: $table.updatedValues,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubscribersTableOrderingComposer get subscriberId {
    final $$SubscribersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriberId,
      referencedTable: $db.subscribers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscribersTableOrderingComposer(
            $db: $db,
            $table: $db.subscribers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get previousValues => $composableBuilder(
    column: $table.previousValues,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedValues => $composableBuilder(
    column: $table.updatedValues,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => column,
  );

  $$SubscribersTableAnnotationComposer get subscriberId {
    final $$SubscribersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriberId,
      referencedTable: $db.subscribers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscribersTableAnnotationComposer(
            $db: $db,
            $table: $db.subscribers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, $$AuditLogsTableReferences),
          AuditLog,
          PrefetchHooks Function({bool subscriberId})
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> subscriberId = const Value.absent(),
                Value<String?> previousValues = const Value.absent(),
                Value<String> updatedValues = const Value.absent(),
                Value<String> modifiedAt = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                subscriberId: subscriberId,
                previousValues: previousValues,
                updatedValues: updatedValues,
                modifiedAt: modifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int subscriberId,
                Value<String?> previousValues = const Value.absent(),
                required String updatedValues,
                Value<String> modifiedAt = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                subscriberId: subscriberId,
                previousValues: previousValues,
                updatedValues: updatedValues,
                modifiedAt: modifiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AuditLogsTable, AuditLog>(table),
                  $$AuditLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({subscriberId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (subscriberId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.subscriberId,
                                referencedTable: $$AuditLogsTableReferences
                                    ._subscriberIdTable(db),
                                referencedColumn: $$AuditLogsTableReferences
                                    ._subscriberIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, $$AuditLogsTableReferences),
      AuditLog,
      PrefetchHooks Function({bool subscriberId})
    >;
typedef $$SubscriptionsTableCreateCompanionBuilder =
    SubscriptionsCompanion Function({
      Value<int> id,
      required int subscriberId,
      required String edition,
      required String planType,
      required int durationYears,
      required String startDate,
      required String expiryDate,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> archivedAt,
    });
typedef $$SubscriptionsTableUpdateCompanionBuilder =
    SubscriptionsCompanion Function({
      Value<int> id,
      Value<int> subscriberId,
      Value<String> edition,
      Value<String> planType,
      Value<int> durationYears,
      Value<String> startDate,
      Value<String> expiryDate,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> archivedAt,
    });

final class $$SubscriptionsTableReferences
    extends BaseReferences<_$AppDatabase, $SubscriptionsTable, Subscription> {
  $$SubscriptionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SubscribersTable _subscriberIdTable(_$AppDatabase db) => db
      .subscribers
      .createAlias('subscriptions__subscriber_id__subscribers__id');

  $$SubscribersTableProcessedTableManager get subscriberId {
    final $_column = $_itemColumn<int>('subscriber_id')!;

    final manager = $$SubscribersTableTableManager(
      $_db,
      $_db.subscribers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subscriberIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SubscriptionsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get edition => $composableBuilder(
    column: $table.edition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get planType => $composableBuilder(
    column: $table.planType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationYears => $composableBuilder(
    column: $table.durationYears,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SubscribersTableFilterComposer get subscriberId {
    final $$SubscribersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriberId,
      referencedTable: $db.subscribers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscribersTableFilterComposer(
            $db: $db,
            $table: $db.subscribers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubscriptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get edition => $composableBuilder(
    column: $table.edition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planType => $composableBuilder(
    column: $table.planType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationYears => $composableBuilder(
    column: $table.durationYears,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubscribersTableOrderingComposer get subscriberId {
    final $$SubscribersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriberId,
      referencedTable: $db.subscribers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscribersTableOrderingComposer(
            $db: $db,
            $table: $db.subscribers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubscriptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionsTable> {
  $$SubscriptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get edition =>
      $composableBuilder(column: $table.edition, builder: (column) => column);

  GeneratedColumn<String> get planType =>
      $composableBuilder(column: $table.planType, builder: (column) => column);

  GeneratedColumn<int> get durationYears => $composableBuilder(
    column: $table.durationYears,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get expiryDate => $composableBuilder(
    column: $table.expiryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  $$SubscribersTableAnnotationComposer get subscriberId {
    final $$SubscribersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subscriberId,
      referencedTable: $db.subscribers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubscribersTableAnnotationComposer(
            $db: $db,
            $table: $db.subscribers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubscriptionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionsTable,
          Subscription,
          $$SubscriptionsTableFilterComposer,
          $$SubscriptionsTableOrderingComposer,
          $$SubscriptionsTableAnnotationComposer,
          $$SubscriptionsTableCreateCompanionBuilder,
          $$SubscriptionsTableUpdateCompanionBuilder,
          (Subscription, $$SubscriptionsTableReferences),
          Subscription,
          PrefetchHooks Function({bool subscriberId})
        > {
  $$SubscriptionsTableTableManager(_$AppDatabase db, $SubscriptionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubscriptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> subscriberId = const Value.absent(),
                Value<String> edition = const Value.absent(),
                Value<String> planType = const Value.absent(),
                Value<int> durationYears = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String> expiryDate = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
              }) => SubscriptionsCompanion(
                id: id,
                subscriberId: subscriberId,
                edition: edition,
                planType: planType,
                durationYears: durationYears,
                startDate: startDate,
                expiryDate: expiryDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int subscriberId,
                required String edition,
                required String planType,
                required int durationYears,
                required String startDate,
                required String expiryDate,
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
              }) => SubscriptionsCompanion.insert(
                id: id,
                subscriberId: subscriberId,
                edition: edition,
                planType: planType,
                durationYears: durationYears,
                startDate: startDate,
                expiryDate: expiryDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubscriptionsTable, Subscription>(table),
                  $$SubscriptionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({subscriberId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (subscriberId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.subscriberId,
                                referencedTable: $$SubscriptionsTableReferences
                                    ._subscriberIdTable(db),
                                referencedColumn: $$SubscriptionsTableReferences
                                    ._subscriberIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SubscriptionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubscriptionsTable,
      Subscription,
      $$SubscriptionsTableFilterComposer,
      $$SubscriptionsTableOrderingComposer,
      $$SubscriptionsTableAnnotationComposer,
      $$SubscriptionsTableCreateCompanionBuilder,
      $$SubscriptionsTableUpdateCompanionBuilder,
      (Subscription, $$SubscriptionsTableReferences),
      Subscription,
      PrefetchHooks Function({bool subscriberId})
    >;
typedef $$MigrationSnapshotsTableCreateCompanionBuilder =
    MigrationSnapshotsCompanion Function({
      required String sourceTable,
      required int rowId,
      required int sourceVersion,
      required String valuesJson,
      Value<int> rowid,
    });
typedef $$MigrationSnapshotsTableUpdateCompanionBuilder =
    MigrationSnapshotsCompanion Function({
      Value<String> sourceTable,
      Value<int> rowId,
      Value<int> sourceVersion,
      Value<String> valuesJson,
      Value<int> rowid,
    });

class $$MigrationSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $MigrationSnapshotsTable> {
  $$MigrationSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceTable => $composableBuilder(
    column: $table.sourceTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valuesJson => $composableBuilder(
    column: $table.valuesJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MigrationSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $MigrationSnapshotsTable> {
  $$MigrationSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceTable => $composableBuilder(
    column: $table.sourceTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valuesJson => $composableBuilder(
    column: $table.valuesJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MigrationSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MigrationSnapshotsTable> {
  $$MigrationSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceTable => $composableBuilder(
    column: $table.sourceTable,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<int> get sourceVersion => $composableBuilder(
    column: $table.sourceVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get valuesJson => $composableBuilder(
    column: $table.valuesJson,
    builder: (column) => column,
  );
}

class $$MigrationSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MigrationSnapshotsTable,
          MigrationSnapshot,
          $$MigrationSnapshotsTableFilterComposer,
          $$MigrationSnapshotsTableOrderingComposer,
          $$MigrationSnapshotsTableAnnotationComposer,
          $$MigrationSnapshotsTableCreateCompanionBuilder,
          $$MigrationSnapshotsTableUpdateCompanionBuilder,
          (
            MigrationSnapshot,
            BaseReferences<
              _$AppDatabase,
              $MigrationSnapshotsTable,
              MigrationSnapshot
            >,
          ),
          MigrationSnapshot,
          PrefetchHooks Function()
        > {
  $$MigrationSnapshotsTableTableManager(
    _$AppDatabase db,
    $MigrationSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MigrationSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MigrationSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MigrationSnapshotsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sourceTable = const Value.absent(),
                Value<int> rowId = const Value.absent(),
                Value<int> sourceVersion = const Value.absent(),
                Value<String> valuesJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MigrationSnapshotsCompanion(
                sourceTable: sourceTable,
                rowId: rowId,
                sourceVersion: sourceVersion,
                valuesJson: valuesJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceTable,
                required int rowId,
                required int sourceVersion,
                required String valuesJson,
                Value<int> rowid = const Value.absent(),
              }) => MigrationSnapshotsCompanion.insert(
                sourceTable: sourceTable,
                rowId: rowId,
                sourceVersion: sourceVersion,
                valuesJson: valuesJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MigrationSnapshotsTable, MigrationSnapshot>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $MigrationSnapshotsTable,
                    MigrationSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MigrationSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MigrationSnapshotsTable,
      MigrationSnapshot,
      $$MigrationSnapshotsTableFilterComposer,
      $$MigrationSnapshotsTableOrderingComposer,
      $$MigrationSnapshotsTableAnnotationComposer,
      $$MigrationSnapshotsTableCreateCompanionBuilder,
      $$MigrationSnapshotsTableUpdateCompanionBuilder,
      (
        MigrationSnapshot,
        BaseReferences<
          _$AppDatabase,
          $MigrationSnapshotsTable,
          MigrationSnapshot
        >,
      ),
      MigrationSnapshot,
      PrefetchHooks Function()
    >;
typedef $$PostalOfficesTableCreateCompanionBuilder =
    PostalOfficesCompanion Function({
      Value<int> id,
      required String name,
      Value<bool> isActive,
      Value<String> createdAt,
      Value<String> updatedAt,
    });
typedef $$PostalOfficesTableUpdateCompanionBuilder =
    PostalOfficesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<bool> isActive,
      Value<String> createdAt,
      Value<String> updatedAt,
    });

final class $$PostalOfficesTableReferences
    extends BaseReferences<_$AppDatabase, $PostalOfficesTable, PostalOffice> {
  $$PostalOfficesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PostalOfficeRulesTable, List<PostalOfficeRule>>
  _postalOfficeRulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.postalOfficeRules,
        aliasName: 'postal_offices__id__postal_office_rules__postal_office_id',
      );

  $$PostalOfficeRulesTableProcessedTableManager get postalOfficeRulesRefs {
    final manager = $$PostalOfficeRulesTableTableManager(
      $_db,
      $_db.postalOfficeRules,
    ).filter((f) => f.postalOfficeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _postalOfficeRulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PostalOfficesTableFilterComposer
    extends Composer<_$AppDatabase, $PostalOfficesTable> {
  $$PostalOfficesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> postalOfficeRulesRefs(
    Expression<bool> Function($$PostalOfficeRulesTableFilterComposer f) f,
  ) {
    final $$PostalOfficeRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.postalOfficeRules,
      getReferencedColumn: (t) => t.postalOfficeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostalOfficeRulesTableFilterComposer(
            $db: $db,
            $table: $db.postalOfficeRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PostalOfficesTableOrderingComposer
    extends Composer<_$AppDatabase, $PostalOfficesTable> {
  $$PostalOfficesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PostalOfficesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostalOfficesTable> {
  $$PostalOfficesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> postalOfficeRulesRefs<T extends Object>(
    Expression<T> Function($$PostalOfficeRulesTableAnnotationComposer a) f,
  ) {
    final $$PostalOfficeRulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.postalOfficeRules,
          getReferencedColumn: (t) => t.postalOfficeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PostalOfficeRulesTableAnnotationComposer(
                $db: $db,
                $table: $db.postalOfficeRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PostalOfficesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PostalOfficesTable,
          PostalOffice,
          $$PostalOfficesTableFilterComposer,
          $$PostalOfficesTableOrderingComposer,
          $$PostalOfficesTableAnnotationComposer,
          $$PostalOfficesTableCreateCompanionBuilder,
          $$PostalOfficesTableUpdateCompanionBuilder,
          (PostalOffice, $$PostalOfficesTableReferences),
          PostalOffice,
          PrefetchHooks Function({bool postalOfficeRulesRefs})
        > {
  $$PostalOfficesTableTableManager(_$AppDatabase db, $PostalOfficesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostalOfficesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostalOfficesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostalOfficesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => PostalOfficesCompanion(
                id: id,
                name: name,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<bool> isActive = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
              }) => PostalOfficesCompanion.insert(
                id: id,
                name: name,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PostalOfficesTable, PostalOffice>(table),
                  $$PostalOfficesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({postalOfficeRulesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (postalOfficeRulesRefs) db.postalOfficeRules,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (postalOfficeRulesRefs)
                    await $_getPrefetchedDataByColumns<
                      PostalOffice,
                      $PostalOfficesTable,
                      PostalOfficeRule,
                      $PostalOfficeRulesTable
                    >(
                      currentTable: table,
                      referencedTable: $$PostalOfficesTableReferences
                          ._postalOfficeRulesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PostalOfficesTableReferences(
                            db,
                            table,
                            p0,
                          ).postalOfficeRulesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'postal_office_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PostalOfficesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PostalOfficesTable,
      PostalOffice,
      $$PostalOfficesTableFilterComposer,
      $$PostalOfficesTableOrderingComposer,
      $$PostalOfficesTableAnnotationComposer,
      $$PostalOfficesTableCreateCompanionBuilder,
      $$PostalOfficesTableUpdateCompanionBuilder,
      (PostalOffice, $$PostalOfficesTableReferences),
      PostalOffice,
      PrefetchHooks Function({bool postalOfficeRulesRefs})
    >;
typedef $$PostalOfficeRulesTableCreateCompanionBuilder =
    PostalOfficeRulesCompanion Function({
      Value<int> id,
      required int postalOfficeId,
      required String operation,
      required String matchMethod,
      required String startValue,
      Value<String?> endValue,
    });
typedef $$PostalOfficeRulesTableUpdateCompanionBuilder =
    PostalOfficeRulesCompanion Function({
      Value<int> id,
      Value<int> postalOfficeId,
      Value<String> operation,
      Value<String> matchMethod,
      Value<String> startValue,
      Value<String?> endValue,
    });

final class $$PostalOfficeRulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PostalOfficeRulesTable,
          PostalOfficeRule
        > {
  $$PostalOfficeRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PostalOfficesTable _postalOfficeIdTable(_$AppDatabase db) => db
      .postalOffices
      .createAlias('postal_office_rules__postal_office_id__postal_offices__id');

  $$PostalOfficesTableProcessedTableManager get postalOfficeId {
    final $_column = $_itemColumn<int>('postal_office_id')!;

    final manager = $$PostalOfficesTableTableManager(
      $_db,
      $_db.postalOffices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_postalOfficeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PostalOfficeRulesTableFilterComposer
    extends Composer<_$AppDatabase, $PostalOfficeRulesTable> {
  $$PostalOfficeRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchMethod => $composableBuilder(
    column: $table.matchMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startValue => $composableBuilder(
    column: $table.startValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endValue => $composableBuilder(
    column: $table.endValue,
    builder: (column) => ColumnFilters(column),
  );

  $$PostalOfficesTableFilterComposer get postalOfficeId {
    final $$PostalOfficesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postalOfficeId,
      referencedTable: $db.postalOffices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostalOfficesTableFilterComposer(
            $db: $db,
            $table: $db.postalOffices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostalOfficeRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $PostalOfficeRulesTable> {
  $$PostalOfficeRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchMethod => $composableBuilder(
    column: $table.matchMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startValue => $composableBuilder(
    column: $table.startValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endValue => $composableBuilder(
    column: $table.endValue,
    builder: (column) => ColumnOrderings(column),
  );

  $$PostalOfficesTableOrderingComposer get postalOfficeId {
    final $$PostalOfficesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postalOfficeId,
      referencedTable: $db.postalOffices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostalOfficesTableOrderingComposer(
            $db: $db,
            $table: $db.postalOffices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostalOfficeRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PostalOfficeRulesTable> {
  $$PostalOfficeRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get matchMethod => $composableBuilder(
    column: $table.matchMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startValue => $composableBuilder(
    column: $table.startValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endValue =>
      $composableBuilder(column: $table.endValue, builder: (column) => column);

  $$PostalOfficesTableAnnotationComposer get postalOfficeId {
    final $$PostalOfficesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.postalOfficeId,
      referencedTable: $db.postalOffices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PostalOfficesTableAnnotationComposer(
            $db: $db,
            $table: $db.postalOffices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PostalOfficeRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PostalOfficeRulesTable,
          PostalOfficeRule,
          $$PostalOfficeRulesTableFilterComposer,
          $$PostalOfficeRulesTableOrderingComposer,
          $$PostalOfficeRulesTableAnnotationComposer,
          $$PostalOfficeRulesTableCreateCompanionBuilder,
          $$PostalOfficeRulesTableUpdateCompanionBuilder,
          (PostalOfficeRule, $$PostalOfficeRulesTableReferences),
          PostalOfficeRule,
          PrefetchHooks Function({bool postalOfficeId})
        > {
  $$PostalOfficeRulesTableTableManager(
    _$AppDatabase db,
    $PostalOfficeRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PostalOfficeRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PostalOfficeRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PostalOfficeRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> postalOfficeId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> matchMethod = const Value.absent(),
                Value<String> startValue = const Value.absent(),
                Value<String?> endValue = const Value.absent(),
              }) => PostalOfficeRulesCompanion(
                id: id,
                postalOfficeId: postalOfficeId,
                operation: operation,
                matchMethod: matchMethod,
                startValue: startValue,
                endValue: endValue,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int postalOfficeId,
                required String operation,
                required String matchMethod,
                required String startValue,
                Value<String?> endValue = const Value.absent(),
              }) => PostalOfficeRulesCompanion.insert(
                id: id,
                postalOfficeId: postalOfficeId,
                operation: operation,
                matchMethod: matchMethod,
                startValue: startValue,
                endValue: endValue,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PostalOfficeRulesTable, PostalOfficeRule>(table),
                  $$PostalOfficeRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({postalOfficeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (postalOfficeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.postalOfficeId,
                                referencedTable:
                                    $$PostalOfficeRulesTableReferences
                                        ._postalOfficeIdTable(db),
                                referencedColumn:
                                    $$PostalOfficeRulesTableReferences
                                        ._postalOfficeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PostalOfficeRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PostalOfficeRulesTable,
      PostalOfficeRule,
      $$PostalOfficeRulesTableFilterComposer,
      $$PostalOfficeRulesTableOrderingComposer,
      $$PostalOfficeRulesTableAnnotationComposer,
      $$PostalOfficeRulesTableCreateCompanionBuilder,
      $$PostalOfficeRulesTableUpdateCompanionBuilder,
      (PostalOfficeRule, $$PostalOfficeRulesTableReferences),
      PostalOfficeRule,
      PrefetchHooks Function({bool postalOfficeId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubscribersTableTableManager get subscribers =>
      $$SubscribersTableTableManager(_db, _db.subscribers);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$SubscriptionsTableTableManager get subscriptions =>
      $$SubscriptionsTableTableManager(_db, _db.subscriptions);
  $$MigrationSnapshotsTableTableManager get migrationSnapshots =>
      $$MigrationSnapshotsTableTableManager(_db, _db.migrationSnapshots);
  $$PostalOfficesTableTableManager get postalOffices =>
      $$PostalOfficesTableTableManager(_db, _db.postalOffices);
  $$PostalOfficeRulesTableTableManager get postalOfficeRules =>
      $$PostalOfficeRulesTableTableManager(_db, _db.postalOfficeRules);
}
