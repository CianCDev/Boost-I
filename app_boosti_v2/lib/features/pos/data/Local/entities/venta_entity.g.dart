// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venta_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetVentaEntityCollection on Isar {
  IsarCollection<VentaEntity> get ventaEntitys => this.collection();
}

const VentaEntitySchema = CollectionSchema(
  name: r'VentaEntity',
  id: 4471830502707141155,
  properties: {
    r'autorizadoPorNombre': PropertySchema(
      id: 0,
      name: r'autorizadoPorNombre',
      type: IsarType.string,
    ),
    r'autorizadoPorRol': PropertySchema(
      id: 1,
      name: r'autorizadoPorRol',
      type: IsarType.string,
    ),
    r'clienteDocumento': PropertySchema(
      id: 2,
      name: r'clienteDocumento',
      type: IsarType.string,
    ),
    r'clienteId': PropertySchema(
      id: 3,
      name: r'clienteId',
      type: IsarType.long,
    ),
    r'clienteNombre': PropertySchema(
      id: 4,
      name: r'clienteNombre',
      type: IsarType.string,
    ),
    r'clienteRazonSocial': PropertySchema(
      id: 5,
      name: r'clienteRazonSocial',
      type: IsarType.string,
    ),
    r'clienteRif': PropertySchema(
      id: 6,
      name: r'clienteRif',
      type: IsarType.string,
    ),
    r'documento': PropertySchema(
      id: 7,
      name: r'documento',
      type: IsarType.long,
    ),
    r'empleado': PropertySchema(
      id: 8,
      name: r'empleado',
      type: IsarType.string,
    ),
    r'empleadoNombre': PropertySchema(
      id: 9,
      name: r'empleadoNombre',
      type: IsarType.string,
    ),
    r'esMultipago': PropertySchema(
      id: 10,
      name: r'esMultipago',
      type: IsarType.bool,
    ),
    r'fecha': PropertySchema(
      id: 11,
      name: r'fecha',
      type: IsarType.dateTime,
    ),
    r'fechaAutorizacion': PropertySchema(
      id: 12,
      name: r'fechaAutorizacion',
      type: IsarType.dateTime,
    ),
    r'idSupabase': PropertySchema(
      id: 13,
      name: r'idSupabase',
      type: IsarType.string,
    ),
    r'impuesto': PropertySchema(
      id: 14,
      name: r'impuesto',
      type: IsarType.double,
    ),
    r'metodoPago': PropertySchema(
      id: 15,
      name: r'metodoPago',
      type: IsarType.string,
    ),
    r'montoDescuentoPorcentaje': PropertySchema(
      id: 16,
      name: r'montoDescuentoPorcentaje',
      type: IsarType.double,
    ),
    r'montoDescuentoTotal': PropertySchema(
      id: 17,
      name: r'montoDescuentoTotal',
      type: IsarType.double,
    ),
    r'requiereAutorizacion': PropertySchema(
      id: 18,
      name: r'requiereAutorizacion',
      type: IsarType.bool,
    ),
    r'subtotal': PropertySchema(
      id: 19,
      name: r'subtotal',
      type: IsarType.double,
    ),
    r'syncStatus': PropertySchema(
      id: 20,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'tasaBcv': PropertySchema(
      id: 21,
      name: r'tasaBcv',
      type: IsarType.double,
    ),
    r'tieneDescuentoEspecial': PropertySchema(
      id: 22,
      name: r'tieneDescuentoEspecial',
      type: IsarType.bool,
    ),
    r'tipoDocumento': PropertySchema(
      id: 23,
      name: r'tipoDocumento',
      type: IsarType.string,
    ),
    r'tipoPago': PropertySchema(
      id: 24,
      name: r'tipoPago',
      type: IsarType.string,
    ),
    r'tipoVenta': PropertySchema(
      id: 25,
      name: r'tipoVenta',
      type: IsarType.string,
    ),
    r'total': PropertySchema(
      id: 26,
      name: r'total',
      type: IsarType.double,
    ),
    r'totalBolivares': PropertySchema(
      id: 27,
      name: r'totalBolivares',
      type: IsarType.double,
    ),
    r'ventaIdString': PropertySchema(
      id: 28,
      name: r'ventaIdString',
      type: IsarType.string,
    )
  },
  estimateSize: _ventaEntityEstimateSize,
  serialize: _ventaEntitySerialize,
  deserialize: _ventaEntityDeserialize,
  deserializeProp: _ventaEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'idSupabase': IndexSchema(
      id: 4556724780604286246,
      name: r'idSupabase',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'idSupabase',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'tipoVenta': IndexSchema(
      id: -5717726438028508383,
      name: r'tipoVenta',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'tipoVenta',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {
    r'items': LinkSchema(
      id: 1883162638632567218,
      name: r'items',
      target: r'DetalleVentaEntity',
      single: false,
    ),
    r'pagos': LinkSchema(
      id: 4899119960094127288,
      name: r'pagos',
      target: r'PagoVentaEntity',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _ventaEntityGetId,
  getLinks: _ventaEntityGetLinks,
  attach: _ventaEntityAttach,
  version: '3.1.0+1',
);

int _ventaEntityEstimateSize(
  VentaEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.autorizadoPorNombre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.autorizadoPorRol;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
  bytesCount += 3 + object.empleado.length * 3;
  bytesCount += 3 + object.empleadoNombre.length * 3;
  {
    final value = object.idSupabase;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.metodoPago.length * 3;
  {
    final value = object.syncStatus;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tipoDocumento;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tipoPago.length * 3;
  bytesCount += 3 + object.tipoVenta.length * 3;
  bytesCount += 3 + object.ventaIdString.length * 3;
  return bytesCount;
}

void _ventaEntitySerialize(
  VentaEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.autorizadoPorNombre);
  writer.writeString(offsets[1], object.autorizadoPorRol);
  writer.writeString(offsets[2], object.clienteDocumento);
  writer.writeLong(offsets[3], object.clienteId);
  writer.writeString(offsets[4], object.clienteNombre);
  writer.writeString(offsets[5], object.clienteRazonSocial);
  writer.writeString(offsets[6], object.clienteRif);
  writer.writeLong(offsets[7], object.documento);
  writer.writeString(offsets[8], object.empleado);
  writer.writeString(offsets[9], object.empleadoNombre);
  writer.writeBool(offsets[10], object.esMultipago);
  writer.writeDateTime(offsets[11], object.fecha);
  writer.writeDateTime(offsets[12], object.fechaAutorizacion);
  writer.writeString(offsets[13], object.idSupabase);
  writer.writeDouble(offsets[14], object.impuesto);
  writer.writeString(offsets[15], object.metodoPago);
  writer.writeDouble(offsets[16], object.montoDescuentoPorcentaje);
  writer.writeDouble(offsets[17], object.montoDescuentoTotal);
  writer.writeBool(offsets[18], object.requiereAutorizacion);
  writer.writeDouble(offsets[19], object.subtotal);
  writer.writeString(offsets[20], object.syncStatus);
  writer.writeDouble(offsets[21], object.tasaBcv);
  writer.writeBool(offsets[22], object.tieneDescuentoEspecial);
  writer.writeString(offsets[23], object.tipoDocumento);
  writer.writeString(offsets[24], object.tipoPago);
  writer.writeString(offsets[25], object.tipoVenta);
  writer.writeDouble(offsets[26], object.total);
  writer.writeDouble(offsets[27], object.totalBolivares);
  writer.writeString(offsets[28], object.ventaIdString);
}

VentaEntity _ventaEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VentaEntity();
  object.autorizadoPorNombre = reader.readStringOrNull(offsets[0]);
  object.autorizadoPorRol = reader.readStringOrNull(offsets[1]);
  object.clienteDocumento = reader.readStringOrNull(offsets[2]);
  object.clienteId = reader.readLongOrNull(offsets[3]);
  object.clienteNombre = reader.readStringOrNull(offsets[4]);
  object.clienteRazonSocial = reader.readStringOrNull(offsets[5]);
  object.clienteRif = reader.readStringOrNull(offsets[6]);
  object.documento = reader.readLong(offsets[7]);
  object.empleado = reader.readString(offsets[8]);
  object.esMultipago = reader.readBool(offsets[10]);
  object.fecha = reader.readDateTimeOrNull(offsets[11]);
  object.fechaAutorizacion = reader.readDateTimeOrNull(offsets[12]);
  object.id = id;
  object.idSupabase = reader.readStringOrNull(offsets[13]);
  object.impuesto = reader.readDouble(offsets[14]);
  object.metodoPago = reader.readString(offsets[15]);
  object.montoDescuentoPorcentaje = reader.readDouble(offsets[16]);
  object.montoDescuentoTotal = reader.readDouble(offsets[17]);
  object.requiereAutorizacion = reader.readBool(offsets[18]);
  object.subtotal = reader.readDouble(offsets[19]);
  object.syncStatus = reader.readStringOrNull(offsets[20]);
  object.tasaBcv = reader.readDouble(offsets[21]);
  object.tieneDescuentoEspecial = reader.readBool(offsets[22]);
  object.tipoDocumento = reader.readStringOrNull(offsets[23]);
  object.tipoPago = reader.readString(offsets[24]);
  object.tipoVenta = reader.readString(offsets[25]);
  object.total = reader.readDouble(offsets[26]);
  object.totalBolivares = reader.readDouble(offsets[27]);
  return object;
}

P _ventaEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readDouble(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readDouble(offset)) as P;
    case 18:
      return (reader.readBool(offset)) as P;
    case 19:
      return (reader.readDouble(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readDouble(offset)) as P;
    case 22:
      return (reader.readBool(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readString(offset)) as P;
    case 25:
      return (reader.readString(offset)) as P;
    case 26:
      return (reader.readDouble(offset)) as P;
    case 27:
      return (reader.readDouble(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ventaEntityGetId(VentaEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ventaEntityGetLinks(VentaEntity object) {
  return [object.items, object.pagos];
}

void _ventaEntityAttach(
    IsarCollection<dynamic> col, Id id, VentaEntity object) {
  object.id = id;
  object.items
      .attach(col, col.isar.collection<DetalleVentaEntity>(), r'items', id);
  object.pagos
      .attach(col, col.isar.collection<PagoVentaEntity>(), r'pagos', id);
}

extension VentaEntityQueryWhereSort
    on QueryBuilder<VentaEntity, VentaEntity, QWhere> {
  QueryBuilder<VentaEntity, VentaEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension VentaEntityQueryWhere
    on QueryBuilder<VentaEntity, VentaEntity, QWhereClause> {
  QueryBuilder<VentaEntity, VentaEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterWhereClause> idSupabaseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idSupabase',
        value: [null],
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterWhereClause>
      idSupabaseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'idSupabase',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterWhereClause> idSupabaseEqualTo(
      String? idSupabase) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'idSupabase',
        value: [idSupabase],
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterWhereClause>
      idSupabaseNotEqualTo(String? idSupabase) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idSupabase',
              lower: [],
              upper: [idSupabase],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idSupabase',
              lower: [idSupabase],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idSupabase',
              lower: [idSupabase],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'idSupabase',
              lower: [],
              upper: [idSupabase],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterWhereClause> tipoVentaEqualTo(
      String tipoVenta) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'tipoVenta',
        value: [tipoVenta],
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterWhereClause> tipoVentaNotEqualTo(
      String tipoVenta) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tipoVenta',
              lower: [],
              upper: [tipoVenta],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tipoVenta',
              lower: [tipoVenta],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tipoVenta',
              lower: [tipoVenta],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'tipoVenta',
              lower: [],
              upper: [tipoVenta],
              includeUpper: false,
            ));
      }
    });
  }
}

extension VentaEntityQueryFilter
    on QueryBuilder<VentaEntity, VentaEntity, QFilterCondition> {
  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorNombreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'autorizadoPorNombre',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorNombreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'autorizadoPorNombre',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorNombreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autorizadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorNombreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autorizadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorNombreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autorizadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorNombreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autorizadoPorNombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorNombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'autorizadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorNombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'autorizadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'autorizadoPorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'autorizadoPorNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autorizadoPorNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'autorizadoPorNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorRolIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'autorizadoPorRol',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorRolIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'autorizadoPorRol',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorRolEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autorizadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorRolGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autorizadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorRolLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autorizadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorRolBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autorizadoPorRol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorRolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'autorizadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorRolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'autorizadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorRolContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'autorizadoPorRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorRolMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'autorizadoPorRol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorRolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autorizadoPorRol',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      autorizadoPorRolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'autorizadoPorRol',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteDocumentoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteDocumento',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteDocumentoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteDocumento',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteDocumentoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clienteDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteDocumentoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clienteDocumento',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteDocumentoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteDocumento',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteDocumentoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clienteDocumento',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteId',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteId',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteId',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteIdGreaterThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteIdLessThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteIdBetween(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteNombreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteNombre',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteNombreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteNombre',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clienteNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clienteNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clienteNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRazonSocialIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteRazonSocial',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRazonSocialIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteRazonSocial',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRazonSocialEqualTo(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRazonSocialGreaterThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRazonSocialLessThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRazonSocialBetween(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRazonSocialStartsWith(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRazonSocialEndsWith(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRazonSocialContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clienteRazonSocial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRazonSocialMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clienteRazonSocial',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRazonSocialIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteRazonSocial',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRazonSocialIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clienteRazonSocial',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRifIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'clienteRif',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRifIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'clienteRif',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRifEqualTo(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRifGreaterThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRifLessThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRifBetween(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRifStartsWith(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRifEndsWith(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRifContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'clienteRif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRifMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'clienteRif',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRifIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'clienteRif',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      clienteRifIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'clienteRif',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      documentoEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documento',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      documentoGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documento',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      documentoLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documento',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      documentoBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documento',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> empleadoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empleado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'empleado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'empleado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> empleadoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'empleado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'empleado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'empleado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'empleado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> empleadoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'empleado',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empleado',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'empleado',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoNombreEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empleadoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoNombreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'empleadoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoNombreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'empleadoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoNombreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'empleadoNombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoNombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'empleadoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoNombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'empleadoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'empleadoNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'empleadoNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empleadoNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      empleadoNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'empleadoNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      esMultipagoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'esMultipago',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> fechaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fecha',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      fechaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fecha',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> fechaEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      fechaGreaterThan(
    DateTime? value, {
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> fechaLessThan(
    DateTime? value, {
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> fechaBetween(
    DateTime? lower,
    DateTime? upper, {
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      fechaAutorizacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaAutorizacion',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      fechaAutorizacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaAutorizacion',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      fechaAutorizacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaAutorizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      fechaAutorizacionGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaAutorizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      fechaAutorizacionLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaAutorizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      fechaAutorizacionBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaAutorizacion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      idSupabaseIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'idSupabase',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      idSupabaseIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'idSupabase',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      idSupabaseEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idSupabase',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      idSupabaseGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'idSupabase',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      idSupabaseLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'idSupabase',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      idSupabaseBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'idSupabase',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      idSupabaseStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'idSupabase',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      idSupabaseEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'idSupabase',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      idSupabaseContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'idSupabase',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      idSupabaseMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'idSupabase',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      idSupabaseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'idSupabase',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      idSupabaseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'idSupabase',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> impuestoEqualTo(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      impuestoGreaterThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      impuestoLessThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> impuestoBetween(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      metodoPagoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metodoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      metodoPagoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'metodoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      metodoPagoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'metodoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      metodoPagoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'metodoPago',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      metodoPagoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'metodoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      metodoPagoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'metodoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      metodoPagoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'metodoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      metodoPagoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'metodoPago',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      metodoPagoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'metodoPago',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      metodoPagoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'metodoPago',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      montoDescuentoPorcentajeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'montoDescuentoPorcentaje',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      montoDescuentoPorcentajeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'montoDescuentoPorcentaje',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      montoDescuentoPorcentajeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'montoDescuentoPorcentaje',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      montoDescuentoPorcentajeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'montoDescuentoPorcentaje',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      montoDescuentoTotalEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'montoDescuentoTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      montoDescuentoTotalGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'montoDescuentoTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      montoDescuentoTotalLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'montoDescuentoTotal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      montoDescuentoTotalBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'montoDescuentoTotal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      requiereAutorizacionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'requiereAutorizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> subtotalEqualTo(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      subtotalGreaterThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      subtotalLessThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> subtotalBetween(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      syncStatusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncStatus',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      syncStatusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncStatus',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      syncStatusEqualTo(
    String? value, {
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      syncStatusGreaterThan(
    String? value, {
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      syncStatusLessThan(
    String? value, {
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      syncStatusBetween(
    String? lower,
    String? upper, {
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> tasaBcvEqualTo(
    double value, {
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tasaBcvGreaterThan(
    double value, {
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> tasaBcvLessThan(
    double value, {
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> tasaBcvBetween(
    double lower,
    double upper, {
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tieneDescuentoEspecialEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tieneDescuentoEspecial',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoDocumentoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tipoDocumento',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoDocumentoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tipoDocumento',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoDocumentoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoDocumentoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoDocumentoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoDocumentoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoDocumento',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoDocumentoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipoDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoDocumentoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipoDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoDocumentoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipoDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoDocumentoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipoDocumento',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoDocumentoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoDocumento',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoDocumentoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipoDocumento',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> tipoPagoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoPagoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoPagoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> tipoPagoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoPago',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoPagoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoPagoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoPagoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipoPago',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> tipoPagoMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipoPago',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoPagoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoPago',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoPagoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipoPago',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoVentaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoVenta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoVentaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoVenta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoVentaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoVenta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoVentaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoVenta',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoVentaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipoVenta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoVentaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipoVenta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoVentaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipoVenta',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoVentaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipoVenta',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoVentaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoVenta',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      tipoVentaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipoVenta',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> totalEqualTo(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      totalGreaterThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> totalLessThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> totalBetween(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      totalBolivaresEqualTo(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      totalBolivaresGreaterThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      totalBolivaresLessThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      totalBolivaresBetween(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      ventaIdStringEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaIdString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      ventaIdStringGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ventaIdString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      ventaIdStringLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ventaIdString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      ventaIdStringBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ventaIdString',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      ventaIdStringStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ventaIdString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      ventaIdStringEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ventaIdString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      ventaIdStringContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ventaIdString',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      ventaIdStringMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ventaIdString',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      ventaIdStringIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaIdString',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      ventaIdStringIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ventaIdString',
        value: '',
      ));
    });
  }
}

extension VentaEntityQueryObject
    on QueryBuilder<VentaEntity, VentaEntity, QFilterCondition> {}

extension VentaEntityQueryLinks
    on QueryBuilder<VentaEntity, VentaEntity, QFilterCondition> {
  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> items(
      FilterQuery<DetalleVentaEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'items');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      itemsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'items', length, true, length, true);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> itemsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'items', 0, true, 0, true);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      itemsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'items', 0, false, 999999, true);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      itemsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'items', 0, true, length, include);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      itemsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'items', length, include, 999999, true);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      itemsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'items', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> pagos(
      FilterQuery<PagoVentaEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'pagos');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      pagosLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pagos', length, true, length, true);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> pagosIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pagos', 0, true, 0, true);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      pagosIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pagos', 0, false, 999999, true);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      pagosLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pagos', 0, true, length, include);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      pagosLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'pagos', length, include, 999999, true);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      pagosLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'pagos', lower, includeLower, upper, includeUpper);
    });
  }
}

extension VentaEntityQuerySortBy
    on QueryBuilder<VentaEntity, VentaEntity, QSortBy> {
  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByAutorizadoPorNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorNombre', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByAutorizadoPorNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorNombre', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByAutorizadoPorRol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorRol', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByAutorizadoPorRolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorRol', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByClienteDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteDocumento', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByClienteDocumentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteDocumento', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByClienteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByClienteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByClienteNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNombre', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByClienteNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNombre', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByClienteRazonSocial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRazonSocial', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByClienteRazonSocialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRazonSocial', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByClienteRif() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRif', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByClienteRifDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRif', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documento', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByDocumentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documento', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByEmpleado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleado', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByEmpleadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleado', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByEmpleadoNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoNombre', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByEmpleadoNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoNombre', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByEsMultipago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esMultipago', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByEsMultipagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esMultipago', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByFechaAutorizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAutorizacion', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByFechaAutorizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAutorizacion', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByIdSupabase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idSupabase', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByIdSupabaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idSupabase', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByImpuesto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'impuesto', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByImpuestoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'impuesto', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByMetodoPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoPago', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByMetodoPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoPago', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByMontoDescuentoPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoDescuentoPorcentaje', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByMontoDescuentoPorcentajeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoDescuentoPorcentaje', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByMontoDescuentoTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoDescuentoTotal', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByMontoDescuentoTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoDescuentoTotal', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByRequiereAutorizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiereAutorizacion', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByRequiereAutorizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiereAutorizacion', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByTasaBcv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByTasaBcvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByTieneDescuentoEspecial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tieneDescuentoEspecial', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByTieneDescuentoEspecialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tieneDescuentoEspecial', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByTipoDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDocumento', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByTipoDocumentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDocumento', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByTipoPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoPago', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByTipoPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoPago', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByTipoVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoVenta', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByTipoVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoVenta', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByTotalBolivares() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBolivares', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByTotalBolivaresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBolivares', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByVentaIdString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdString', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByVentaIdStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdString', Sort.desc);
    });
  }
}

extension VentaEntityQuerySortThenBy
    on QueryBuilder<VentaEntity, VentaEntity, QSortThenBy> {
  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByAutorizadoPorNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorNombre', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByAutorizadoPorNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorNombre', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByAutorizadoPorRol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorRol', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByAutorizadoPorRolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorRol', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByClienteDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteDocumento', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByClienteDocumentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteDocumento', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByClienteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByClienteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteId', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByClienteNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNombre', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByClienteNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteNombre', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByClienteRazonSocial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRazonSocial', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByClienteRazonSocialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRazonSocial', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByClienteRif() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRif', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByClienteRifDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'clienteRif', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documento', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByDocumentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documento', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByEmpleado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleado', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByEmpleadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleado', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByEmpleadoNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoNombre', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByEmpleadoNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoNombre', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByEsMultipago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esMultipago', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByEsMultipagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esMultipago', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByFechaAutorizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAutorizacion', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByFechaAutorizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaAutorizacion', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByIdSupabase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idSupabase', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByIdSupabaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'idSupabase', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByImpuesto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'impuesto', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByImpuestoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'impuesto', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByMetodoPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoPago', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByMetodoPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'metodoPago', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByMontoDescuentoPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoDescuentoPorcentaje', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByMontoDescuentoPorcentajeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoDescuentoPorcentaje', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByMontoDescuentoTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoDescuentoTotal', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByMontoDescuentoTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'montoDescuentoTotal', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByRequiereAutorizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiereAutorizacion', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByRequiereAutorizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'requiereAutorizacion', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByTasaBcv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByTasaBcvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tasaBcv', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByTieneDescuentoEspecial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tieneDescuentoEspecial', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByTieneDescuentoEspecialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tieneDescuentoEspecial', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByTipoDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDocumento', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByTipoDocumentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDocumento', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByTipoPago() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoPago', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByTipoPagoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoPago', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByTipoVenta() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoVenta', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByTipoVentaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoVenta', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByTotalBolivares() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBolivares', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByTotalBolivaresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalBolivares', Sort.desc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByVentaIdString() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdString', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByVentaIdStringDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdString', Sort.desc);
    });
  }
}

extension VentaEntityQueryWhereDistinct
    on QueryBuilder<VentaEntity, VentaEntity, QDistinct> {
  QueryBuilder<VentaEntity, VentaEntity, QDistinct>
      distinctByAutorizadoPorNombre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autorizadoPorNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByAutorizadoPorRol(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autorizadoPorRol',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByClienteDocumento(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteDocumento',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByClienteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteId');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByClienteNombre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct>
      distinctByClienteRazonSocial({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteRazonSocial',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByClienteRif(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'clienteRif', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documento');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByEmpleado(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empleado', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByEmpleadoNombre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empleadoNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByEsMultipago() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'esMultipago');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fecha');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct>
      distinctByFechaAutorizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaAutorizacion');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByIdSupabase(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'idSupabase', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByImpuesto() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'impuesto');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByMetodoPago(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'metodoPago', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct>
      distinctByMontoDescuentoPorcentaje() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'montoDescuentoPorcentaje');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct>
      distinctByMontoDescuentoTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'montoDescuentoTotal');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct>
      distinctByRequiereAutorizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'requiereAutorizacion');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtotal');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctBySyncStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByTasaBcv() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tasaBcv');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct>
      distinctByTieneDescuentoEspecial() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tieneDescuentoEspecial');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByTipoDocumento(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoDocumento',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByTipoPago(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoPago', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByTipoVenta(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoVenta', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByTotalBolivares() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalBolivares');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByVentaIdString(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ventaIdString',
          caseSensitive: caseSensitive);
    });
  }
}

extension VentaEntityQueryProperty
    on QueryBuilder<VentaEntity, VentaEntity, QQueryProperty> {
  QueryBuilder<VentaEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<VentaEntity, String?, QQueryOperations>
      autorizadoPorNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autorizadoPorNombre');
    });
  }

  QueryBuilder<VentaEntity, String?, QQueryOperations>
      autorizadoPorRolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autorizadoPorRol');
    });
  }

  QueryBuilder<VentaEntity, String?, QQueryOperations>
      clienteDocumentoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteDocumento');
    });
  }

  QueryBuilder<VentaEntity, int?, QQueryOperations> clienteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteId');
    });
  }

  QueryBuilder<VentaEntity, String?, QQueryOperations> clienteNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteNombre');
    });
  }

  QueryBuilder<VentaEntity, String?, QQueryOperations>
      clienteRazonSocialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteRazonSocial');
    });
  }

  QueryBuilder<VentaEntity, String?, QQueryOperations> clienteRifProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'clienteRif');
    });
  }

  QueryBuilder<VentaEntity, int, QQueryOperations> documentoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documento');
    });
  }

  QueryBuilder<VentaEntity, String, QQueryOperations> empleadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empleado');
    });
  }

  QueryBuilder<VentaEntity, String, QQueryOperations> empleadoNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empleadoNombre');
    });
  }

  QueryBuilder<VentaEntity, bool, QQueryOperations> esMultipagoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'esMultipago');
    });
  }

  QueryBuilder<VentaEntity, DateTime?, QQueryOperations> fechaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fecha');
    });
  }

  QueryBuilder<VentaEntity, DateTime?, QQueryOperations>
      fechaAutorizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaAutorizacion');
    });
  }

  QueryBuilder<VentaEntity, String?, QQueryOperations> idSupabaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'idSupabase');
    });
  }

  QueryBuilder<VentaEntity, double, QQueryOperations> impuestoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'impuesto');
    });
  }

  QueryBuilder<VentaEntity, String, QQueryOperations> metodoPagoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metodoPago');
    });
  }

  QueryBuilder<VentaEntity, double, QQueryOperations>
      montoDescuentoPorcentajeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'montoDescuentoPorcentaje');
    });
  }

  QueryBuilder<VentaEntity, double, QQueryOperations>
      montoDescuentoTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'montoDescuentoTotal');
    });
  }

  QueryBuilder<VentaEntity, bool, QQueryOperations>
      requiereAutorizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'requiereAutorizacion');
    });
  }

  QueryBuilder<VentaEntity, double, QQueryOperations> subtotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtotal');
    });
  }

  QueryBuilder<VentaEntity, String?, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<VentaEntity, double, QQueryOperations> tasaBcvProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tasaBcv');
    });
  }

  QueryBuilder<VentaEntity, bool, QQueryOperations>
      tieneDescuentoEspecialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tieneDescuentoEspecial');
    });
  }

  QueryBuilder<VentaEntity, String?, QQueryOperations> tipoDocumentoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoDocumento');
    });
  }

  QueryBuilder<VentaEntity, String, QQueryOperations> tipoPagoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoPago');
    });
  }

  QueryBuilder<VentaEntity, String, QQueryOperations> tipoVentaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoVenta');
    });
  }

  QueryBuilder<VentaEntity, double, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }

  QueryBuilder<VentaEntity, double, QQueryOperations> totalBolivaresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalBolivares');
    });
  }

  QueryBuilder<VentaEntity, String, QQueryOperations> ventaIdStringProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ventaIdString');
    });
  }
}
