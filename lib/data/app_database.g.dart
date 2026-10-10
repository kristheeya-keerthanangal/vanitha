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
  static const VerificationMeta _subscriberTypeMeta = const VerificationMeta(
    'subscriberType',
  );
  @override
  late final GeneratedColumn<String> subscriberType = GeneratedColumn<String>(
    'subscriber_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (subscriber_type IN (\'individual\', \'organization\'))',
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
  static const VerificationMeta _contactPersonNameMeta = const VerificationMeta(
    'contactPersonName',
  );
  @override
  late final GeneratedColumn<String> contactPersonName =
      GeneratedColumn<String>(
        'contact_person_name',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
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
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
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
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    subscriberType,
    name,
    contactPersonName,
    email,
    phone,
    postalAddress,
    city,
    state,
    postalCode,
    country,
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
    if (data.containsKey('subscriber_type')) {
      context.handle(
        _subscriberTypeMeta,
        subscriberType.isAcceptableOrUnknown(
          data['subscriber_type']!,
          _subscriberTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subscriberTypeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact_person_name')) {
      context.handle(
        _contactPersonNameMeta,
        contactPersonName.isAcceptableOrUnknown(
          data['contact_person_name']!,
          _contactPersonNameMeta,
        ),
      );
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
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('postal_code')) {
      context.handle(
        _postalCodeMeta,
        postalCode.isAcceptableOrUnknown(data['postal_code']!, _postalCodeMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
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
      subscriberType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subscriber_type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contactPersonName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_person_name'],
      ),
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
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      ),
      postalCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postal_code'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
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
  final String subscriberType;
  final String name;
  final String? contactPersonName;
  final String? email;
  final String? phone;
  final String? postalAddress;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String createdAt;
  final String updatedAt;
  final String? archivedAt;
  const Subscriber({
    required this.id,
    required this.subscriberType,
    required this.name,
    this.contactPersonName,
    this.email,
    this.phone,
    this.postalAddress,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subscriber_type'] = Variable<String>(subscriberType);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contactPersonName != null) {
      map['contact_person_name'] = Variable<String>(contactPersonName);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || postalAddress != null) {
      map['postal_address'] = Variable<String>(postalAddress);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || state != null) {
      map['state'] = Variable<String>(state);
    }
    if (!nullToAbsent || postalCode != null) {
      map['postal_code'] = Variable<String>(postalCode);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
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
      subscriberType: Value(subscriberType),
      name: Value(name),
      contactPersonName: contactPersonName == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPersonName),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      postalAddress: postalAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(postalAddress),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      state: state == null && nullToAbsent
          ? const Value.absent()
          : Value(state),
      postalCode: postalCode == null && nullToAbsent
          ? const Value.absent()
          : Value(postalCode),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
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
      subscriberType: serializer.fromJson<String>(json['subscriberType']),
      name: serializer.fromJson<String>(json['name']),
      contactPersonName: serializer.fromJson<String?>(
        json['contactPersonName'],
      ),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      postalAddress: serializer.fromJson<String?>(json['postalAddress']),
      city: serializer.fromJson<String?>(json['city']),
      state: serializer.fromJson<String?>(json['state']),
      postalCode: serializer.fromJson<String?>(json['postalCode']),
      country: serializer.fromJson<String?>(json['country']),
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
      'subscriberType': serializer.toJson<String>(subscriberType),
      'name': serializer.toJson<String>(name),
      'contactPersonName': serializer.toJson<String?>(contactPersonName),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'postalAddress': serializer.toJson<String?>(postalAddress),
      'city': serializer.toJson<String?>(city),
      'state': serializer.toJson<String?>(state),
      'postalCode': serializer.toJson<String?>(postalCode),
      'country': serializer.toJson<String?>(country),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'archivedAt': serializer.toJson<String?>(archivedAt),
    };
  }

  Subscriber copyWith({
    int? id,
    String? subscriberType,
    String? name,
    Value<String?> contactPersonName = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> postalAddress = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<String?> state = const Value.absent(),
    Value<String?> postalCode = const Value.absent(),
    Value<String?> country = const Value.absent(),
    String? createdAt,
    String? updatedAt,
    Value<String?> archivedAt = const Value.absent(),
  }) => Subscriber(
    id: id ?? this.id,
    subscriberType: subscriberType ?? this.subscriberType,
    name: name ?? this.name,
    contactPersonName: contactPersonName.present
        ? contactPersonName.value
        : this.contactPersonName,
    email: email.present ? email.value : this.email,
    phone: phone.present ? phone.value : this.phone,
    postalAddress: postalAddress.present
        ? postalAddress.value
        : this.postalAddress,
    city: city.present ? city.value : this.city,
    state: state.present ? state.value : this.state,
    postalCode: postalCode.present ? postalCode.value : this.postalCode,
    country: country.present ? country.value : this.country,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  Subscriber copyWithCompanion(SubscribersCompanion data) {
    return Subscriber(
      id: data.id.present ? data.id.value : this.id,
      subscriberType: data.subscriberType.present
          ? data.subscriberType.value
          : this.subscriberType,
      name: data.name.present ? data.name.value : this.name,
      contactPersonName: data.contactPersonName.present
          ? data.contactPersonName.value
          : this.contactPersonName,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      postalAddress: data.postalAddress.present
          ? data.postalAddress.value
          : this.postalAddress,
      city: data.city.present ? data.city.value : this.city,
      state: data.state.present ? data.state.value : this.state,
      postalCode: data.postalCode.present
          ? data.postalCode.value
          : this.postalCode,
      country: data.country.present ? data.country.value : this.country,
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
          ..write('subscriberType: $subscriberType, ')
          ..write('name: $name, ')
          ..write('contactPersonName: $contactPersonName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('postalAddress: $postalAddress, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('postalCode: $postalCode, ')
          ..write('country: $country, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subscriberType,
    name,
    contactPersonName,
    email,
    phone,
    postalAddress,
    city,
    state,
    postalCode,
    country,
    createdAt,
    updatedAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subscriber &&
          other.id == this.id &&
          other.subscriberType == this.subscriberType &&
          other.name == this.name &&
          other.contactPersonName == this.contactPersonName &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.postalAddress == this.postalAddress &&
          other.city == this.city &&
          other.state == this.state &&
          other.postalCode == this.postalCode &&
          other.country == this.country &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.archivedAt == this.archivedAt);
}

class SubscribersCompanion extends UpdateCompanion<Subscriber> {
  final Value<int> id;
  final Value<String> subscriberType;
  final Value<String> name;
  final Value<String?> contactPersonName;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<String?> postalAddress;
  final Value<String?> city;
  final Value<String?> state;
  final Value<String?> postalCode;
  final Value<String?> country;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> archivedAt;
  const SubscribersCompanion({
    this.id = const Value.absent(),
    this.subscriberType = const Value.absent(),
    this.name = const Value.absent(),
    this.contactPersonName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.postalAddress = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.country = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  });
  SubscribersCompanion.insert({
    this.id = const Value.absent(),
    required String subscriberType,
    required String name,
    this.contactPersonName = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.postalAddress = const Value.absent(),
    this.city = const Value.absent(),
    this.state = const Value.absent(),
    this.postalCode = const Value.absent(),
    this.country = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  }) : subscriberType = Value(subscriberType),
       name = Value(name);
  static Insertable<Subscriber> custom({
    Expression<int>? id,
    Expression<String>? subscriberType,
    Expression<String>? name,
    Expression<String>? contactPersonName,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<String>? postalAddress,
    Expression<String>? city,
    Expression<String>? state,
    Expression<String>? postalCode,
    Expression<String>? country,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? archivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subscriberType != null) 'subscriber_type': subscriberType,
      if (name != null) 'name': name,
      if (contactPersonName != null) 'contact_person_name': contactPersonName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (postalAddress != null) 'postal_address': postalAddress,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (postalCode != null) 'postal_code': postalCode,
      if (country != null) 'country': country,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
    });
  }

  SubscribersCompanion copyWith({
    Value<int>? id,
    Value<String>? subscriberType,
    Value<String>? name,
    Value<String?>? contactPersonName,
    Value<String?>? email,
    Value<String?>? phone,
    Value<String?>? postalAddress,
    Value<String?>? city,
    Value<String?>? state,
    Value<String?>? postalCode,
    Value<String?>? country,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String?>? archivedAt,
  }) {
    return SubscribersCompanion(
      id: id ?? this.id,
      subscriberType: subscriberType ?? this.subscriberType,
      name: name ?? this.name,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      postalAddress: postalAddress ?? this.postalAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
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
    if (subscriberType.present) {
      map['subscriber_type'] = Variable<String>(subscriberType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contactPersonName.present) {
      map['contact_person_name'] = Variable<String>(contactPersonName.value);
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
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (postalCode.present) {
      map['postal_code'] = Variable<String>(postalCode.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
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
          ..write('subscriberType: $subscriberType, ')
          ..write('name: $name, ')
          ..write('contactPersonName: $contactPersonName, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('postalAddress: $postalAddress, ')
          ..write('city: $city, ')
          ..write('state: $state, ')
          ..write('postalCode: $postalCode, ')
          ..write('country: $country, ')
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubscribersTable subscribers = $SubscribersTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final Index idxSubscribersName = Index(
    'idx_subscribers_name',
    'CREATE INDEX idx_subscribers_name ON subscribers (name COLLATE NOCASE)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    subscribers,
    auditLogs,
    idxSubscribersName,
  ];
}

typedef $$SubscribersTableCreateCompanionBuilder =
    SubscribersCompanion Function({
      Value<int> id,
      required String subscriberType,
      required String name,
      Value<String?> contactPersonName,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> postalAddress,
      Value<String?> city,
      Value<String?> state,
      Value<String?> postalCode,
      Value<String?> country,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String?> archivedAt,
    });
typedef $$SubscribersTableUpdateCompanionBuilder =
    SubscribersCompanion Function({
      Value<int> id,
      Value<String> subscriberType,
      Value<String> name,
      Value<String?> contactPersonName,
      Value<String?> email,
      Value<String?> phone,
      Value<String?> postalAddress,
      Value<String?> city,
      Value<String?> state,
      Value<String?> postalCode,
      Value<String?> country,
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

  ColumnFilters<String> get subscriberType => $composableBuilder(
    column: $table.subscriberType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPersonName => $composableBuilder(
    column: $table.contactPersonName,
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

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
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

  ColumnOrderings<String> get subscriberType => $composableBuilder(
    column: $table.subscriberType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPersonName => $composableBuilder(
    column: $table.contactPersonName,
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

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
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

  GeneratedColumn<String> get subscriberType => $composableBuilder(
    column: $table.subscriberType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contactPersonName => $composableBuilder(
    column: $table.contactPersonName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get postalAddress => $composableBuilder(
    column: $table.postalAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<String> get postalCode => $composableBuilder(
    column: $table.postalCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

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
          PrefetchHooks Function({bool auditLogsRefs})
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
                Value<String> subscriberType = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contactPersonName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> postalAddress = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> postalCode = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
              }) => SubscribersCompanion(
                id: id,
                subscriberType: subscriberType,
                name: name,
                contactPersonName: contactPersonName,
                email: email,
                phone: phone,
                postalAddress: postalAddress,
                city: city,
                state: state,
                postalCode: postalCode,
                country: country,
                createdAt: createdAt,
                updatedAt: updatedAt,
                archivedAt: archivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String subscriberType,
                required String name,
                Value<String?> contactPersonName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> postalAddress = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<String?> state = const Value.absent(),
                Value<String?> postalCode = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> archivedAt = const Value.absent(),
              }) => SubscribersCompanion.insert(
                id: id,
                subscriberType: subscriberType,
                name: name,
                contactPersonName: contactPersonName,
                email: email,
                phone: phone,
                postalAddress: postalAddress,
                city: city,
                state: state,
                postalCode: postalCode,
                country: country,
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
          prefetchHooksCallback: ({auditLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (auditLogsRefs) db.auditLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (auditLogsRefs)
                    await $_getPrefetchedData<
                      Subscriber,
                      $SubscribersTable,
                      AuditLog
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
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.subscriberId == item.id,
                          ),
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
      PrefetchHooks Function({bool auditLogsRefs})
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubscribersTableTableManager get subscribers =>
      $$SubscribersTableTableManager(_db, _db.subscribers);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
}
