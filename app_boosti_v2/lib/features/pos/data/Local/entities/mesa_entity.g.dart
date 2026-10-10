// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mesa_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMesaEntityCollection on Isar {
  IsarCollection<MesaEntity> get mesaEntitys => this.collection();
}

const MesaEntitySchema = CollectionSchema(
  name: r'MesaEntity',
  id: 8698681675579858238,
  properties: {
    r'capacidad': PropertySchema(
      id: 0,
      name: r'capacidad',
      type: IsarType.long,
    ),
    r'claveUnica': PropertySchema(
      id: 1,
      name: r'claveUnica',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'disponibleParaComanda': PropertySchema(
      id: 3,
      name: r'disponibleParaComanda',
      type: IsarType.bool,
    ),
    r'estaUnida': PropertySchema(
      id: 4,
      name: r'estaUnida',
      type: IsarType.bool,
    ),
    r'estado': PropertySchema(
      id: 5,
      name: r'estado',
      type: IsarType.string,
      enumMap: _MesaEntityestadoEnumValueMap,
    ),
    r'fechaSincronizacion': PropertySchema(
      id: 6,
      name: r'fechaSincronizacion',
      type: IsarType.dateTime,
    ),
    r'localId': PropertySchema(
      id: 7,
      name: r'localId',
      type: IsarType.long,
    ),
    r'localSupabaseId': PropertySchema(
      id: 8,
      name: r'localSupabaseId',
      type: IsarType.string,
    ),
    r'nombre': PropertySchema(
      id: 9,
      name: r'nombre',
      type: IsarType.string,
    ),
    r'ocupadaDesde': PropertySchema(
      id: 10,
      name: r'ocupadaDesde',
      type: IsarType.dateTime,
    ),
    r'ordenGrid': PropertySchema(
      id: 11,
      name: r'ordenGrid',
      type: IsarType.long,
    ),
    r'reservaId': PropertySchema(
      id: 12,
      name: r'reservaId',
      type: IsarType.long,
    ),
    r'sincronizado': PropertySchema(
      id: 13,
      name: r'sincronizado',
      type: IsarType.bool,
    ),
    r'supabaseId': PropertySchema(
      id: 14,
      name: r'supabaseId',
      type: IsarType.string,
    ),
    r'unidaConMesaId': PropertySchema(
      id: 15,
      name: r'unidaConMesaId',
      type: IsarType.long,
    ),
    r'updatedAt': PropertySchema(
      id: 16,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'zona': PropertySchema(
      id: 17,
      name: r'zona',
      type: IsarType.string,
      enumMap: _MesaEntityzonaEnumValueMap,
    )
  },
  estimateSize: _mesaEntityEstimateSize,
  serialize: _mesaEntitySerialize,
  deserialize: _mesaEntityDeserialize,
  deserializeProp: _mesaEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'localId': IndexSchema(
      id: 1199848425898359622,
      name: r'localId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'localId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'nombre': IndexSchema(
      id: -8239814765453414572,
      name: r'nombre',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'nombre',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'claveUnica': IndexSchema(
      id: 7303140198272169443,
      name: r'claveUnica',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'claveUnica',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _mesaEntityGetId,
  getLinks: _mesaEntityGetLinks,
  attach: _mesaEntityAttach,
  version: '3.1.0+1',
);

int _mesaEntityEstimateSize(
  MesaEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.claveUnica.length * 3;
  bytesCount += 3 + object.estado.name.length * 3;
  {
    final value = object.localSupabaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.nombre.length * 3;
  {
    final value = object.supabaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.zona.name.length * 3;
  return bytesCount;
}

void _mesaEntitySerialize(
  MesaEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.capacidad);
  writer.writeString(offsets[1], object.claveUnica);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeBool(offsets[3], object.disponibleParaComanda);
  writer.writeBool(offsets[4], object.estaUnida);
  writer.writeString(offsets[5], object.estado.name);
  writer.writeDateTime(offsets[6], object.fechaSincronizacion);
  writer.writeLong(offsets[7], object.localId);
  writer.writeString(offsets[8], object.localSupabaseId);
  writer.writeString(offsets[9], object.nombre);
  writer.writeDateTime(offsets[10], object.ocupadaDesde);
  writer.writeLong(offsets[11], object.ordenGrid);
  writer.writeLong(offsets[12], object.reservaId);
  writer.writeBool(offsets[13], object.sincronizado);
  writer.writeString(offsets[14], object.supabaseId);
  writer.writeLong(offsets[15], object.unidaConMesaId);
  writer.writeDateTime(offsets[16], object.updatedAt);
  writer.writeString(offsets[17], object.zona.name);
}

MesaEntity _mesaEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MesaEntity();
  object.capacidad = reader.readLong(offsets[0]);
  object.claveUnica = reader.readString(offsets[1]);
  object.createdAt = reader.readDateTimeOrNull(offsets[2]);
  object.estado =
      _MesaEntityestadoValueEnumMap[reader.readStringOrNull(offsets[5])] ??
          MesaEstado.libre;
  object.fechaSincronizacion = reader.readDateTimeOrNull(offsets[6]);
  object.id = id;
  object.localId = reader.readLong(offsets[7]);
  object.localSupabaseId = reader.readStringOrNull(offsets[8]);
  object.nombre = reader.readString(offsets[9]);
  object.ocupadaDesde = reader.readDateTimeOrNull(offsets[10]);
  object.ordenGrid = reader.readLong(offsets[11]);
  object.reservaId = reader.readLongOrNull(offsets[12]);
  object.sincronizado = reader.readBool(offsets[13]);
  object.supabaseId = reader.readStringOrNull(offsets[14]);
  object.unidaConMesaId = reader.readLongOrNull(offsets[15]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[16]);
  object.zona =
      _MesaEntityzonaValueEnumMap[reader.readStringOrNull(offsets[17])] ??
          MesaZona.salon;
  return object;
}

P _mesaEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (_MesaEntityestadoValueEnumMap[reader.readStringOrNull(offset)] ??
          MesaEstado.libre) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset)) as P;
    case 16:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 17:
      return (_MesaEntityzonaValueEnumMap[reader.readStringOrNull(offset)] ??
          MesaZona.salon) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _MesaEntityestadoEnumValueMap = {
  r'libre': r'libre',
  r'ocupada': r'ocupada',
  r'reservada': r'reservada',
  r'porLimpiar': r'porLimpiar',
};
const _MesaEntityestadoValueEnumMap = {
  r'libre': MesaEstado.libre,
  r'ocupada': MesaEstado.ocupada,
  r'reservada': MesaEstado.reservada,
  r'porLimpiar': MesaEstado.porLimpiar,
};
const _MesaEntityzonaEnumValueMap = {
  r'salon': r'salon',
  r'terraza': r'terraza',
  r'bar': r'bar',
  r'privado': r'privado',
  r'vip': r'vip',
};
const _MesaEntityzonaValueEnumMap = {
  r'salon': MesaZona.salon,
  r'terraza': MesaZona.terraza,
  r'bar': MesaZona.bar,
  r'privado': MesaZona.privado,
  r'vip': MesaZona.vip,
};

Id _mesaEntityGetId(MesaEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mesaEntityGetLinks(MesaEntity object) {
  return [];
}

void _mesaEntityAttach(IsarCollection<dynamic> col, Id id, MesaEntity object) {
  object.id = id;
}

extension MesaEntityByIndex on IsarCollection<MesaEntity> {
  Future<MesaEntity?> getByClaveUnica(String claveUnica) {
    return getByIndex(r'claveUnica', [claveUnica]);
  }

  MesaEntity? getByClaveUnicaSync(String claveUnica) {
    return getByIndexSync(r'claveUnica', [claveUnica]);
  }

  Future<bool> deleteByClaveUnica(String claveUnica) {
    return deleteByIndex(r'claveUnica', [claveUnica]);
  }

  bool deleteByClaveUnicaSync(String claveUnica) {
    return deleteByIndexSync(r'claveUnica', [claveUnica]);
  }

  Future<List<MesaEntity?>> getAllByClaveUnica(List<String> claveUnicaValues) {
    final values = claveUnicaValues.map((e) => [e]).toList();
    return getAllByIndex(r'claveUnica', values);
  }

  List<MesaEntity?> getAllByClaveUnicaSync(List<String> claveUnicaValues) {
    final values = claveUnicaValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'claveUnica', values);
  }

  Future<int> deleteAllByClaveUnica(List<String> claveUnicaValues) {
    final values = claveUnicaValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'claveUnica', values);
  }

  int deleteAllByClaveUnicaSync(List<String> claveUnicaValues) {
    final values = claveUnicaValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'claveUnica', values);
  }

  Future<Id> putByClaveUnica(MesaEntity object) {
    return putByIndex(r'claveUnica', object);
  }

  Id putByClaveUnicaSync(MesaEntity object, {bool saveLinks = true}) {
    return putByIndexSync(r'claveUnica', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByClaveUnica(List<MesaEntity> objects) {
    return putAllByIndex(r'claveUnica', objects);
  }

  List<Id> putAllByClaveUnicaSync(List<MesaEntity> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'claveUnica', objects, saveLinks: saveLinks);
  }
}

extension MesaEntityQueryWhereSort
    on QueryBuilder<MesaEntity, MesaEntity, QWhere> {
  QueryBuilder<MesaEntity, MesaEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhere> anyLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'localId'),
      );
    });
  }
}

extension MesaEntityQueryWhere
    on QueryBuilder<MesaEntity, MesaEntity, QWhereClause> {
  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> localIdEqualTo(
      int localId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'localId',
        value: [localId],
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> localIdNotEqualTo(
      int localId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localId',
              lower: [],
              upper: [localId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localId',
              lower: [localId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localId',
              lower: [localId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localId',
              lower: [],
              upper: [localId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> localIdGreaterThan(
    int localId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'localId',
        lower: [localId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> localIdLessThan(
    int localId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'localId',
        lower: [],
        upper: [localId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> localIdBetween(
    int lowerLocalId,
    int upperLocalId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'localId',
        lower: [lowerLocalId],
        includeLower: includeLower,
        upper: [upperLocalId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> nombreEqualTo(
      String nombre) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'nombre',
        value: [nombre],
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> nombreNotEqualTo(
      String nombre) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nombre',
              lower: [],
              upper: [nombre],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nombre',
              lower: [nombre],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nombre',
              lower: [nombre],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'nombre',
              lower: [],
              upper: [nombre],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> claveUnicaEqualTo(
      String claveUnica) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'claveUnica',
        value: [claveUnica],
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterWhereClause> claveUnicaNotEqualTo(
      String claveUnica) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'claveUnica',
              lower: [],
              upper: [claveUnica],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'claveUnica',
              lower: [claveUnica],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'claveUnica',
              lower: [claveUnica],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'claveUnica',
              lower: [],
              upper: [claveUnica],
              includeUpper: false,
            ));
      }
    });
  }
}

extension MesaEntityQueryFilter
    on QueryBuilder<MesaEntity, MesaEntity, QFilterCondition> {
  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> capacidadEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'capacidad',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      capacidadGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'capacidad',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> capacidadLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'capacidad',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> capacidadBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'capacidad',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> claveUnicaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'claveUnica',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      claveUnicaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'claveUnica',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      claveUnicaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'claveUnica',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> claveUnicaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'claveUnica',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      claveUnicaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'claveUnica',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      claveUnicaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'claveUnica',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      claveUnicaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'claveUnica',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> claveUnicaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'claveUnica',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      claveUnicaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'claveUnica',
        value: '',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      claveUnicaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'claveUnica',
        value: '',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> createdAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      disponibleParaComandaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disponibleParaComanda',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> estaUnidaEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estaUnida',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> estadoEqualTo(
    MesaEstado value, {
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> estadoGreaterThan(
    MesaEstado value, {
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> estadoLessThan(
    MesaEstado value, {
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> estadoBetween(
    MesaEstado lower,
    MesaEstado upper, {
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> estadoStartsWith(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> estadoEndsWith(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> estadoContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> estadoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'estado',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> estadoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      estadoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      fechaSincronizacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      fechaSincronizacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      fechaSincronizacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> localIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localId',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      localIdGreaterThan(
    int value, {
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> localIdLessThan(
    int value, {
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> localIdBetween(
    int lower,
    int upper, {
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      localSupabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localSupabaseId',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      localSupabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localSupabaseId',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      localSupabaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      localSupabaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      localSupabaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      localSupabaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localSupabaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      localSupabaseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'localSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      localSupabaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'localSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      localSupabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      localSupabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localSupabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      localSupabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      localSupabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> nombreEqualTo(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> nombreGreaterThan(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> nombreLessThan(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> nombreBetween(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> nombreStartsWith(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> nombreEndsWith(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> nombreContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> nombreMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      ocupadaDesdeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ocupadaDesde',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      ocupadaDesdeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ocupadaDesde',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      ocupadaDesdeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ocupadaDesde',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      ocupadaDesdeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ocupadaDesde',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      ocupadaDesdeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ocupadaDesde',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      ocupadaDesdeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ocupadaDesde',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> ordenGridEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ordenGrid',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      ordenGridGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ordenGrid',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> ordenGridLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ordenGrid',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> ordenGridBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ordenGrid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      reservaIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'reservaId',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      reservaIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'reservaId',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> reservaIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'reservaId',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      reservaIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'reservaId',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> reservaIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'reservaId',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> reservaIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'reservaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      sincronizadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sincronizado',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> supabaseIdEqualTo(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> supabaseIdBetween(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      supabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> supabaseIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      unidaConMesaIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'unidaConMesaId',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      unidaConMesaIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'unidaConMesaId',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      unidaConMesaIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unidaConMesaId',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      unidaConMesaIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unidaConMesaId',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      unidaConMesaIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unidaConMesaId',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      unidaConMesaIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unidaConMesaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> updatedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition>
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> updatedAtBetween(
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

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> zonaEqualTo(
    MesaZona value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zona',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> zonaGreaterThan(
    MesaZona value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'zona',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> zonaLessThan(
    MesaZona value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'zona',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> zonaBetween(
    MesaZona lower,
    MesaZona upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'zona',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> zonaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'zona',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> zonaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'zona',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> zonaContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'zona',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> zonaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'zona',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> zonaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'zona',
        value: '',
      ));
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterFilterCondition> zonaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'zona',
        value: '',
      ));
    });
  }
}

extension MesaEntityQueryObject
    on QueryBuilder<MesaEntity, MesaEntity, QFilterCondition> {}

extension MesaEntityQueryLinks
    on QueryBuilder<MesaEntity, MesaEntity, QFilterCondition> {}

extension MesaEntityQuerySortBy
    on QueryBuilder<MesaEntity, MesaEntity, QSortBy> {
  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByCapacidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capacidad', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByCapacidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capacidad', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByClaveUnica() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claveUnica', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByClaveUnicaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claveUnica', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy>
      sortByDisponibleParaComanda() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disponibleParaComanda', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy>
      sortByDisponibleParaComandaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disponibleParaComanda', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByEstaUnida() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estaUnida', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByEstaUnidaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estaUnida', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy>
      sortByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy>
      sortByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByLocalSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy>
      sortByLocalSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByOcupadaDesde() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocupadaDesde', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByOcupadaDesdeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocupadaDesde', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByOrdenGrid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ordenGrid', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByOrdenGridDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ordenGrid', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByReservaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reservaId', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByReservaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reservaId', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByUnidaConMesaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidaConMesaId', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy>
      sortByUnidaConMesaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidaConMesaId', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByZona() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zona', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> sortByZonaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zona', Sort.desc);
    });
  }
}

extension MesaEntityQuerySortThenBy
    on QueryBuilder<MesaEntity, MesaEntity, QSortThenBy> {
  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByCapacidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capacidad', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByCapacidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'capacidad', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByClaveUnica() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claveUnica', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByClaveUnicaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'claveUnica', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy>
      thenByDisponibleParaComanda() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disponibleParaComanda', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy>
      thenByDisponibleParaComandaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disponibleParaComanda', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByEstaUnida() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estaUnida', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByEstaUnidaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estaUnida', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy>
      thenByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy>
      thenByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByLocalSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy>
      thenByLocalSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByOcupadaDesde() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocupadaDesde', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByOcupadaDesdeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ocupadaDesde', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByOrdenGrid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ordenGrid', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByOrdenGridDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ordenGrid', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByReservaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reservaId', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByReservaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'reservaId', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByUnidaConMesaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidaConMesaId', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy>
      thenByUnidaConMesaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidaConMesaId', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByZona() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zona', Sort.asc);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QAfterSortBy> thenByZonaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zona', Sort.desc);
    });
  }
}

extension MesaEntityQueryWhereDistinct
    on QueryBuilder<MesaEntity, MesaEntity, QDistinct> {
  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByCapacidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'capacidad');
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByClaveUnica(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'claveUnica', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct>
      distinctByDisponibleParaComanda() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disponibleParaComanda');
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByEstaUnida() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estaUnida');
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByEstado(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct>
      distinctByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaSincronizacion');
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localId');
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByLocalSupabaseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localSupabaseId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByNombre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByOcupadaDesde() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ocupadaDesde');
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByOrdenGrid() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ordenGrid');
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByReservaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'reservaId');
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sincronizado');
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctBySupabaseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByUnidaConMesaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unidaConMesaId');
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<MesaEntity, MesaEntity, QDistinct> distinctByZona(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zona', caseSensitive: caseSensitive);
    });
  }
}

extension MesaEntityQueryProperty
    on QueryBuilder<MesaEntity, MesaEntity, QQueryProperty> {
  QueryBuilder<MesaEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MesaEntity, int, QQueryOperations> capacidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'capacidad');
    });
  }

  QueryBuilder<MesaEntity, String, QQueryOperations> claveUnicaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'claveUnica');
    });
  }

  QueryBuilder<MesaEntity, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MesaEntity, bool, QQueryOperations>
      disponibleParaComandaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disponibleParaComanda');
    });
  }

  QueryBuilder<MesaEntity, bool, QQueryOperations> estaUnidaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estaUnida');
    });
  }

  QueryBuilder<MesaEntity, MesaEstado, QQueryOperations> estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<MesaEntity, DateTime?, QQueryOperations>
      fechaSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaSincronizacion');
    });
  }

  QueryBuilder<MesaEntity, int, QQueryOperations> localIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localId');
    });
  }

  QueryBuilder<MesaEntity, String?, QQueryOperations>
      localSupabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localSupabaseId');
    });
  }

  QueryBuilder<MesaEntity, String, QQueryOperations> nombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombre');
    });
  }

  QueryBuilder<MesaEntity, DateTime?, QQueryOperations> ocupadaDesdeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ocupadaDesde');
    });
  }

  QueryBuilder<MesaEntity, int, QQueryOperations> ordenGridProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ordenGrid');
    });
  }

  QueryBuilder<MesaEntity, int?, QQueryOperations> reservaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'reservaId');
    });
  }

  QueryBuilder<MesaEntity, bool, QQueryOperations> sincronizadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sincronizado');
    });
  }

  QueryBuilder<MesaEntity, String?, QQueryOperations> supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<MesaEntity, int?, QQueryOperations> unidaConMesaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unidaConMesaId');
    });
  }

  QueryBuilder<MesaEntity, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<MesaEntity, MesaZona, QQueryOperations> zonaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zona');
    });
  }
}
