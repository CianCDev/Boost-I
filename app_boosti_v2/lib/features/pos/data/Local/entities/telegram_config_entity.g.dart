// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telegram_config_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTelegramConfigEntityCollection on Isar {
  IsarCollection<TelegramConfigEntity> get telegramConfigEntitys =>
      this.collection();
}

const TelegramConfigEntitySchema = CollectionSchema(
  name: r'TelegramConfigEntity',
  id: 868642393692605687,
  properties: {
    r'botToken': PropertySchema(
      id: 0,
      name: r'botToken',
      type: IsarType.string,
    ),
    r'chatId': PropertySchema(
      id: 1,
      name: r'chatId',
      type: IsarType.string,
    ),
    r'comandosPermitidos': PropertySchema(
      id: 2,
      name: r'comandosPermitidos',
      type: IsarType.stringList,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'enabled': PropertySchema(
      id: 4,
      name: r'enabled',
      type: IsarType.bool,
    ),
    r'fechaSincronizacion': PropertySchema(
      id: 5,
      name: r'fechaSincronizacion',
      type: IsarType.dateTime,
    ),
    r'nombreChat': PropertySchema(
      id: 6,
      name: r'nombreChat',
      type: IsarType.string,
    ),
    r'notificarPedidos': PropertySchema(
      id: 7,
      name: r'notificarPedidos',
      type: IsarType.bool,
    ),
    r'notificarStockBajo': PropertySchema(
      id: 8,
      name: r'notificarStockBajo',
      type: IsarType.bool,
    ),
    r'notificarVentas': PropertySchema(
      id: 9,
      name: r'notificarVentas',
      type: IsarType.bool,
    ),
    r'sincronizado': PropertySchema(
      id: 10,
      name: r'sincronizado',
      type: IsarType.bool,
    ),
    r'supabaseId': PropertySchema(
      id: 11,
      name: r'supabaseId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'usuarioId': PropertySchema(
      id: 13,
      name: r'usuarioId',
      type: IsarType.long,
    )
  },
  estimateSize: _telegramConfigEntityEstimateSize,
  serialize: _telegramConfigEntitySerialize,
  deserialize: _telegramConfigEntityDeserialize,
  deserializeProp: _telegramConfigEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _telegramConfigEntityGetId,
  getLinks: _telegramConfigEntityGetLinks,
  attach: _telegramConfigEntityAttach,
  version: '3.1.0+1',
);

int _telegramConfigEntityEstimateSize(
  TelegramConfigEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.botToken.length * 3;
  bytesCount += 3 + object.chatId.length * 3;
  bytesCount += 3 + object.comandosPermitidos.length * 3;
  {
    for (var i = 0; i < object.comandosPermitidos.length; i++) {
      final value = object.comandosPermitidos[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.nombreChat;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.supabaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _telegramConfigEntitySerialize(
  TelegramConfigEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.botToken);
  writer.writeString(offsets[1], object.chatId);
  writer.writeStringList(offsets[2], object.comandosPermitidos);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeBool(offsets[4], object.enabled);
  writer.writeDateTime(offsets[5], object.fechaSincronizacion);
  writer.writeString(offsets[6], object.nombreChat);
  writer.writeBool(offsets[7], object.notificarPedidos);
  writer.writeBool(offsets[8], object.notificarStockBajo);
  writer.writeBool(offsets[9], object.notificarVentas);
  writer.writeBool(offsets[10], object.sincronizado);
  writer.writeString(offsets[11], object.supabaseId);
  writer.writeDateTime(offsets[12], object.updatedAt);
  writer.writeLong(offsets[13], object.usuarioId);
}

TelegramConfigEntity _telegramConfigEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = TelegramConfigEntity();
  object.botToken = reader.readString(offsets[0]);
  object.chatId = reader.readString(offsets[1]);
  object.comandosPermitidos = reader.readStringList(offsets[2]) ?? [];
  object.createdAt = reader.readDateTimeOrNull(offsets[3]);
  object.enabled = reader.readBool(offsets[4]);
  object.fechaSincronizacion = reader.readDateTimeOrNull(offsets[5]);
  object.id = id;
  object.nombreChat = reader.readStringOrNull(offsets[6]);
  object.notificarPedidos = reader.readBool(offsets[7]);
  object.notificarStockBajo = reader.readBool(offsets[8]);
  object.notificarVentas = reader.readBool(offsets[9]);
  object.sincronizado = reader.readBool(offsets[10]);
  object.supabaseId = reader.readStringOrNull(offsets[11]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[12]);
  object.usuarioId = reader.readLongOrNull(offsets[13]);
  return object;
}

P _telegramConfigEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readStringList(offset) ?? []) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _telegramConfigEntityGetId(TelegramConfigEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _telegramConfigEntityGetLinks(
    TelegramConfigEntity object) {
  return [];
}

void _telegramConfigEntityAttach(
    IsarCollection<dynamic> col, Id id, TelegramConfigEntity object) {
  object.id = id;
}

extension TelegramConfigEntityQueryWhereSort
    on QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QWhere> {
  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TelegramConfigEntityQueryWhere
    on QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QWhereClause> {
  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TelegramConfigEntityQueryFilter on QueryBuilder<TelegramConfigEntity,
    TelegramConfigEntity, QFilterCondition> {
  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> botTokenEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'botToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> botTokenGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'botToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> botTokenLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'botToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> botTokenBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'botToken',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> botTokenStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'botToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> botTokenEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'botToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
          QAfterFilterCondition>
      botTokenContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'botToken',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
          QAfterFilterCondition>
      botTokenMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'botToken',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> botTokenIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'botToken',
        value: '',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> botTokenIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'botToken',
        value: '',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> chatIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chatId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> chatIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chatId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> chatIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chatId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> chatIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chatId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> chatIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chatId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> chatIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chatId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
          QAfterFilterCondition>
      chatIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chatId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
          QAfterFilterCondition>
      chatIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chatId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> chatIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chatId',
        value: '',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> chatIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chatId',
        value: '',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'comandosPermitidos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'comandosPermitidos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'comandosPermitidos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'comandosPermitidos',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'comandosPermitidos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'comandosPermitidos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
          QAfterFilterCondition>
      comandosPermitidosElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'comandosPermitidos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
          QAfterFilterCondition>
      comandosPermitidosElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'comandosPermitidos',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'comandosPermitidos',
        value: '',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'comandosPermitidos',
        value: '',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'comandosPermitidos',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'comandosPermitidos',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'comandosPermitidos',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'comandosPermitidos',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'comandosPermitidos',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> comandosPermitidosLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'comandosPermitidos',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> enabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'enabled',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> fechaSincronizacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> fechaSincronizacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> fechaSincronizacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> fechaSincronizacionGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> fechaSincronizacionLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> fechaSincronizacionBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaSincronizacion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> nombreChatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nombreChat',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> nombreChatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nombreChat',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> nombreChatEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombreChat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> nombreChatGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nombreChat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> nombreChatLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nombreChat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> nombreChatBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nombreChat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> nombreChatStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nombreChat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> nombreChatEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nombreChat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
          QAfterFilterCondition>
      nombreChatContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombreChat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
          QAfterFilterCondition>
      nombreChatMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombreChat',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> nombreChatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombreChat',
        value: '',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> nombreChatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombreChat',
        value: '',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> notificarPedidosEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificarPedidos',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> notificarStockBajoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificarStockBajo',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> notificarVentasEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificarVentas',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> sincronizadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sincronizado',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> supabaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> supabaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> supabaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> supabaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supabaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> supabaseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> supabaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
          QAfterFilterCondition>
      supabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
          QAfterFilterCondition>
      supabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> updatedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> updatedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> updatedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> usuarioIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usuarioId',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> usuarioIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usuarioId',
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> usuarioIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> usuarioIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> usuarioIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity,
      QAfterFilterCondition> usuarioIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usuarioId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TelegramConfigEntityQueryObject on QueryBuilder<TelegramConfigEntity,
    TelegramConfigEntity, QFilterCondition> {}

extension TelegramConfigEntityQueryLinks on QueryBuilder<TelegramConfigEntity,
    TelegramConfigEntity, QFilterCondition> {}

extension TelegramConfigEntityQuerySortBy
    on QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QSortBy> {
  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByBotToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'botToken', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByBotTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'botToken', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByChatId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatId', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByChatIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatId', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByNombreChat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreChat', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByNombreChatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreChat', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByNotificarPedidos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificarPedidos', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByNotificarPedidosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificarPedidos', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByNotificarStockBajo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificarStockBajo', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByNotificarStockBajoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificarStockBajo', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByNotificarVentas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificarVentas', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByNotificarVentasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificarVentas', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      sortByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension TelegramConfigEntityQuerySortThenBy
    on QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QSortThenBy> {
  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByBotToken() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'botToken', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByBotTokenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'botToken', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByChatId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatId', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByChatIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chatId', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'enabled', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByNombreChat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreChat', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByNombreChatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreChat', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByNotificarPedidos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificarPedidos', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByNotificarPedidosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificarPedidos', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByNotificarStockBajo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificarStockBajo', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByNotificarStockBajoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificarStockBajo', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByNotificarVentas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificarVentas', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByNotificarVentasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificarVentas', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QAfterSortBy>
      thenByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension TelegramConfigEntityQueryWhereDistinct
    on QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct> {
  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctByBotToken({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'botToken', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctByChatId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chatId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctByComandosPermitidos() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'comandosPermitidos');
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctByEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'enabled');
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaSincronizacion');
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctByNombreChat({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombreChat', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctByNotificarPedidos() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificarPedidos');
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctByNotificarStockBajo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificarStockBajo');
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctByNotificarVentas() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificarVentas');
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sincronizado');
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctBySupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<TelegramConfigEntity, TelegramConfigEntity, QDistinct>
      distinctByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioId');
    });
  }
}

extension TelegramConfigEntityQueryProperty on QueryBuilder<
    TelegramConfigEntity, TelegramConfigEntity, QQueryProperty> {
  QueryBuilder<TelegramConfigEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<TelegramConfigEntity, String, QQueryOperations>
      botTokenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'botToken');
    });
  }

  QueryBuilder<TelegramConfigEntity, String, QQueryOperations>
      chatIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chatId');
    });
  }

  QueryBuilder<TelegramConfigEntity, List<String>, QQueryOperations>
      comandosPermitidosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'comandosPermitidos');
    });
  }

  QueryBuilder<TelegramConfigEntity, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<TelegramConfigEntity, bool, QQueryOperations> enabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'enabled');
    });
  }

  QueryBuilder<TelegramConfigEntity, DateTime?, QQueryOperations>
      fechaSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaSincronizacion');
    });
  }

  QueryBuilder<TelegramConfigEntity, String?, QQueryOperations>
      nombreChatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombreChat');
    });
  }

  QueryBuilder<TelegramConfigEntity, bool, QQueryOperations>
      notificarPedidosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificarPedidos');
    });
  }

  QueryBuilder<TelegramConfigEntity, bool, QQueryOperations>
      notificarStockBajoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificarStockBajo');
    });
  }

  QueryBuilder<TelegramConfigEntity, bool, QQueryOperations>
      notificarVentasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificarVentas');
    });
  }

  QueryBuilder<TelegramConfigEntity, bool, QQueryOperations>
      sincronizadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sincronizado');
    });
  }

  QueryBuilder<TelegramConfigEntity, String?, QQueryOperations>
      supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<TelegramConfigEntity, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<TelegramConfigEntity, int?, QQueryOperations>
      usuarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioId');
    });
  }
}
