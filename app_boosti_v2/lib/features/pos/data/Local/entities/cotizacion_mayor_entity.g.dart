// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cotizacion_mayor_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCotizacionMayorEntityCollection on Isar {
  IsarCollection<CotizacionMayorEntity> get cotizacionMayorEntitys =>
      this.collection();
}

const CotizacionMayorEntitySchema = CollectionSchema(
  name: r'CotizacionMayorEntity',
  id: -636120279524532429,
  properties: {
    r'clienteId': PropertySchema(
      id: 0,
      name: r'clienteId',
      type: IsarType.long,
    ),
    r'clienteNombre': PropertySchema(
      id: 1,
      name: r'clienteNombre',
      type: IsarType.string,
    ),
    r'clienteRazonSocial': PropertySchema(
      id: 2,
      name: r'clienteRazonSocial',
      type: IsarType.string,
    ),
    r'clienteRif': PropertySchema(
      id: 3,
      name: r'clienteRif',
      type: IsarType.string,
    ),
    r'clienteSupabaseId': PropertySchema(
      id: 4,
      name: r'clienteSupabaseId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 5,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'descuentoGlobal': PropertySchema(
      id: 6,
      name: r'descuentoGlobal',
      type: IsarType.double,
    ),
    r'estado': PropertySchema(
      id: 7,
      name: r'estado',
      type: IsarType.string,
    ),
    r'fechaEmision': PropertySchema(
      id: 8,
      name: r'fechaEmision',
      type: IsarType.dateTime,
    ),
    r'fechaVencimiento': PropertySchema(
      id: 9,
      name: r'fechaVencimiento',
      type: IsarType.dateTime,
    ),
    r'impuesto': PropertySchema(
      id: 10,
      name: r'impuesto',
      type: IsarType.double,
    ),
    r'itemsJson': PropertySchema(
      id: 11,
      name: r'itemsJson',
      type: IsarType.string,
    ),
    r'numero': PropertySchema(
      id: 12,
      name: r'numero',
      type: IsarType.string,
    ),
    r'observaciones': PropertySchema(
      id: 13,
      name: r'observaciones',
      type: IsarType.string,
    ),
    r'subtotal': PropertySchema(
      id: 14,
      name: r'subtotal',
      type: IsarType.double,
    ),
    r'supabaseId': PropertySchema(
      id: 15,
      name: r'supabaseId',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 16,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'tasaBcv': PropertySchema(
      id: 17,
      name: r'tasaBcv',
      type: IsarType.double,
    ),
    r'tenantId': PropertySchema(
      id: 18,
      name: r'tenantId',
      type: IsarType.string,
    ),
    r'total': PropertySchema(
      id: 19,
      name: r'total',
      type: IsarType.double,
    ),
    r'totalBolivares': PropertySchema(
      id: 20,
      name: r'totalBolivares',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 21,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'usuarioId': PropertySchema(
      id: 22,
      name: r'usuarioId',
      type: IsarType.long,
    ),
    r'usuarioNombre': PropertySchema(
      id: 23,
      name: r'usuarioNombre',
      type: IsarType.string,
    ),
    r'ventaConvertidaId': PropertySchema(
      id: 24,
      name: r'ventaConvertidaId',
      type: IsarType.string,
    )
  },
  estimateSize: _cotizacionMayorEntityEstimateSize,
  serialize: _cotizacionMayorEntitySerialize,
  deserialize: _cotizacionMayorEntityDeserialize,
  deserializeProp: _cotizacionMayorEntityDeserializeProp,
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
    ),
    r'numero': IndexSchema(
      id: -2487710741234600426,
      name: r'numero',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'numero',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'estado': IndexSchema(
      id: -4800696143246816208,
      name: r'estado',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'estado',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _cotizacionMayorEntityGetId,
  getLinks: _cotizacionMayorEntityGetLinks,
  attach: _cotizacionMayorEntityAttach,
  version: '3.1.0+1',
);

int _cotizacionMayorEntityEstimateSize(
  CotizacionMayorEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.clienteNombre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.clienteRazonSocial;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.clienteRif;
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
  bytesCount += 3 + object.estado.length * 3;
  bytesCount += 3 + object.itemsJson.length * 3;
  bytesCount += 3 + object.numero.length * 3;
  {
    final value = object.observaciones;
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
  bytesCount += 3 + object.syncStatus.length * 3;
  {
    final value = object.tenantId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.usuarioNombre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ventaConvertidaId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _cotizacionMayorEntitySerialize(
  CotizacionMayorEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.clienteId);
  writer.writeString(offsets[1], object.clienteNombre);
  writer.writeString(offsets[2], object.clienteRazonSocial);
  writer.writeString(offsets[3], object.clienteRif);
  writer.writeString(offsets[4], object.clienteSupabaseId);
  writer.writeDateTime(offsets[5], object.createdAt);
  writer.writeDouble(offsets[6], object.descuentoGlobal);
  writer.writeString(offsets[7], object.estado);
  writer.writeDateTime(offsets[8], object.fechaEmision);
  writer.writeDateTime(offsets[9], object.fechaVencimiento);
  writer.writeDouble(offsets[10], object.impuesto);
  writer.writeString(offsets[11], object.itemsJson);
  writer.writeString(offsets[12], object.numero);
  writer.writeString(offsets[13], object.observaciones);
  writer.writeDouble(offsets[14], object.subtotal);
  writer.writeString(offsets[15], object.supabaseId);
  writer.writeString(offsets[16], object.syncStatus);
  writer.writeDouble(offsets[17], object.tasaBcv);
  writer.writeString(offsets[18], object.tenantId);
  writer.writeDouble(offsets[19], object.total);
  writer.writeDouble(offsets[20], object.totalBolivares);
  writer.writeDateTime(offsets[21], object.updatedAt);
  writer.writeLong(offsets[22], object.usuarioId);
  writer.writeString(offsets[23], object.usuarioNombre);
  writer.writeString(offsets[24], object.ventaConvertidaId);
}

CotizacionMayorEntity _cotizacionMayorEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CotizacionMayorEntity();
  object.clienteId = reader.readLongOrNull(offsets[0]);
  object.clienteNombre = reader.readStringOrNull(offsets[1]);
  object.clienteRazonSocial = reader.readStringOrNull(offsets[2]);
  object.clienteRif = reader.readStringOrNull(offsets[3]);
  object.clienteSupabaseId = reader.readStringOrNull(offsets[4]);
  object.createdAt = reader.readDateTimeOrNull(offsets[5]);
  object.descuentoGlobal = reader.readDouble(offsets[6]);
  object.estado = reader.readString(offsets[7]);
  object.fechaEmision = reader.readDateTime(offsets[8]);
  object.fechaVencimiento = reader.readDateTimeOrNull(offsets[9]);
  object.id = id;
  object.impuesto = reader.readDouble(offsets[10]);
  object.itemsJson = reader.readString(offsets[11]);
  object.numero = reader.readString(offsets[12]);
  object.observaciones = reader.readStringOrNull(offsets[13]);
  object.subtotal = reader.readDouble(offsets[14]);
  object.supabaseId = reader.readStringOrNull(offsets[15]);
  object.syncStatus = reader.readString(offsets[16]);
  object.tasaBcv = reader.readDoubleOrNull(offsets[17]);
  object.tenantId = reader.readStringOrNull(offsets[18]);
  object.total = reader.readDouble(offsets[19]);
  object.totalBolivares = reader.readDouble(offsets[20]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[21]);
  object.usuarioId = reader.readLongOrNull(offsets[22]);
  object.usuarioNombre = reader.readStringOrNull(offsets[23]);
  object.ventaConvertidaId = reader.readStringOrNull(offsets[24]);
  return object;
}

P _cotizacionMayorEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readDoubleOrNull(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readDouble(offset)) as P;
    case 20:
      return (reader.readDouble(offset)) as P;
    case 21:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 22:
      return (reader.readLongOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _cotizacionMayorEntityGetId(CotizacionMayorEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _cotizacionMayorEntityGetLinks(
    CotizacionMayorEntity object) {
  return [];
}

void _cotizacionMayorEntityAttach(
    IsarCollection<dynamic> col, Id id, CotizacionMayorEntity object) {
  object.id = id;
}

extension CotizacionMayorEntityQueryWhereSort
    on QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QWhere> {
  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CotizacionMayorEntityQueryWhere on QueryBuilder<CotizacionMayorEntity,
    CotizacionMayorEntity, QWhereClause> {
  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'supabaseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'supabaseId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      supabaseIdEqualTo(String? supabaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'supabaseId',
        value: [supabaseId],
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      supabaseIdNotEqualTo(String? supabaseId) {
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      tenantIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tenantId',
        value: [null],
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      tenantIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'tenantId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      tenantIdEqualTo(String? tenantId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tenantId',
        value: [tenantId],
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      tenantIdNotEqualTo(String? tenantId) {
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      numeroEqualTo(String numero) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'numero',
        value: [numero],
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      numeroNotEqualTo(String numero) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'numero',
              lower: [],
              upper: [numero],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'numero',
              lower: [numero],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'numero',
              lower: [numero],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'numero',
              lower: [],
              upper: [numero],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      estadoEqualTo(String estado) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'estado',
        value: [estado],
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterWhereClause>
      estadoNotEqualTo(String estado) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [],
              upper: [estado],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [estado],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [estado],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'estado',
              lower: [],
              upper: [estado],
              includeUpper: false,
            ));
      }
    });
  }
}

extension CotizacionMayorEntityQueryFilter on QueryBuilder<
    CotizacionMayorEntity, CotizacionMayorEntity, QFilterCondition> {
  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteId',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteId',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteId',
        value: value,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clienteId',
        value: value,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clienteId',
        value: value,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clienteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteNombreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteNombre',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteNombreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteNombre',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteNombreEqualTo(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteNombreGreaterThan(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteNombreLessThan(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteNombreBetween(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteNombreStartsWith(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteNombreEndsWith(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      clienteNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clienteNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      clienteNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clienteNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clienteNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRazonSocialIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteRazonSocial',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRazonSocialIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteRazonSocial',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRazonSocialEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteRazonSocial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRazonSocialGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clienteRazonSocial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRazonSocialLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clienteRazonSocial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRazonSocialBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clienteRazonSocial',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRazonSocialStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clienteRazonSocial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRazonSocialEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clienteRazonSocial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      clienteRazonSocialContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clienteRazonSocial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      clienteRazonSocialMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clienteRazonSocial',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRazonSocialIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteRazonSocial',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRazonSocialIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clienteRazonSocial',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRifIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteRif',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRifIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteRif',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRifEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteRif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRifGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'clienteRif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRifLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'clienteRif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRifBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'clienteRif',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRifStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'clienteRif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRifEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'clienteRif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      clienteRifContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clienteRif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      clienteRifMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clienteRif',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRifIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteRif',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteRifIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clienteRif',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteSupabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteSupabaseId',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteSupabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteSupabaseId',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteSupabaseIdEqualTo(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteSupabaseIdGreaterThan(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteSupabaseIdLessThan(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteSupabaseIdBetween(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteSupabaseIdStartsWith(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteSupabaseIdEndsWith(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      clienteSupabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clienteSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      clienteSupabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clienteSupabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteSupabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> clienteSupabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clienteSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> descuentoGlobalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descuentoGlobal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> descuentoGlobalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descuentoGlobal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> descuentoGlobalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descuentoGlobal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> descuentoGlobalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descuentoGlobal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> estadoEqualTo(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> estadoGreaterThan(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> estadoLessThan(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> estadoBetween(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> estadoStartsWith(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> estadoEndsWith(
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      estadoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      estadoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'estado',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> estadoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> estadoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> fechaEmisionEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaEmision',
        value: value,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> fechaEmisionGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaEmision',
        value: value,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> fechaEmisionLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaEmision',
        value: value,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> fechaEmisionBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaEmision',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> fechaVencimientoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaVencimiento',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> fechaVencimientoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaVencimiento',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> fechaVencimientoEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaVencimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> fechaVencimientoGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaVencimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> fechaVencimientoLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaVencimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> fechaVencimientoBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaVencimiento',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> impuestoEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'impuesto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> impuestoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'impuesto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> impuestoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'impuesto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> impuestoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'impuesto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> itemsJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> itemsJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> itemsJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> itemsJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'itemsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> itemsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> itemsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      itemsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'itemsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      itemsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'itemsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> itemsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'itemsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> itemsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'itemsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> numeroEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numero',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> numeroGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'numero',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> numeroLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'numero',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> numeroBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'numero',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> numeroStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'numero',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> numeroEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'numero',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      numeroContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'numero',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      numeroMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'numero',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> numeroIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'numero',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> numeroIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'numero',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> observacionesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'observaciones',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> observacionesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'observaciones',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> observacionesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> observacionesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> observacionesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> observacionesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'observaciones',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> observacionesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> observacionesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      observacionesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      observacionesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'observaciones',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> observacionesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'observaciones',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> observacionesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'observaciones',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> subtotalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> subtotalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> subtotalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'subtotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> subtotalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'subtotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> tasaBcvIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tasaBcv',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> tasaBcvIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tasaBcv',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> tasaBcvEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tasaBcv',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> tasaBcvGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tasaBcv',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> tasaBcvLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tasaBcv',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> tasaBcvBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tasaBcv',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> tenantIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tenantId',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> tenantIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tenantId',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> tenantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> tenantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> totalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> totalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> totalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'total',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> totalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'total',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> totalBolivaresEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalBolivares',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> totalBolivaresGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalBolivares',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> totalBolivaresLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalBolivares',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> totalBolivaresBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalBolivares',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> usuarioIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usuarioId',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> usuarioIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usuarioId',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> usuarioIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
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

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> usuarioNombreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'usuarioNombre',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> usuarioNombreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'usuarioNombre',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> usuarioNombreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> usuarioNombreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> usuarioNombreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> usuarioNombreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usuarioNombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> usuarioNombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> usuarioNombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      usuarioNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      usuarioNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> usuarioNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> usuarioNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> ventaConvertidaIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ventaConvertidaId',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> ventaConvertidaIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ventaConvertidaId',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> ventaConvertidaIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaConvertidaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> ventaConvertidaIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ventaConvertidaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> ventaConvertidaIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ventaConvertidaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> ventaConvertidaIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ventaConvertidaId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> ventaConvertidaIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ventaConvertidaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> ventaConvertidaIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ventaConvertidaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      ventaConvertidaIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ventaConvertidaId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
          QAfterFilterCondition>
      ventaConvertidaIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ventaConvertidaId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> ventaConvertidaIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaConvertidaId',
        value: '',
      ));
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity,
      QAfterFilterCondition> ventaConvertidaIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ventaConvertidaId',
        value: '',
      ));
    });
  }
}

extension CotizacionMayorEntityQueryObject on QueryBuilder<
    CotizacionMayorEntity, CotizacionMayorEntity, QFilterCondition> {}

extension CotizacionMayorEntityQueryLinks on QueryBuilder<CotizacionMayorEntity,
    CotizacionMayorEntity, QFilterCondition> {}

extension CotizacionMayorEntityQuerySortBy
    on QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QSortBy> {
  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByClienteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByClienteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByClienteNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNombre', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByClienteNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNombre', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByClienteRazonSocial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRazonSocial', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByClienteRazonSocialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRazonSocial', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByClienteRif() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRif', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByClienteRifDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRif', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByClienteSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByClienteSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByDescuentoGlobal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoGlobal', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByDescuentoGlobalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoGlobal', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByFechaEmision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEmision', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByFechaEmisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEmision', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByFechaVencimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVencimiento', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByFechaVencimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVencimiento', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByImpuesto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'impuesto', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByImpuestoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'impuesto', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByItemsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsJson', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByItemsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsJson', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByNumero() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numero', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByNumeroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numero', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByObservaciones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByObservacionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByTasaBcv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByTasaBcvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByTotalBolivares() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBolivares', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByTotalBolivaresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBolivares', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByUsuarioNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByUsuarioNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByVentaConvertidaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaConvertidaId', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      sortByVentaConvertidaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaConvertidaId', Sort.desc);
    });
  }
}

extension CotizacionMayorEntityQuerySortThenBy
    on QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QSortThenBy> {
  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByClienteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByClienteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByClienteNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNombre', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByClienteNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNombre', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByClienteRazonSocial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRazonSocial', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByClienteRazonSocialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRazonSocial', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByClienteRif() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRif', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByClienteRifDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRif', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByClienteSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByClienteSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByDescuentoGlobal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoGlobal', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByDescuentoGlobalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoGlobal', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByFechaEmision() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEmision', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByFechaEmisionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaEmision', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByFechaVencimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVencimiento', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByFechaVencimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVencimiento', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByImpuesto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'impuesto', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByImpuestoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'impuesto', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByItemsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsJson', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByItemsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'itemsJson', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByNumero() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numero', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByNumeroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'numero', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByObservaciones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByObservacionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByTasaBcv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByTasaBcvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByTotalBolivares() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBolivares', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByTotalBolivaresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBolivares', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByUsuarioNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByUsuarioNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.desc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByVentaConvertidaId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaConvertidaId', Sort.asc);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QAfterSortBy>
      thenByVentaConvertidaIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaConvertidaId', Sort.desc);
    });
  }
}

extension CotizacionMayorEntityQueryWhereDistinct
    on QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct> {
  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByClienteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteId');
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByClienteNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByClienteRazonSocial({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteRazonSocial',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByClienteRif({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteRif', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByClienteSupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteSupabaseId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByDescuentoGlobal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descuentoGlobal');
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByEstado({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByFechaEmision() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaEmision');
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByFechaVencimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaVencimiento');
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByImpuesto() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'impuesto');
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByItemsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'itemsJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByNumero({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'numero', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByObservaciones({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'observaciones',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtotal');
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctBySupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByTasaBcv() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tasaBcv');
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByTenantId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tenantId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByTotalBolivares() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalBolivares');
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioId');
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByUsuarioNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CotizacionMayorEntity, CotizacionMayorEntity, QDistinct>
      distinctByVentaConvertidaId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ventaConvertidaId',
          caseSensitive: caseSensitive);
    });
  }
}

extension CotizacionMayorEntityQueryProperty on QueryBuilder<
    CotizacionMayorEntity, CotizacionMayorEntity, QQueryProperty> {
  QueryBuilder<CotizacionMayorEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CotizacionMayorEntity, int?, QQueryOperations>
      clienteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteId');
    });
  }

  QueryBuilder<CotizacionMayorEntity, String?, QQueryOperations>
      clienteNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteNombre');
    });
  }

  QueryBuilder<CotizacionMayorEntity, String?, QQueryOperations>
      clienteRazonSocialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteRazonSocial');
    });
  }

  QueryBuilder<CotizacionMayorEntity, String?, QQueryOperations>
      clienteRifProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteRif');
    });
  }

  QueryBuilder<CotizacionMayorEntity, String?, QQueryOperations>
      clienteSupabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteSupabaseId');
    });
  }

  QueryBuilder<CotizacionMayorEntity, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CotizacionMayorEntity, double, QQueryOperations>
      descuentoGlobalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descuentoGlobal');
    });
  }

  QueryBuilder<CotizacionMayorEntity, String, QQueryOperations>
      estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<CotizacionMayorEntity, DateTime, QQueryOperations>
      fechaEmisionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaEmision');
    });
  }

  QueryBuilder<CotizacionMayorEntity, DateTime?, QQueryOperations>
      fechaVencimientoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaVencimiento');
    });
  }

  QueryBuilder<CotizacionMayorEntity, double, QQueryOperations>
      impuestoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'impuesto');
    });
  }

  QueryBuilder<CotizacionMayorEntity, String, QQueryOperations>
      itemsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'itemsJson');
    });
  }

  QueryBuilder<CotizacionMayorEntity, String, QQueryOperations>
      numeroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'numero');
    });
  }

  QueryBuilder<CotizacionMayorEntity, String?, QQueryOperations>
      observacionesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'observaciones');
    });
  }

  QueryBuilder<CotizacionMayorEntity, double, QQueryOperations>
      subtotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtotal');
    });
  }

  QueryBuilder<CotizacionMayorEntity, String?, QQueryOperations>
      supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<CotizacionMayorEntity, String, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<CotizacionMayorEntity, double?, QQueryOperations>
      tasaBcvProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tasaBcv');
    });
  }

  QueryBuilder<CotizacionMayorEntity, String?, QQueryOperations>
      tenantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tenantId');
    });
  }

  QueryBuilder<CotizacionMayorEntity, double, QQueryOperations>
      totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }

  QueryBuilder<CotizacionMayorEntity, double, QQueryOperations>
      totalBolivaresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalBolivares');
    });
  }

  QueryBuilder<CotizacionMayorEntity, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<CotizacionMayorEntity, int?, QQueryOperations>
      usuarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioId');
    });
  }

  QueryBuilder<CotizacionMayorEntity, String?, QQueryOperations>
      usuarioNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioNombre');
    });
  }

  QueryBuilder<CotizacionMayorEntity, String?, QQueryOperations>
      ventaConvertidaIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ventaConvertidaId');
    });
  }
}
