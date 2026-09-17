// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_descuento_mayorista_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetConfigDescuentoMayoristaEntityCollection on Isar {
  IsarCollection<ConfigDescuentoMayoristaEntity>
      get configDescuentoMayoristaEntitys => this.collection();
}

const ConfigDescuentoMayoristaEntitySchema = CollectionSchema(
  name: r'ConfigDescuentoMayoristaEntity',
  id: -2203653140620421283,
  properties: {
    r'activo': PropertySchema(
      id: 0,
      name: r'activo',
      type: IsarType.bool,
    ),
    r'cantidadMaxima': PropertySchema(
      id: 1,
      name: r'cantidadMaxima',
      type: IsarType.long,
    ),
    r'cantidadMinima': PropertySchema(
      id: 2,
      name: r'cantidadMinima',
      type: IsarType.long,
    ),
    r'categoriaIdIsar': PropertySchema(
      id: 3,
      name: r'categoriaIdIsar',
      type: IsarType.long,
    ),
    r'categoriaSupabaseId': PropertySchema(
      id: 4,
      name: r'categoriaSupabaseId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'descuentoPorcentaje': PropertySchema(
      id: 6,
      name: r'descuentoPorcentaje',
      type: IsarType.double,
    ),
    r'nombre': PropertySchema(
      id: 7,
      name: r'nombre',
      type: IsarType.string,
    ),
    r'requiereAutorizacion': PropertySchema(
      id: 8,
      name: r'requiereAutorizacion',
      type: IsarType.bool,
    ),
    r'supabaseId': PropertySchema(
      id: 9,
      name: r'supabaseId',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 10,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'tenantId': PropertySchema(
      id: 11,
      name: r'tenantId',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 12,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _configDescuentoMayoristaEntityEstimateSize,
  serialize: _configDescuentoMayoristaEntitySerialize,
  deserialize: _configDescuentoMayoristaEntityDeserialize,
  deserializeProp: _configDescuentoMayoristaEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'supabaseId': IndexSchema(
      id: 2753382765909358918,
      name: r'supabaseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'supabaseId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'tenantId': IndexSchema(
      id: -1042425927805315167,
      name: r'tenantId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tenantId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _configDescuentoMayoristaEntityGetId,
  getLinks: _configDescuentoMayoristaEntityGetLinks,
  attach: _configDescuentoMayoristaEntityAttach,
  version: '3.1.0+1',
);

int _configDescuentoMayoristaEntityEstimateSize(
  ConfigDescuentoMayoristaEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.categoriaSupabaseId;
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
  bytesCount += 3 + object.syncStatus.length * 3;
  {
    final value = object.tenantId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _configDescuentoMayoristaEntitySerialize(
  ConfigDescuentoMayoristaEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.activo);
  writer.writeLong(offsets[1], object.cantidadMaxima);
  writer.writeLong(offsets[2], object.cantidadMinima);
  writer.writeLong(offsets[3], object.categoriaIdIsar);
  writer.writeString(offsets[4], object.categoriaSupabaseId);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeDouble(offsets[6], object.descuentoPorcentaje);
  writer.writeString(offsets[7], object.nombre);
  writer.writeBool(offsets[8], object.requiereAutorizacion);
  writer.writeString(offsets[9], object.supabaseId);
  writer.writeString(offsets[10], object.syncStatus);
  writer.writeString(offsets[11], object.tenantId);
  writer.writeDateTime(offsets[12], object.updatedAt);
}

ConfigDescuentoMayoristaEntity _configDescuentoMayoristaEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ConfigDescuentoMayoristaEntity();
  object.activo = reader.readBool(offsets[0]);
  object.cantidadMaxima = reader.readLongOrNull(offsets[1]);
  object.cantidadMinima = reader.readLong(offsets[2]);
  object.categoriaIdIsar = reader.readLongOrNull(offsets[3]);
  object.categoriaSupabaseId = reader.readStringOrNull(offsets[4]);
  object.createdAt = reader.readDateTime(offsets[5]);
  object.descuentoPorcentaje = reader.readDouble(offsets[6]);
  object.id = id;
  object.nombre = reader.readString(offsets[7]);
  object.requiereAutorizacion = reader.readBool(offsets[8]);
  object.supabaseId = reader.readStringOrNull(offsets[9]);
  object.syncStatus = reader.readString(offsets[10]);
  object.tenantId = reader.readStringOrNull(offsets[11]);
  object.updatedAt = reader.readDateTime(offsets[12]);
  return object;
}

P _configDescuentoMayoristaEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _configDescuentoMayoristaEntityGetId(ConfigDescuentoMayoristaEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _configDescuentoMayoristaEntityGetLinks(
    ConfigDescuentoMayoristaEntity object) {
  return [];
}

void _configDescuentoMayoristaEntityAttach(
    IsarCollection<dynamic> col, Id id, ConfigDescuentoMayoristaEntity object) {
  object.id = id;
}

extension ConfigDescuentoMayoristaEntityQueryWhereSort on QueryBuilder<
    ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity, QWhere> {
  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ConfigDescuentoMayoristaEntityQueryWhere on QueryBuilder<
    ConfigDescuentoMayoristaEntity,
    ConfigDescuentoMayoristaEntity,
    QWhereClause> {
  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhereClause> supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'supabaseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhereClause> supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'supabaseId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhereClause> supabaseIdEqualTo(String? supabaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'supabaseId',
        value: [supabaseId],
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhereClause> supabaseIdNotEqualTo(String? supabaseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supabaseId',
              lower: [],
              upper: [supabaseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supabaseId',
              lower: [supabaseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supabaseId',
              lower: [supabaseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supabaseId',
              lower: [],
              upper: [supabaseId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhereClause> tenantIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tenantId',
        value: [null],
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhereClause> tenantIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tenantId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhereClause> tenantIdEqualTo(String? tenantId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tenantId',
        value: [tenantId],
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterWhereClause> tenantIdNotEqualTo(String? tenantId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tenantId',
              lower: [],
              upper: [tenantId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tenantId',
              lower: [tenantId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tenantId',
              lower: [tenantId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tenantId',
              lower: [],
              upper: [tenantId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ConfigDescuentoMayoristaEntityQueryFilter on QueryBuilder<
    ConfigDescuentoMayoristaEntity,
    ConfigDescuentoMayoristaEntity,
    QFilterCondition> {
  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> activoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activo',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> cantidadMaximaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'cantidadMaxima',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> cantidadMaximaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'cantidadMaxima',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> cantidadMaximaEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidadMaxima',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> cantidadMaximaGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cantidadMaxima',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> cantidadMaximaLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cantidadMaxima',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> cantidadMaximaBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cantidadMaxima',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> cantidadMinimaEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidadMinima',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> cantidadMinimaGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cantidadMinima',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> cantidadMinimaLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cantidadMinima',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> cantidadMinimaBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cantidadMinima',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaIdIsarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'categoriaIdIsar',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaIdIsarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'categoriaIdIsar',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaIdIsarEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoriaIdIsar',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaIdIsarGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoriaIdIsar',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaIdIsarLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoriaIdIsar',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaIdIsarBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoriaIdIsar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaSupabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'categoriaSupabaseId',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaSupabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'categoriaSupabaseId',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaSupabaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoriaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaSupabaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'categoriaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaSupabaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'categoriaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaSupabaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'categoriaSupabaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaSupabaseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'categoriaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaSupabaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'categoriaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
          QAfterFilterCondition>
      categoriaSupabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'categoriaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
          QAfterFilterCondition>
      categoriaSupabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'categoriaSupabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaSupabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'categoriaSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> categoriaSupabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'categoriaSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> descuentoPorcentajeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descuentoPorcentaje',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> descuentoPorcentajeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descuentoPorcentaje',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> descuentoPorcentajeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descuentoPorcentaje',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> descuentoPorcentajeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descuentoPorcentaje',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> nombreEqualTo(
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> nombreGreaterThan(
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> nombreLessThan(
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> nombreBetween(
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> nombreStartsWith(
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> nombreEndsWith(
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
          QAfterFilterCondition>
      nombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
          QAfterFilterCondition>
      nombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> requiereAutorizacionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requiereAutorizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> syncStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> syncStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> syncStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> syncStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> syncStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> syncStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
          QAfterFilterCondition>
      syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
          QAfterFilterCondition>
      syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> tenantIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tenantId',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> tenantIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tenantId',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> tenantIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> tenantIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> tenantIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> tenantIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tenantId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> tenantIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> tenantIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
          QAfterFilterCondition>
      tenantIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
          QAfterFilterCondition>
      tenantIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tenantId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> tenantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> tenantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterFilterCondition> updatedAtBetween(
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
}

extension ConfigDescuentoMayoristaEntityQueryObject on QueryBuilder<
    ConfigDescuentoMayoristaEntity,
    ConfigDescuentoMayoristaEntity,
    QFilterCondition> {}

extension ConfigDescuentoMayoristaEntityQueryLinks on QueryBuilder<
    ConfigDescuentoMayoristaEntity,
    ConfigDescuentoMayoristaEntity,
    QFilterCondition> {}

extension ConfigDescuentoMayoristaEntityQuerySortBy on QueryBuilder<
    ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity, QSortBy> {
  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByCantidadMaxima() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadMaxima', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByCantidadMaximaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadMaxima', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByCantidadMinima() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadMinima', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByCantidadMinimaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadMinima', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByCategoriaIdIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaIdIsar', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByCategoriaIdIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaIdIsar', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByCategoriaSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByCategoriaSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByDescuentoPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoPorcentaje', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByDescuentoPorcentajeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoPorcentaje', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByRequiereAutorizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiereAutorizacion', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByRequiereAutorizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiereAutorizacion', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ConfigDescuentoMayoristaEntityQuerySortThenBy on QueryBuilder<
    ConfigDescuentoMayoristaEntity,
    ConfigDescuentoMayoristaEntity,
    QSortThenBy> {
  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByCantidadMaxima() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadMaxima', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByCantidadMaximaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadMaxima', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByCantidadMinima() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadMinima', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByCantidadMinimaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadMinima', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByCategoriaIdIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaIdIsar', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByCategoriaIdIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaIdIsar', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByCategoriaSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByCategoriaSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'categoriaSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByDescuentoPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoPorcentaje', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByDescuentoPorcentajeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoPorcentaje', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByRequiereAutorizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiereAutorizacion', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByRequiereAutorizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiereAutorizacion', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ConfigDescuentoMayoristaEntityQueryWhereDistinct on QueryBuilder<
    ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity, QDistinct> {
  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QDistinct> distinctByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activo');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QDistinct> distinctByCantidadMaxima() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidadMaxima');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QDistinct> distinctByCantidadMinima() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidadMinima');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QDistinct> distinctByCategoriaIdIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoriaIdIsar');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QDistinct> distinctByCategoriaSupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'categoriaSupabaseId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QDistinct> distinctByDescuentoPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descuentoPorcentaje');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QDistinct> distinctByNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QDistinct> distinctByRequiereAutorizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requiereAutorizacion');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QDistinct> distinctBySupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QDistinct> distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QDistinct> distinctByTenantId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tenantId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, ConfigDescuentoMayoristaEntity,
      QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ConfigDescuentoMayoristaEntityQueryProperty on QueryBuilder<
    ConfigDescuentoMayoristaEntity,
    ConfigDescuentoMayoristaEntity,
    QQueryProperty> {
  QueryBuilder<ConfigDescuentoMayoristaEntity, int, QQueryOperations>
      idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, bool, QQueryOperations>
      activoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activo');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, int?, QQueryOperations>
      cantidadMaximaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidadMaxima');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, int, QQueryOperations>
      cantidadMinimaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidadMinima');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, int?, QQueryOperations>
      categoriaIdIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoriaIdIsar');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, String?, QQueryOperations>
      categoriaSupabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'categoriaSupabaseId');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, double, QQueryOperations>
      descuentoPorcentajeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descuentoPorcentaje');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, String, QQueryOperations>
      nombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombre');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, bool, QQueryOperations>
      requiereAutorizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requiereAutorizacion');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, String?, QQueryOperations>
      supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, String, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, String?, QQueryOperations>
      tenantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tenantId');
    });
  }

  QueryBuilder<ConfigDescuentoMayoristaEntity, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
