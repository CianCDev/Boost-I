// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_session_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCartSessionEntityCollection on Isar {
  IsarCollection<CartSessionEntity> get cartSessionEntitys => this.collection();
}

const CartSessionEntitySchema = CollectionSchema(
  name: r'CartSessionEntity',
  id: 3947143390069076431,
  properties: {
    r'clienteDocumento': PropertySchema(
      id: 0,
      name: r'clienteDocumento',
      type: IsarType.string,
    ),
    r'clienteIsarId': PropertySchema(
      id: 1,
      name: r'clienteIsarId',
      type: IsarType.long,
    ),
    r'clienteNombre': PropertySchema(
      id: 2,
      name: r'clienteNombre',
      type: IsarType.string,
    ),
    r'clienteSupabaseId': PropertySchema(
      id: 3,
      name: r'clienteSupabaseId',
      type: IsarType.string,
    ),
    r'configIvaPais': PropertySchema(
      id: 4,
      name: r'configIvaPais',
      type: IsarType.string,
    ),
    r'configIvaPorcentaje': PropertySchema(
      id: 5,
      name: r'configIvaPorcentaje',
      type: IsarType.double,
    ),
    r'configIvaPreciosIncluyenIva': PropertySchema(
      id: 6,
      name: r'configIvaPreciosIncluyenIva',
      type: IsarType.bool,
    ),
    r'createdAt': PropertySchema(
      id: 7,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'items': PropertySchema(
      id: 8,
      name: r'items',
      type: IsarType.objectList,
      target: r'CartSessionItem',
    ),
    r'itemsNombres': PropertySchema(
      id: 9,
      name: r'itemsNombres',
      type: IsarType.stringList,
    ),
    r'ivaHabilitado': PropertySchema(
      id: 10,
      name: r'ivaHabilitado',
      type: IsarType.bool,
    ),
    r'nombre': PropertySchema(
      id: 11,
      name: r'nombre',
      type: IsarType.string,
    ),
    r'notas': PropertySchema(
      id: 12,
      name: r'notas',
      type: IsarType.string,
    ),
    r'sessionId': PropertySchema(
      id: 13,
      name: r'sessionId',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 14,
      name: r'status',
      type: IsarType.string,
      enumMap: _CartSessionEntitystatusEnumValueMap,
    ),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'usuarioId': PropertySchema(
      id: 16,
      name: r'usuarioId',
      type: IsarType.long,
    )
  },
  estimateSize: _cartSessionEntityEstimateSize,
  serialize: _cartSessionEntitySerialize,
  deserialize: _cartSessionEntityDeserialize,
  deserializeProp: _cartSessionEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'usuarioId': IndexSchema(
      id: -6806307564427522310,
      name: r'usuarioId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'usuarioId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'CartSessionItem': CartSessionItemSchema},
  getId: _cartSessionEntityGetId,
  getLinks: _cartSessionEntityGetLinks,
  attach: _cartSessionEntityAttach,
  version: '3.1.0+1',
);

int _cartSessionEntityEstimateSize(
  CartSessionEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.clienteDocumento;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.clienteNombre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.clienteSupabaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.configIvaPais.length * 3;
  bytesCount += 3 + object.items.length * 3;
  {
    final offsets = allOffsets[CartSessionItem]!;
    for (var i = 0; i < object.items.length; i++) {
      final value = object.items[i];
      bytesCount +=
          CartSessionItemSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.itemsNombres.length * 3;
  {
    for (var i = 0; i < object.itemsNombres.length; i++) {
      final value = object.itemsNombres[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.nombre.length * 3;
  {
    final value = object.notas;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sessionId.length * 3;
  bytesCount += 3 + object.status.name.length * 3;
  return bytesCount;
}

void _cartSessionEntitySerialize(
  CartSessionEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.clienteDocumento);
  writer.writeLong(offsets[1], object.clienteIsarId);
  writer.writeString(offsets[2], object.clienteNombre);
  writer.writeString(offsets[3], object.clienteSupabaseId);
  writer.writeString(offsets[4], object.configIvaPais);
  writer.writeDouble(offsets[5], object.configIvaPorcentaje);
  writer.writeBool(offsets[6], object.configIvaPreciosIncluyenIva);
  writer.writeDateTime(offsets[7], object.createdAt);
  writer.writeObjectList<CartSessionItem>(
    offsets[8],
    allOffsets,
    CartSessionItemSchema.serialize,
    object.items,
  );
  writer.writeStringList(offsets[9], object.itemsNombres);
  writer.writeBool(offsets[10], object.ivaHabilitado);
  writer.writeString(offsets[11], object.nombre);
  writer.writeString(offsets[12], object.notas);
  writer.writeString(offsets[13], object.sessionId);
  writer.writeString(offsets[14], object.status.name);
  writer.writeDateTime(offsets[15], object.updatedAt);
  writer.writeLong(offsets[16], object.usuarioId);
}

CartSessionEntity _cartSessionEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CartSessionEntity();
  object.clienteDocumento = reader.readStringOrNull(offsets[0]);
  object.clienteIsarId = reader.readLongOrNull(offsets[1]);
  object.clienteNombre = reader.readStringOrNull(offsets[2]);
  object.clienteSupabaseId = reader.readStringOrNull(offsets[3]);
  object.configIvaPais = reader.readString(offsets[4]);
  object.configIvaPorcentaje = reader.readDouble(offsets[5]);
  object.configIvaPreciosIncluyenIva = reader.readBool(offsets[6]);
  object.createdAt = reader.readDateTime(offsets[7]);
  object.id = id;
  object.items = reader.readObjectList<CartSessionItem>(
        offsets[8],
        CartSessionItemSchema.deserialize,
        allOffsets,
        CartSessionItem(),
      ) ??
      [];
  object.itemsNombres = reader.readStringList(offsets[9]) ?? [];
  object.ivaHabilitado = reader.readBool(offsets[10]);
  object.nombre = reader.readString(offsets[11]);
  object.notas = reader.readStringOrNull(offsets[12]);
  object.sessionId = reader.readString(offsets[13]);
  object.status = _CartSessionEntitystatusValueEnumMap[
          reader.readStringOrNull(offsets[14])] ??
      CartSessionStatus.enEspera;
  object.updatedAt = reader.readDateTime(offsets[15]);
  object.usuarioId = reader.readLong(offsets[16]);
  return object;
}

P _cartSessionEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readObjectList<CartSessionItem>(
            offset,
            CartSessionItemSchema.deserialize,
            allOffsets,
            CartSessionItem(),
          ) ??
          []) as P;
    case 9:
      return (reader.readStringList(offset) ?? []) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (_CartSessionEntitystatusValueEnumMap[
              reader.readStringOrNull(offset)] ??
          CartSessionStatus.enEspera) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _CartSessionEntitystatusEnumValueMap = {
  r'enEspera': r'enEspera',
  r'abandonado': r'abandonado',
};
const _CartSessionEntitystatusValueEnumMap = {
  r'enEspera': CartSessionStatus.enEspera,
  r'abandonado': CartSessionStatus.abandonado,
};

Id _cartSessionEntityGetId(CartSessionEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cartSessionEntityGetLinks(
    CartSessionEntity object) {
  return [];
}

void _cartSessionEntityAttach(
    IsarCollection<dynamic> col, Id id, CartSessionEntity object) {
  object.id = id;
}

extension CartSessionEntityByIndex on IsarCollection<CartSessionEntity> {
  Future<CartSessionEntity?> getBySessionId(String sessionId) {
    return getByIndex(r'sessionId', [sessionId]);
  }

  CartSessionEntity? getBySessionIdSync(String sessionId) {
    return getByIndexSync(r'sessionId', [sessionId]);
  }

  Future<bool> deleteBySessionId(String sessionId) {
    return deleteByIndex(r'sessionId', [sessionId]);
  }

  bool deleteBySessionIdSync(String sessionId) {
    return deleteByIndexSync(r'sessionId', [sessionId]);
  }

  Future<List<CartSessionEntity?>> getAllBySessionId(
      List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'sessionId', values);
  }

  List<CartSessionEntity?> getAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sessionId', values);
  }

  Future<int> deleteAllBySessionId(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sessionId', values);
  }

  int deleteAllBySessionIdSync(List<String> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sessionId', values);
  }

  Future<Id> putBySessionId(CartSessionEntity object) {
    return putByIndex(r'sessionId', object);
  }

  Id putBySessionIdSync(CartSessionEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'sessionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySessionId(List<CartSessionEntity> objects) {
    return putAllByIndex(r'sessionId', objects);
  }

  List<Id> putAllBySessionIdSync(List<CartSessionEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'sessionId', objects, saveLinks: saveLinks);
  }
}

extension CartSessionEntityQueryWhereSort
    on QueryBuilder<CartSessionEntity, CartSessionEntity, QWhere> {
  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhere>
      anyUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'usuarioId'),
      );
    });
  }
}

extension CartSessionEntityQueryWhere
    on QueryBuilder<CartSessionEntity, CartSessionEntity, QWhereClause> {
  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhereClause>
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

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhereClause>
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

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhereClause>
      sessionIdEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhereClause>
      sessionIdNotEqualTo(String sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhereClause>
      usuarioIdEqualTo(int usuarioId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'usuarioId',
        value: [usuarioId],
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhereClause>
      usuarioIdNotEqualTo(int usuarioId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [],
              upper: [usuarioId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [usuarioId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [usuarioId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [],
              upper: [usuarioId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhereClause>
      usuarioIdGreaterThan(
    int usuarioId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'usuarioId',
        lower: [usuarioId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhereClause>
      usuarioIdLessThan(
    int usuarioId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'usuarioId',
        lower: [],
        upper: [usuarioId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterWhereClause>
      usuarioIdBetween(
    int lowerUsuarioId,
    int upperUsuarioId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'usuarioId',
        lower: [lowerUsuarioId],
        includeLower: includeLower,
        upper: [upperUsuarioId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CartSessionEntityQueryFilter
    on QueryBuilder<CartSessionEntity, CartSessionEntity, QFilterCondition> {
  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteDocumentoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteDocumento',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteDocumentoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteDocumento',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteDocumentoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteDocumentoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clienteDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteDocumentoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clienteDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteDocumentoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clienteDocumento',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteDocumentoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clienteDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteDocumentoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clienteDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteDocumentoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clienteDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteDocumentoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clienteDocumento',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteDocumentoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteDocumento',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteDocumentoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clienteDocumento',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteIsarIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteIsarId',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteIsarIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteIsarId',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteIsarIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteIsarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteIsarIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clienteIsarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteIsarIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clienteIsarId',
        value: value,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteIsarIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clienteIsarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteNombreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteNombre',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteNombreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteNombre',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteNombreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteNombreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clienteNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteNombreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clienteNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteNombreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clienteNombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteNombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clienteNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteNombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clienteNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clienteNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clienteNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clienteNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteSupabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteSupabaseId',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteSupabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteSupabaseId',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteSupabaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteSupabaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clienteSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteSupabaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clienteSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteSupabaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clienteSupabaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteSupabaseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clienteSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteSupabaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clienteSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteSupabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clienteSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteSupabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clienteSupabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteSupabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      clienteSupabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clienteSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPaisEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'configIvaPais',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPaisGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'configIvaPais',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPaisLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'configIvaPais',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPaisBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'configIvaPais',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPaisStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'configIvaPais',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPaisEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'configIvaPais',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPaisContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'configIvaPais',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPaisMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'configIvaPais',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPaisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'configIvaPais',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPaisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'configIvaPais',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPorcentajeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'configIvaPorcentaje',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPorcentajeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'configIvaPorcentaje',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPorcentajeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'configIvaPorcentaje',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPorcentajeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'configIvaPorcentaje',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      configIvaPreciosIncluyenIvaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'configIvaPreciosIncluyenIva',
        value: value,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
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

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'items',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemsNombres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemsNombres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemsNombres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemsNombres',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemsNombres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemsNombres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemsNombres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemsNombres',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemsNombres',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemsNombres',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemsNombres',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemsNombres',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemsNombres',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemsNombres',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemsNombres',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsNombresLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'itemsNombres',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      ivaHabilitadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ivaHabilitado',
        value: value,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      nombreEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      nombreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      nombreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      nombreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      nombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      nombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      nombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      nombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      notasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notas',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      notasIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notas',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      notasEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      notasGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      notasLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      notasBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notas',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      notasStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      notasEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      notasContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      notasMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notas',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      notasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notas',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      notasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notas',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      sessionIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      sessionIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      sessionIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      sessionIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      sessionIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      sessionIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      sessionIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      sessionIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      sessionIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      sessionIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionId',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      statusEqualTo(
    CartSessionStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      statusGreaterThan(
    CartSessionStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      statusLessThan(
    CartSessionStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      statusBetween(
    CartSessionStatus lower,
    CartSessionStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
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

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
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

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
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

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      usuarioIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      usuarioIdGreaterThan(
    int value, {
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

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      usuarioIdLessThan(
    int value, {
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

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      usuarioIdBetween(
    int lower,
    int upper, {
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

extension CartSessionEntityQueryObject
    on QueryBuilder<CartSessionEntity, CartSessionEntity, QFilterCondition> {
  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterFilterCondition>
      itemsElement(FilterQuery<CartSessionItem> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'items');
    });
  }
}

extension CartSessionEntityQueryLinks
    on QueryBuilder<CartSessionEntity, CartSessionEntity, QFilterCondition> {}

extension CartSessionEntityQuerySortBy
    on QueryBuilder<CartSessionEntity, CartSessionEntity, QSortBy> {
  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByClienteDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteDocumento', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByClienteDocumentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteDocumento', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByClienteIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteIsarId', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByClienteIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteIsarId', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByClienteNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNombre', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByClienteNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNombre', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByClienteSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByClienteSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByConfigIvaPais() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configIvaPais', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByConfigIvaPaisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configIvaPais', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByConfigIvaPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configIvaPorcentaje', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByConfigIvaPorcentajeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configIvaPorcentaje', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByConfigIvaPreciosIncluyenIva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configIvaPreciosIncluyenIva', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByConfigIvaPreciosIncluyenIvaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configIvaPreciosIncluyenIva', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByIvaHabilitado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ivaHabilitado', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByIvaHabilitadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ivaHabilitado', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByNotas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notas', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByNotasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notas', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      sortByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension CartSessionEntityQuerySortThenBy
    on QueryBuilder<CartSessionEntity, CartSessionEntity, QSortThenBy> {
  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByClienteDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteDocumento', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByClienteDocumentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteDocumento', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByClienteIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteIsarId', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByClienteIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteIsarId', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByClienteNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNombre', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByClienteNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNombre', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByClienteSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByClienteSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByConfigIvaPais() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configIvaPais', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByConfigIvaPaisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configIvaPais', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByConfigIvaPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configIvaPorcentaje', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByConfigIvaPorcentajeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configIvaPorcentaje', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByConfigIvaPreciosIncluyenIva() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configIvaPreciosIncluyenIva', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByConfigIvaPreciosIncluyenIvaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'configIvaPreciosIncluyenIva', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByIvaHabilitado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ivaHabilitado', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByIvaHabilitadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ivaHabilitado', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByNotas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notas', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByNotasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notas', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QAfterSortBy>
      thenByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension CartSessionEntityQueryWhereDistinct
    on QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct> {
  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByClienteDocumento({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteDocumento',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByClienteIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteIsarId');
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByClienteNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByClienteSupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteSupabaseId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByConfigIvaPais({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'configIvaPais',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByConfigIvaPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'configIvaPorcentaje');
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByConfigIvaPreciosIncluyenIva() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'configIvaPreciosIncluyenIva');
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByItemsNombres() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemsNombres');
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByIvaHabilitado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ivaHabilitado');
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct> distinctByNotas(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notas', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctBySessionId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionEntity, QDistinct>
      distinctByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioId');
    });
  }
}

extension CartSessionEntityQueryProperty
    on QueryBuilder<CartSessionEntity, CartSessionEntity, QQueryProperty> {
  QueryBuilder<CartSessionEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CartSessionEntity, String?, QQueryOperations>
      clienteDocumentoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteDocumento');
    });
  }

  QueryBuilder<CartSessionEntity, int?, QQueryOperations>
      clienteIsarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteIsarId');
    });
  }

  QueryBuilder<CartSessionEntity, String?, QQueryOperations>
      clienteNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteNombre');
    });
  }

  QueryBuilder<CartSessionEntity, String?, QQueryOperations>
      clienteSupabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteSupabaseId');
    });
  }

  QueryBuilder<CartSessionEntity, String, QQueryOperations>
      configIvaPaisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'configIvaPais');
    });
  }

  QueryBuilder<CartSessionEntity, double, QQueryOperations>
      configIvaPorcentajeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'configIvaPorcentaje');
    });
  }

  QueryBuilder<CartSessionEntity, bool, QQueryOperations>
      configIvaPreciosIncluyenIvaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'configIvaPreciosIncluyenIva');
    });
  }

  QueryBuilder<CartSessionEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CartSessionEntity, List<CartSessionItem>, QQueryOperations>
      itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'items');
    });
  }

  QueryBuilder<CartSessionEntity, List<String>, QQueryOperations>
      itemsNombresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemsNombres');
    });
  }

  QueryBuilder<CartSessionEntity, bool, QQueryOperations>
      ivaHabilitadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ivaHabilitado');
    });
  }

  QueryBuilder<CartSessionEntity, String, QQueryOperations> nombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombre');
    });
  }

  QueryBuilder<CartSessionEntity, String?, QQueryOperations> notasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notas');
    });
  }

  QueryBuilder<CartSessionEntity, String, QQueryOperations>
      sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<CartSessionEntity, CartSessionStatus, QQueryOperations>
      statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<CartSessionEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<CartSessionEntity, int, QQueryOperations> usuarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioId');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const CartSessionItemSchema = Schema(
  name: r'CartSessionItem',
  id: -1957373908056655466,
  properties: {
    r'cantidad': PropertySchema(
      id: 0,
      name: r'cantidad',
      type: IsarType.double,
    ),
    r'esDescuentoEspecial': PropertySchema(
      id: 1,
      name: r'esDescuentoEspecial',
      type: IsarType.bool,
    ),
    r'esPesado': PropertySchema(
      id: 2,
      name: r'esPesado',
      type: IsarType.bool,
    ),
    r'precioOriginal': PropertySchema(
      id: 3,
      name: r'precioOriginal',
      type: IsarType.double,
    ),
    r'precioUnidad': PropertySchema(
      id: 4,
      name: r'precioUnidad',
      type: IsarType.double,
    ),
    r'productoCategoria': PropertySchema(
      id: 5,
      name: r'productoCategoria',
      type: IsarType.string,
    ),
    r'productoCodigoBarras': PropertySchema(
      id: 6,
      name: r'productoCodigoBarras',
      type: IsarType.string,
    ),
    r'productoId': PropertySchema(
      id: 7,
      name: r'productoId',
      type: IsarType.string,
    ),
    r'productoNombre': PropertySchema(
      id: 8,
      name: r'productoNombre',
      type: IsarType.string,
    )
  },
  estimateSize: _cartSessionItemEstimateSize,
  serialize: _cartSessionItemSerialize,
  deserialize: _cartSessionItemDeserialize,
  deserializeProp: _cartSessionItemDeserializeProp,
);

int _cartSessionItemEstimateSize(
  CartSessionItem object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.productoCategoria.length * 3;
  bytesCount += 3 + object.productoCodigoBarras.length * 3;
  bytesCount += 3 + object.productoId.length * 3;
  bytesCount += 3 + object.productoNombre.length * 3;
  return bytesCount;
}

void _cartSessionItemSerialize(
  CartSessionItem object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cantidad);
  writer.writeBool(offsets[1], object.esDescuentoEspecial);
  writer.writeBool(offsets[2], object.esPesado);
  writer.writeDouble(offsets[3], object.precioOriginal);
  writer.writeDouble(offsets[4], object.precioUnidad);
  writer.writeString(offsets[5], object.productoCategoria);
  writer.writeString(offsets[6], object.productoCodigoBarras);
  writer.writeString(offsets[7], object.productoId);
  writer.writeString(offsets[8], object.productoNombre);
}

CartSessionItem _cartSessionItemDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CartSessionItem();
  object.cantidad = reader.readDouble(offsets[0]);
  object.esDescuentoEspecial = reader.readBool(offsets[1]);
  object.esPesado = reader.readBool(offsets[2]);
  object.precioOriginal = reader.readDouble(offsets[3]);
  object.precioUnidad = reader.readDouble(offsets[4]);
  object.productoCategoria = reader.readString(offsets[5]);
  object.productoCodigoBarras = reader.readString(offsets[6]);
  object.productoId = reader.readString(offsets[7]);
  object.productoNombre = reader.readString(offsets[8]);
  return object;
}

P _cartSessionItemDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension CartSessionItemQueryFilter
    on QueryBuilder<CartSessionItem, CartSessionItem, QFilterCondition> {
  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      cantidadEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      cantidadGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cantidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      cantidadLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cantidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      cantidadBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cantidad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      esDescuentoEspecialEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'esDescuentoEspecial',
        value: value,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      esPesadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'esPesado',
        value: value,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      precioOriginalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precioOriginal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      precioOriginalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precioOriginal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      precioOriginalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precioOriginal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      precioOriginalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precioOriginal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      precioUnidadEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precioUnidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      precioUnidadGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precioUnidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      precioUnidadLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precioUnidad',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      precioUnidadBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precioUnidad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCategoriaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoCategoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCategoriaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productoCategoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCategoriaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productoCategoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCategoriaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productoCategoria',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCategoriaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productoCategoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCategoriaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productoCategoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCategoriaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productoCategoria',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCategoriaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productoCategoria',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCategoriaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoCategoria',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCategoriaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productoCategoria',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCodigoBarrasEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoCodigoBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCodigoBarrasGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productoCodigoBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCodigoBarrasLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productoCodigoBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCodigoBarrasBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productoCodigoBarras',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCodigoBarrasStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productoCodigoBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCodigoBarrasEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productoCodigoBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCodigoBarrasContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productoCodigoBarras',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCodigoBarrasMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productoCodigoBarras',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCodigoBarrasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoCodigoBarras',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoCodigoBarrasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productoCodigoBarras',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productoId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productoId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productoId',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoNombreEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoNombreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoNombreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoNombreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productoNombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoNombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'productoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoNombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'productoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'productoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'productoNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<CartSessionItem, CartSessionItem, QAfterFilterCondition>
      productoNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'productoNombre',
        value: '',
      ));
    });
  }
}

extension CartSessionItemQueryObject
    on QueryBuilder<CartSessionItem, CartSessionItem, QFilterCondition> {}
