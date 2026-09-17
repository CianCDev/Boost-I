// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pago_venta_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPagoVentaEntityCollection on Isar {
  IsarCollection<PagoVentaEntity> get pagoVentaEntitys => this.collection();
}

const PagoVentaEntitySchema = CollectionSchema(
  name: r'PagoVentaEntity',
  id: -6534163529066025589,
  properties: {
    r'bancoEmisor': PropertySchema(
      id: 0,
      name: r'bancoEmisor',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'fecha': PropertySchema(
      id: 2,
      name: r'fecha',
      type: IsarType.dateTime,
    ),
    r'hashTransaccion': PropertySchema(
      id: 3,
      name: r'hashTransaccion',
      type: IsarType.string,
    ),
    r'idIsar': PropertySchema(
      id: 4,
      name: r'idIsar',
      type: IsarType.long,
    ),
    r'metodo': PropertySchema(
      id: 5,
      name: r'metodo',
      type: IsarType.string,
    ),
    r'moneda': PropertySchema(
      id: 6,
      name: r'moneda',
      type: IsarType.string,
    ),
    r'monto': PropertySchema(
      id: 7,
      name: r'monto',
      type: IsarType.double,
    ),
    r'montoUsdEquivalente': PropertySchema(
      id: 8,
      name: r'montoUsdEquivalente',
      type: IsarType.double,
    ),
    r'redCripto': PropertySchema(
      id: 9,
      name: r'redCripto',
      type: IsarType.string,
    ),
    r'referencia': PropertySchema(
      id: 10,
      name: r'referencia',
      type: IsarType.string,
    ),
    r'supabaseId': PropertySchema(
      id: 11,
      name: r'supabaseId',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 12,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'tasaBcv': PropertySchema(
      id: 13,
      name: r'tasaBcv',
      type: IsarType.double,
    ),
    r'tenantId': PropertySchema(
      id: 14,
      name: r'tenantId',
      type: IsarType.string,
    ),
    r'titular': PropertySchema(
      id: 15,
      name: r'titular',
      type: IsarType.string,
    ),
    r'ultimosDigitos': PropertySchema(
      id: 16,
      name: r'ultimosDigitos',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 17,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'ventaIdFk': PropertySchema(
      id: 18,
      name: r'ventaIdFk',
      type: IsarType.long,
    ),
    r'ventaSupabaseId': PropertySchema(
      id: 19,
      name: r'ventaSupabaseId',
      type: IsarType.string,
    ),
    r'walletDestino': PropertySchema(
      id: 20,
      name: r'walletDestino',
      type: IsarType.string,
    )
  },
  estimateSize: _pagoVentaEntityEstimateSize,
  serialize: _pagoVentaEntitySerialize,
  deserialize: _pagoVentaEntityDeserialize,
  deserializeProp: _pagoVentaEntityDeserializeProp,
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
    r'ventaIdFk': IndexSchema(
      id: -8955582939714860263,
      name: r'ventaIdFk',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ventaIdFk',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'ventaSupabaseId': IndexSchema(
      id: 8462317851844394297,
      name: r'ventaSupabaseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'ventaSupabaseId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'metodo': IndexSchema(
      id: -944467228903984170,
      name: r'metodo',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'metodo',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pagoVentaEntityGetId,
  getLinks: _pagoVentaEntityGetLinks,
  attach: _pagoVentaEntityAttach,
  version: '3.1.0+1',
);

int _pagoVentaEntityEstimateSize(
  PagoVentaEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.bancoEmisor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.hashTransaccion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.metodo.length * 3;
  bytesCount += 3 + object.moneda.length * 3;
  {
    final value = object.redCripto;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.referencia;
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
    final value = object.titular;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ultimosDigitos;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.ventaSupabaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.walletDestino;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _pagoVentaEntitySerialize(
  PagoVentaEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bancoEmisor);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDateTime(offsets[2], object.fecha);
  writer.writeString(offsets[3], object.hashTransaccion);
  writer.writeLong(offsets[4], object.idIsar);
  writer.writeString(offsets[5], object.metodo);
  writer.writeString(offsets[6], object.moneda);
  writer.writeDouble(offsets[7], object.monto);
  writer.writeDouble(offsets[8], object.montoUsdEquivalente);
  writer.writeString(offsets[9], object.redCripto);
  writer.writeString(offsets[10], object.referencia);
  writer.writeString(offsets[11], object.supabaseId);
  writer.writeString(offsets[12], object.syncStatus);
  writer.writeDouble(offsets[13], object.tasaBcv);
  writer.writeString(offsets[14], object.tenantId);
  writer.writeString(offsets[15], object.titular);
  writer.writeString(offsets[16], object.ultimosDigitos);
  writer.writeDateTime(offsets[17], object.updatedAt);
  writer.writeLong(offsets[18], object.ventaIdFk);
  writer.writeString(offsets[19], object.ventaSupabaseId);
  writer.writeString(offsets[20], object.walletDestino);
}

PagoVentaEntity _pagoVentaEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PagoVentaEntity();
  object.bancoEmisor = reader.readStringOrNull(offsets[0]);
  object.createdAt = reader.readDateTimeOrNull(offsets[1]);
  object.fecha = reader.readDateTime(offsets[2]);
  object.hashTransaccion = reader.readStringOrNull(offsets[3]);
  object.id = id;
  object.idIsar = reader.readLongOrNull(offsets[4]);
  object.metodo = reader.readString(offsets[5]);
  object.moneda = reader.readString(offsets[6]);
  object.monto = reader.readDouble(offsets[7]);
  object.montoUsdEquivalente = reader.readDouble(offsets[8]);
  object.redCripto = reader.readStringOrNull(offsets[9]);
  object.referencia = reader.readStringOrNull(offsets[10]);
  object.supabaseId = reader.readStringOrNull(offsets[11]);
  object.syncStatus = reader.readString(offsets[12]);
  object.tasaBcv = reader.readDoubleOrNull(offsets[13]);
  object.tenantId = reader.readStringOrNull(offsets[14]);
  object.titular = reader.readStringOrNull(offsets[15]);
  object.ultimosDigitos = reader.readStringOrNull(offsets[16]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[17]);
  object.ventaIdFk = reader.readLongOrNull(offsets[18]);
  object.ventaSupabaseId = reader.readStringOrNull(offsets[19]);
  object.walletDestino = reader.readStringOrNull(offsets[20]);
  return object;
}

P _pagoVentaEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (reader.readDoubleOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 18:
      return (reader.readLongOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pagoVentaEntityGetId(PagoVentaEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pagoVentaEntityGetLinks(PagoVentaEntity object) {
  return [];
}

void _pagoVentaEntityAttach(
    IsarCollection<dynamic> col, Id id, PagoVentaEntity object) {
  object.id = id;
}

extension PagoVentaEntityQueryWhereSort
    on QueryBuilder<PagoVentaEntity, PagoVentaEntity, QWhere> {
  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhere> anyVentaIdFk() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'ventaIdFk'),
      );
    });
  }
}

extension PagoVentaEntityQueryWhere
    on QueryBuilder<PagoVentaEntity, PagoVentaEntity, QWhereClause> {
  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'supabaseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      supabaseIdEqualTo(String? supabaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'supabaseId',
        value: [supabaseId],
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      tenantIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tenantId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      tenantIdEqualTo(String? tenantId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tenantId',
        value: [tenantId],
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      ventaIdFkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ventaIdFk',
        value: [null],
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      ventaIdFkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ventaIdFk',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      ventaIdFkEqualTo(int? ventaIdFk) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ventaIdFk',
        value: [ventaIdFk],
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      ventaIdFkNotEqualTo(int? ventaIdFk) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaIdFk',
              lower: [],
              upper: [ventaIdFk],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaIdFk',
              lower: [ventaIdFk],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaIdFk',
              lower: [ventaIdFk],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaIdFk',
              lower: [],
              upper: [ventaIdFk],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      ventaIdFkGreaterThan(
    int? ventaIdFk, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ventaIdFk',
        lower: [ventaIdFk],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      ventaIdFkLessThan(
    int? ventaIdFk, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ventaIdFk',
        lower: [],
        upper: [ventaIdFk],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      ventaIdFkBetween(
    int? lowerVentaIdFk,
    int? upperVentaIdFk, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ventaIdFk',
        lower: [lowerVentaIdFk],
        includeLower: includeLower,
        upper: [upperVentaIdFk],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      ventaSupabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ventaSupabaseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      ventaSupabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'ventaSupabaseId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      ventaSupabaseIdEqualTo(String? ventaSupabaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'ventaSupabaseId',
        value: [ventaSupabaseId],
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      ventaSupabaseIdNotEqualTo(String? ventaSupabaseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaSupabaseId',
              lower: [],
              upper: [ventaSupabaseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaSupabaseId',
              lower: [ventaSupabaseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaSupabaseId',
              lower: [ventaSupabaseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'ventaSupabaseId',
              lower: [],
              upper: [ventaSupabaseId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      metodoEqualTo(String metodo) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'metodo',
        value: [metodo],
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterWhereClause>
      metodoNotEqualTo(String metodo) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'metodo',
              lower: [],
              upper: [metodo],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'metodo',
              lower: [metodo],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'metodo',
              lower: [metodo],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'metodo',
              lower: [],
              upper: [metodo],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PagoVentaEntityQueryFilter
    on QueryBuilder<PagoVentaEntity, PagoVentaEntity, QFilterCondition> {
  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      bancoEmisorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bancoEmisor',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      bancoEmisorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bancoEmisor',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      bancoEmisorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bancoEmisor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      bancoEmisorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bancoEmisor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      bancoEmisorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bancoEmisor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      bancoEmisorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bancoEmisor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      bancoEmisorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bancoEmisor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      bancoEmisorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bancoEmisor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      bancoEmisorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bancoEmisor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      bancoEmisorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bancoEmisor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      bancoEmisorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bancoEmisor',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      bancoEmisorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bancoEmisor',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      fechaEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      fechaGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      fechaLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      fechaBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fecha',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      hashTransaccionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'hashTransaccion',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      hashTransaccionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'hashTransaccion',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      hashTransaccionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashTransaccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      hashTransaccionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hashTransaccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      hashTransaccionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hashTransaccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      hashTransaccionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hashTransaccion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      hashTransaccionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'hashTransaccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      hashTransaccionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'hashTransaccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      hashTransaccionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'hashTransaccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      hashTransaccionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'hashTransaccion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      hashTransaccionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hashTransaccion',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      hashTransaccionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'hashTransaccion',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      idIsarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idIsar',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      idIsarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idIsar',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      idIsarEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idIsar',
        value: value,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      idIsarGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idIsar',
        value: value,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      idIsarLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idIsar',
        value: value,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      idIsarBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idIsar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      metodoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metodo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      metodoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metodo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      metodoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metodo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      metodoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metodo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      metodoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metodo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      metodoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metodo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      metodoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metodo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      metodoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metodo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      metodoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metodo',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      metodoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metodo',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      monedaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      monedaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      monedaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      monedaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'moneda',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      monedaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      monedaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      monedaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'moneda',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      monedaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'moneda',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      monedaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'moneda',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      monedaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'moneda',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      montoEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'monto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      montoGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'monto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      montoLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'monto',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      montoBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'monto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      montoUsdEquivalenteEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'montoUsdEquivalente',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      montoUsdEquivalenteGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'montoUsdEquivalente',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      montoUsdEquivalenteLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'montoUsdEquivalente',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      montoUsdEquivalenteBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'montoUsdEquivalente',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      redCriptoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'redCripto',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      redCriptoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'redCripto',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      redCriptoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'redCripto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      redCriptoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'redCripto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      redCriptoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'redCripto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      redCriptoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'redCripto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      redCriptoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'redCripto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      redCriptoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'redCripto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      redCriptoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'redCripto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      redCriptoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'redCripto',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      redCriptoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'redCripto',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      redCriptoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'redCripto',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      referenciaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'referencia',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      referenciaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'referencia',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      referenciaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      referenciaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'referencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      referenciaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'referencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      referenciaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'referencia',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      referenciaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'referencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      referenciaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'referencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      referenciaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'referencia',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      referenciaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'referencia',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      referenciaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'referencia',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      referenciaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'referencia',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      supabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      supabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      syncStatusEqualTo(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      syncStatusGreaterThan(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      syncStatusLessThan(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      syncStatusBetween(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      syncStatusStartsWith(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      syncStatusEndsWith(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tasaBcvIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tasaBcv',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tasaBcvIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tasaBcv',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tasaBcvEqualTo(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tasaBcvGreaterThan(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tasaBcvLessThan(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tasaBcvBetween(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tenantIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tenantId',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tenantIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tenantId',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tenantIdEqualTo(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tenantIdGreaterThan(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tenantIdLessThan(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tenantIdBetween(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tenantIdStartsWith(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tenantIdEndsWith(
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tenantIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tenantId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tenantIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tenantId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tenantIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      tenantIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tenantId',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      titularIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'titular',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      titularIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'titular',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      titularEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titular',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      titularGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'titular',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      titularLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'titular',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      titularBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'titular',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      titularStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'titular',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      titularEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'titular',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      titularContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'titular',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      titularMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'titular',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      titularIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'titular',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      titularIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'titular',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ultimosDigitosIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ultimosDigitos',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ultimosDigitosIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ultimosDigitos',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ultimosDigitosEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimosDigitos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ultimosDigitosGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ultimosDigitos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ultimosDigitosLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ultimosDigitos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ultimosDigitosBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ultimosDigitos',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ultimosDigitosStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ultimosDigitos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ultimosDigitosEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ultimosDigitos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ultimosDigitosContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ultimosDigitos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ultimosDigitosMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ultimosDigitos',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ultimosDigitosIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimosDigitos',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ultimosDigitosIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ultimosDigitos',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaIdFkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ventaIdFk',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaIdFkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ventaIdFk',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaIdFkEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaIdFk',
        value: value,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaIdFkGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ventaIdFk',
        value: value,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaIdFkLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ventaIdFk',
        value: value,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaIdFkBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ventaIdFk',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaSupabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ventaSupabaseId',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaSupabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ventaSupabaseId',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaSupabaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaSupabaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ventaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaSupabaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ventaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaSupabaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ventaSupabaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaSupabaseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ventaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaSupabaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ventaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaSupabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ventaSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaSupabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ventaSupabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaSupabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      ventaSupabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ventaSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      walletDestinoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'walletDestino',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      walletDestinoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'walletDestino',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      walletDestinoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'walletDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      walletDestinoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'walletDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      walletDestinoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'walletDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      walletDestinoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'walletDestino',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      walletDestinoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'walletDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      walletDestinoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'walletDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      walletDestinoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'walletDestino',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      walletDestinoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'walletDestino',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      walletDestinoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'walletDestino',
        value: '',
      ));
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterFilterCondition>
      walletDestinoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'walletDestino',
        value: '',
      ));
    });
  }
}

extension PagoVentaEntityQueryObject
    on QueryBuilder<PagoVentaEntity, PagoVentaEntity, QFilterCondition> {}

extension PagoVentaEntityQueryLinks
    on QueryBuilder<PagoVentaEntity, PagoVentaEntity, QFilterCondition> {}

extension PagoVentaEntityQuerySortBy
    on QueryBuilder<PagoVentaEntity, PagoVentaEntity, QSortBy> {
  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByBancoEmisor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bancoEmisor', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByBancoEmisorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bancoEmisor', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> sortByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByHashTransaccion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashTransaccion', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByHashTransaccionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashTransaccion', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> sortByIdIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idIsar', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByIdIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idIsar', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> sortByMetodo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodo', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByMetodoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodo', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> sortByMoneda() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneda', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByMonedaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneda', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> sortByMonto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monto', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByMontoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monto', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByMontoUsdEquivalente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoUsdEquivalente', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByMontoUsdEquivalenteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoUsdEquivalente', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByRedCripto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'redCripto', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByRedCriptoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'redCripto', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByReferencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referencia', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByReferenciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referencia', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> sortByTasaBcv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByTasaBcvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> sortByTitular() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titular', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByTitularDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titular', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByUltimosDigitos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimosDigitos', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByUltimosDigitosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimosDigitos', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByVentaIdFk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdFk', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByVentaIdFkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdFk', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByVentaSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByVentaSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByWalletDestino() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletDestino', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      sortByWalletDestinoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletDestino', Sort.desc);
    });
  }
}

extension PagoVentaEntityQuerySortThenBy
    on QueryBuilder<PagoVentaEntity, PagoVentaEntity, QSortThenBy> {
  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByBancoEmisor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bancoEmisor', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByBancoEmisorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bancoEmisor', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> thenByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByHashTransaccion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashTransaccion', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByHashTransaccionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hashTransaccion', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> thenByIdIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idIsar', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByIdIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idIsar', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> thenByMetodo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodo', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByMetodoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodo', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> thenByMoneda() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneda', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByMonedaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'moneda', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> thenByMonto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monto', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByMontoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'monto', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByMontoUsdEquivalente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoUsdEquivalente', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByMontoUsdEquivalenteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoUsdEquivalente', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByRedCripto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'redCripto', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByRedCriptoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'redCripto', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByReferencia() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referencia', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByReferenciaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'referencia', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> thenByTasaBcv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByTasaBcvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByTenantId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByTenantIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tenantId', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy> thenByTitular() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titular', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByTitularDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'titular', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByUltimosDigitos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimosDigitos', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByUltimosDigitosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimosDigitos', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByVentaIdFk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdFk', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByVentaIdFkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdFk', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByVentaSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByVentaSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByWalletDestino() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletDestino', Sort.asc);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QAfterSortBy>
      thenByWalletDestinoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'walletDestino', Sort.desc);
    });
  }
}

extension PagoVentaEntityQueryWhereDistinct
    on QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct> {
  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct>
      distinctByBancoEmisor({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bancoEmisor', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct> distinctByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fecha');
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct>
      distinctByHashTransaccion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hashTransaccion',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct> distinctByIdIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idIsar');
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct> distinctByMetodo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metodo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct> distinctByMoneda(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'moneda', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct> distinctByMonto() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'monto');
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct>
      distinctByMontoUsdEquivalente() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'montoUsdEquivalente');
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct> distinctByRedCripto(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'redCripto', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct>
      distinctByReferencia({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'referencia', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct>
      distinctBySupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct>
      distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct>
      distinctByTasaBcv() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tasaBcv');
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct> distinctByTenantId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tenantId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct> distinctByTitular(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'titular', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct>
      distinctByUltimosDigitos({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimosDigitos',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct>
      distinctByVentaIdFk() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ventaIdFk');
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct>
      distinctByVentaSupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ventaSupabaseId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PagoVentaEntity, PagoVentaEntity, QDistinct>
      distinctByWalletDestino({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'walletDestino',
          caseSensitive: caseSensitive);
    });
  }
}

extension PagoVentaEntityQueryProperty
    on QueryBuilder<PagoVentaEntity, PagoVentaEntity, QQueryProperty> {
  QueryBuilder<PagoVentaEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PagoVentaEntity, String?, QQueryOperations>
      bancoEmisorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bancoEmisor');
    });
  }

  QueryBuilder<PagoVentaEntity, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PagoVentaEntity, DateTime, QQueryOperations> fechaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fecha');
    });
  }

  QueryBuilder<PagoVentaEntity, String?, QQueryOperations>
      hashTransaccionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hashTransaccion');
    });
  }

  QueryBuilder<PagoVentaEntity, int?, QQueryOperations> idIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idIsar');
    });
  }

  QueryBuilder<PagoVentaEntity, String, QQueryOperations> metodoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metodo');
    });
  }

  QueryBuilder<PagoVentaEntity, String, QQueryOperations> monedaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'moneda');
    });
  }

  QueryBuilder<PagoVentaEntity, double, QQueryOperations> montoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'monto');
    });
  }

  QueryBuilder<PagoVentaEntity, double, QQueryOperations>
      montoUsdEquivalenteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'montoUsdEquivalente');
    });
  }

  QueryBuilder<PagoVentaEntity, String?, QQueryOperations> redCriptoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'redCripto');
    });
  }

  QueryBuilder<PagoVentaEntity, String?, QQueryOperations>
      referenciaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'referencia');
    });
  }

  QueryBuilder<PagoVentaEntity, String?, QQueryOperations>
      supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<PagoVentaEntity, String, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<PagoVentaEntity, double?, QQueryOperations> tasaBcvProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tasaBcv');
    });
  }

  QueryBuilder<PagoVentaEntity, String?, QQueryOperations> tenantIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tenantId');
    });
  }

  QueryBuilder<PagoVentaEntity, String?, QQueryOperations> titularProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'titular');
    });
  }

  QueryBuilder<PagoVentaEntity, String?, QQueryOperations>
      ultimosDigitosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimosDigitos');
    });
  }

  QueryBuilder<PagoVentaEntity, DateTime?, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<PagoVentaEntity, int?, QQueryOperations> ventaIdFkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ventaIdFk');
    });
  }

  QueryBuilder<PagoVentaEntity, String?, QQueryOperations>
      ventaSupabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ventaSupabaseId');
    });
  }

  QueryBuilder<PagoVentaEntity, String?, QQueryOperations>
      walletDestinoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'walletDestino');
    });
  }
}
