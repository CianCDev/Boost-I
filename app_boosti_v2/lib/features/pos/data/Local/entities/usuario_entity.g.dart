// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUsuarioEntityCollection on Isar {
  IsarCollection<UsuarioEntity> get usuarioEntitys => this.collection();
}

const UsuarioEntitySchema = CollectionSchema(
  name: r'UsuarioEntity',
  id: 2843857974286045947,
  properties: {
    r'activo': PropertySchema(
      id: 0,
      name: r'activo',
      type: IsarType.bool,
    ),
    r'cajaAsignada': PropertySchema(
      id: 1,
      name: r'cajaAsignada',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'departamento': PropertySchema(
      id: 3,
      name: r'departamento',
      type: IsarType.string,
    ),
    r'departamentoId': PropertySchema(
      id: 4,
      name: r'departamentoId',
      type: IsarType.long,
    ),
    r'deviceId': PropertySchema(
      id: 5,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'dynamicId': PropertySchema(
      id: 6,
      name: r'dynamicId',
      type: IsarType.string,
    ),
    r'email': PropertySchema(
      id: 7,
      name: r'email',
      type: IsarType.string,
    ),
    r'estado': PropertySchema(
      id: 8,
      name: r'estado',
      type: IsarType.string,
    ),
    r'fechaSincronizacion': PropertySchema(
      id: 9,
      name: r'fechaSincronizacion',
      type: IsarType.dateTime,
    ),
    r'localId': PropertySchema(
      id: 10,
      name: r'localId',
      type: IsarType.long,
    ),
    r'nombre': PropertySchema(
      id: 11,
      name: r'nombre',
      type: IsarType.string,
    ),
    r'password': PropertySchema(
      id: 12,
      name: r'password',
      type: IsarType.string,
    ),
    r'pin': PropertySchema(
      id: 13,
      name: r'pin',
      type: IsarType.string,
    ),
    r'rol': PropertySchema(
      id: 14,
      name: r'rol',
      type: IsarType.string,
    ),
    r'sincronizado': PropertySchema(
      id: 15,
      name: r'sincronizado',
      type: IsarType.bool,
    ),
    r'supabaseId': PropertySchema(
      id: 16,
      name: r'supabaseId',
      type: IsarType.string,
    ),
    r'supabaseUid': PropertySchema(
      id: 17,
      name: r'supabaseUid',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 18,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _usuarioEntityEstimateSize,
  serialize: _usuarioEntitySerialize,
  deserialize: _usuarioEntityDeserialize,
  deserializeProp: _usuarioEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'dynamicId': IndexSchema(
      id: -273221038475025965,
      name: r'dynamicId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dynamicId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _usuarioEntityGetId,
  getLinks: _usuarioEntityGetLinks,
  attach: _usuarioEntityAttach,
  version: '3.1.0+1',
);

int _usuarioEntityEstimateSize(
  UsuarioEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.cajaAsignada.length * 3;
  {
    final value = object.departamento;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.deviceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.dynamicId.length * 3;
  {
    final value = object.email;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.estado.length * 3;
  bytesCount += 3 + object.nombre.length * 3;
  {
    final value = object.password;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.pin.length * 3;
  bytesCount += 3 + object.rol.length * 3;
  {
    final value = object.supabaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.supabaseUid;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _usuarioEntitySerialize(
  UsuarioEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.activo);
  writer.writeString(offsets[1], object.cajaAsignada);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.departamento);
  writer.writeLong(offsets[4], object.departamentoId);
  writer.writeString(offsets[5], object.deviceId);
  writer.writeString(offsets[6], object.dynamicId);
  writer.writeString(offsets[7], object.email);
  writer.writeString(offsets[8], object.estado);
  writer.writeDateTime(offsets[9], object.fechaSincronizacion);
  writer.writeLong(offsets[10], object.localId);
  writer.writeString(offsets[11], object.nombre);
  writer.writeString(offsets[12], object.password);
  writer.writeString(offsets[13], object.pin);
  writer.writeString(offsets[14], object.rol);
  writer.writeBool(offsets[15], object.sincronizado);
  writer.writeString(offsets[16], object.supabaseId);
  writer.writeString(offsets[17], object.supabaseUid);
  writer.writeDateTime(offsets[18], object.updatedAt);
}

UsuarioEntity _usuarioEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UsuarioEntity();
  object.activo = reader.readBool(offsets[0]);
  object.cajaAsignada = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTimeOrNull(offsets[2]);
  object.departamento = reader.readStringOrNull(offsets[3]);
  object.departamentoId = reader.readLongOrNull(offsets[4]);
  object.deviceId = reader.readStringOrNull(offsets[5]);
  object.dynamicId = reader.readString(offsets[6]);
  object.email = reader.readStringOrNull(offsets[7]);
  object.estado = reader.readString(offsets[8]);
  object.fechaSincronizacion = reader.readDateTimeOrNull(offsets[9]);
  object.id = id;
  object.localId = reader.readLongOrNull(offsets[10]);
  object.nombre = reader.readString(offsets[11]);
  object.password = reader.readStringOrNull(offsets[12]);
  object.pin = reader.readString(offsets[13]);
  object.rol = reader.readString(offsets[14]);
  object.sincronizado = reader.readBool(offsets[15]);
  object.supabaseId = reader.readStringOrNull(offsets[16]);
  object.supabaseUid = reader.readStringOrNull(offsets[17]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[18]);
  return object;
}

P _usuarioEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _usuarioEntityGetId(UsuarioEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _usuarioEntityGetLinks(UsuarioEntity object) {
  return [];
}

void _usuarioEntityAttach(
    IsarCollection<dynamic> col, Id id, UsuarioEntity object) {
  object.id = id;
}

extension UsuarioEntityByIndex on IsarCollection<UsuarioEntity> {
  Future<UsuarioEntity?> getByDynamicId(String dynamicId) {
    return getByIndex(r'dynamicId', [dynamicId]);
  }

  UsuarioEntity? getByDynamicIdSync(String dynamicId) {
    return getByIndexSync(r'dynamicId', [dynamicId]);
  }

  Future<bool> deleteByDynamicId(String dynamicId) {
    return deleteByIndex(r'dynamicId', [dynamicId]);
  }

  bool deleteByDynamicIdSync(String dynamicId) {
    return deleteByIndexSync(r'dynamicId', [dynamicId]);
  }

  Future<List<UsuarioEntity?>> getAllByDynamicId(List<String> dynamicIdValues) {
    final values = dynamicIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'dynamicId', values);
  }

  List<UsuarioEntity?> getAllByDynamicIdSync(List<String> dynamicIdValues) {
    final values = dynamicIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'dynamicId', values);
  }

  Future<int> deleteAllByDynamicId(List<String> dynamicIdValues) {
    final values = dynamicIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'dynamicId', values);
  }

  int deleteAllByDynamicIdSync(List<String> dynamicIdValues) {
    final values = dynamicIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'dynamicId', values);
  }

  Future<Id> putByDynamicId(UsuarioEntity object) {
    return putByIndex(r'dynamicId', object);
  }

  Id putByDynamicIdSync(UsuarioEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'dynamicId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDynamicId(List<UsuarioEntity> objects) {
    return putAllByIndex(r'dynamicId', objects);
  }

  List<Id> putAllByDynamicIdSync(List<UsuarioEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'dynamicId', objects, saveLinks: saveLinks);
  }
}

extension UsuarioEntityQueryWhereSort
    on QueryBuilder<UsuarioEntity, UsuarioEntity, QWhere> {
  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UsuarioEntityQueryWhere
    on QueryBuilder<UsuarioEntity, UsuarioEntity, QWhereClause> {
  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterWhereClause>
      dynamicIdEqualTo(String dynamicId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dynamicId',
        value: [dynamicId],
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterWhereClause>
      dynamicIdNotEqualTo(String dynamicId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dynamicId',
              lower: [],
              upper: [dynamicId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dynamicId',
              lower: [dynamicId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dynamicId',
              lower: [dynamicId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dynamicId',
              lower: [],
              upper: [dynamicId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension UsuarioEntityQueryFilter
    on QueryBuilder<UsuarioEntity, UsuarioEntity, QFilterCondition> {
  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      activoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activo',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      cajaAsignadaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cajaAsignada',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      cajaAsignadaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cajaAsignada',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      cajaAsignadaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cajaAsignada',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      cajaAsignadaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cajaAsignada',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      cajaAsignadaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cajaAsignada',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      cajaAsignadaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cajaAsignada',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      cajaAsignadaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cajaAsignada',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      cajaAsignadaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cajaAsignada',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      cajaAsignadaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cajaAsignada',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      cajaAsignadaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cajaAsignada',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      createdAtGreaterThan(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      createdAtLessThan(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      createdAtBetween(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'departamento',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'departamento',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departamento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'departamento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'departamento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'departamento',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'departamento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'departamento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'departamento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'departamento',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departamento',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'departamento',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'departamentoId',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'departamentoId',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'departamentoId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'departamentoId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'departamentoId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      departamentoIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'departamentoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      deviceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deviceId',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      deviceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deviceId',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      deviceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      deviceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      deviceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      deviceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      dynamicIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dynamicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      dynamicIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dynamicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      dynamicIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dynamicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      dynamicIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dynamicId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      dynamicIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dynamicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      dynamicIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dynamicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      dynamicIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dynamicId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      dynamicIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dynamicId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      dynamicIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dynamicId',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      dynamicIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dynamicId',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      emailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      emailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      emailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      emailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      emailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      emailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'email',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      emailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      emailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      emailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      emailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'email',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      estadoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      estadoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      estadoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      estadoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'estado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      estadoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      estadoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      estadoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      estadoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'estado',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      estadoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      estadoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      fechaSincronizacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      fechaSincronizacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      fechaSincronizacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      fechaSincronizacionGreaterThan(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      fechaSincronizacionLessThan(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      fechaSincronizacionBetween(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      localIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localId',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      localIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localId',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      localIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      localIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      localIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      localIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      nombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      nombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      passwordIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'password',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      passwordIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'password',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      passwordEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      passwordGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      passwordLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      passwordBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'password',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      passwordStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      passwordEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      passwordContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'password',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      passwordMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'password',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      passwordIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'password',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      passwordIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'password',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> pinEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      pinGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> pinLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> pinBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pin',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      pinStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> pinEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> pinContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pin',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> pinMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pin',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      pinIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pin',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      pinIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pin',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> rolEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      rolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> rolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> rolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      rolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> rolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> rolContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition> rolMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      rolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rol',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      rolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rol',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      sincronizadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sincronizado',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseIdEqualTo(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseIdGreaterThan(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseIdLessThan(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseIdBetween(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseIdStartsWith(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseIdEndsWith(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseUidIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseUid',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseUidIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseUid',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseUidEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseUidGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supabaseUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseUidLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supabaseUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseUidBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supabaseUid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseUidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supabaseUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseUidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supabaseUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseUidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseUid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseUidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseUid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseUidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseUid',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      supabaseUidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseUid',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      updatedAtGreaterThan(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      updatedAtLessThan(
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

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterFilterCondition>
      updatedAtBetween(
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
}

extension UsuarioEntityQueryObject
    on QueryBuilder<UsuarioEntity, UsuarioEntity, QFilterCondition> {}

extension UsuarioEntityQueryLinks
    on QueryBuilder<UsuarioEntity, UsuarioEntity, QFilterCondition> {}

extension UsuarioEntityQuerySortBy
    on QueryBuilder<UsuarioEntity, UsuarioEntity, QSortBy> {
  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortByCajaAsignada() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaAsignada', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortByCajaAsignadaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaAsignada', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortByDepartamento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departamento', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortByDepartamentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departamento', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortByDepartamentoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departamentoId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortByDepartamentoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departamentoId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByDynamicId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortByDynamicIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortByPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByPin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pin', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByPinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pin', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByRol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rol', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByRolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rol', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortBySupabaseUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseUid', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortBySupabaseUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseUid', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension UsuarioEntityQuerySortThenBy
    on QueryBuilder<UsuarioEntity, UsuarioEntity, QSortThenBy> {
  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenByCajaAsignada() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaAsignada', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenByCajaAsignadaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cajaAsignada', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenByDepartamento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departamento', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenByDepartamentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departamento', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenByDepartamentoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departamentoId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenByDepartamentoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'departamentoId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByDynamicId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenByDynamicIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dynamicId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByPassword() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenByPasswordDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'password', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByPin() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pin', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByPinDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pin', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByRol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rol', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByRolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rol', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenBySupabaseUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseUid', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenBySupabaseUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseUid', Sort.desc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension UsuarioEntityQueryWhereDistinct
    on QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> {
  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activo');
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByCajaAsignada(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cajaAsignada', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByDepartamento(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'departamento', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct>
      distinctByDepartamentoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'departamentoId');
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByDeviceId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByDynamicId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dynamicId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByEmail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByEstado(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct>
      distinctByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaSincronizacion');
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localId');
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByNombre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByPassword(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'password', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByPin(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pin', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByRol(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rol', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct>
      distinctBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sincronizado');
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctBySupabaseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctBySupabaseUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseUid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsuarioEntity, UsuarioEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension UsuarioEntityQueryProperty
    on QueryBuilder<UsuarioEntity, UsuarioEntity, QQueryProperty> {
  QueryBuilder<UsuarioEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UsuarioEntity, bool, QQueryOperations> activoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activo');
    });
  }

  QueryBuilder<UsuarioEntity, String, QQueryOperations> cajaAsignadaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cajaAsignada');
    });
  }

  QueryBuilder<UsuarioEntity, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<UsuarioEntity, String?, QQueryOperations>
      departamentoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'departamento');
    });
  }

  QueryBuilder<UsuarioEntity, int?, QQueryOperations> departamentoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'departamentoId');
    });
  }

  QueryBuilder<UsuarioEntity, String?, QQueryOperations> deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<UsuarioEntity, String, QQueryOperations> dynamicIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dynamicId');
    });
  }

  QueryBuilder<UsuarioEntity, String?, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<UsuarioEntity, String, QQueryOperations> estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<UsuarioEntity, DateTime?, QQueryOperations>
      fechaSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaSincronizacion');
    });
  }

  QueryBuilder<UsuarioEntity, int?, QQueryOperations> localIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localId');
    });
  }

  QueryBuilder<UsuarioEntity, String, QQueryOperations> nombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombre');
    });
  }

  QueryBuilder<UsuarioEntity, String?, QQueryOperations> passwordProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'password');
    });
  }

  QueryBuilder<UsuarioEntity, String, QQueryOperations> pinProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pin');
    });
  }

  QueryBuilder<UsuarioEntity, String, QQueryOperations> rolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rol');
    });
  }

  QueryBuilder<UsuarioEntity, bool, QQueryOperations> sincronizadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sincronizado');
    });
  }

  QueryBuilder<UsuarioEntity, String?, QQueryOperations> supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<UsuarioEntity, String?, QQueryOperations> supabaseUidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseUid');
    });
  }

  QueryBuilder<UsuarioEntity, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
