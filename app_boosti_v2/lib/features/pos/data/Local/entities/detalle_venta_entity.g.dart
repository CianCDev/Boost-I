// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detalle_venta_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetDetalleVentaEntityCollection on Isar {
  IsarCollection<DetalleVentaEntity> get detalleVentaEntitys =>
      this.collection();
}

const DetalleVentaEntitySchema = CollectionSchema(
  name: r'DetalleVentaEntity',
  id: -7850025648576014193,
  properties: {
    r'autorizadoPorLinea': PropertySchema(
      id: 0,
      name: r'autorizadoPorLinea',
      type: IsarType.string,
    ),
    r'cantidad': PropertySchema(
      id: 1,
      name: r'cantidad',
      type: IsarType.double,
    ),
    r'costoUnitarioSnapshot': PropertySchema(
      id: 2,
      name: r'costoUnitarioSnapshot',
      type: IsarType.double,
    ),
    r'descuentoPorcentajeLinea': PropertySchema(
      id: 3,
      name: r'descuentoPorcentajeLinea',
      type: IsarType.double,
    ),
    r'esDescuentoEspecial': PropertySchema(
      id: 4,
      name: r'esDescuentoEspecial',
      type: IsarType.bool,
    ),
    r'loteIdIsar': PropertySchema(
      id: 5,
      name: r'loteIdIsar',
      type: IsarType.long,
    ),
    r'nombreProducto': PropertySchema(
      id: 6,
      name: r'nombreProducto',
      type: IsarType.string,
    ),
    r'precioDetalOriginal': PropertySchema(
      id: 7,
      name: r'precioDetalOriginal',
      type: IsarType.double,
    ),
    r'precioMayorAplicado': PropertySchema(
      id: 8,
      name: r'precioMayorAplicado',
      type: IsarType.double,
    ),
    r'precioOriginal': PropertySchema(
      id: 9,
      name: r'precioOriginal',
      type: IsarType.double,
    ),
    r'precioUnidad': PropertySchema(
      id: 10,
      name: r'precioUnidad',
      type: IsarType.double,
    ),
    r'productoId': PropertySchema(
      id: 11,
      name: r'productoId',
      type: IsarType.long,
    ),
    r'subtotal': PropertySchema(
      id: 12,
      name: r'subtotal',
      type: IsarType.double,
    ),
    r'syncStatus': PropertySchema(
      id: 13,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'tipoPrecio': PropertySchema(
      id: 14,
      name: r'tipoPrecio',
      type: IsarType.string,
    ),
    r'unidadEmpaque': PropertySchema(
      id: 15,
      name: r'unidadEmpaque',
      type: IsarType.string,
    ),
    r'unidadesPorEmpaque': PropertySchema(
      id: 16,
      name: r'unidadesPorEmpaque',
      type: IsarType.long,
    ),
    r'ventaIdFk': PropertySchema(
      id: 17,
      name: r'ventaIdFk',
      type: IsarType.string,
    )
  },
  estimateSize: _detalleVentaEntityEstimateSize,
  serialize: _detalleVentaEntitySerialize,
  deserialize: _detalleVentaEntityDeserialize,
  deserializeProp: _detalleVentaEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _detalleVentaEntityGetId,
  getLinks: _detalleVentaEntityGetLinks,
  attach: _detalleVentaEntityAttach,
  version: '3.1.0+1',
);

int _detalleVentaEntityEstimateSize(
  DetalleVentaEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.autorizadoPorLinea;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.nombreProducto.length * 3;
  {
    final value = object.syncStatus;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.tipoPrecio;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.unidadEmpaque.length * 3;
  {
    final value = object.ventaIdFk;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _detalleVentaEntitySerialize(
  DetalleVentaEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.autorizadoPorLinea);
  writer.writeDouble(offsets[1], object.cantidad);
  writer.writeDouble(offsets[2], object.costoUnitarioSnapshot);
  writer.writeDouble(offsets[3], object.descuentoPorcentajeLinea);
  writer.writeBool(offsets[4], object.esDescuentoEspecial);
  writer.writeLong(offsets[5], object.loteIdIsar);
  writer.writeString(offsets[6], object.nombreProducto);
  writer.writeDouble(offsets[7], object.precioDetalOriginal);
  writer.writeDouble(offsets[8], object.precioMayorAplicado);
  writer.writeDouble(offsets[9], object.precioOriginal);
  writer.writeDouble(offsets[10], object.precioUnidad);
  writer.writeLong(offsets[11], object.productoId);
  writer.writeDouble(offsets[12], object.subtotal);
  writer.writeString(offsets[13], object.syncStatus);
  writer.writeString(offsets[14], object.tipoPrecio);
  writer.writeString(offsets[15], object.unidadEmpaque);
  writer.writeLong(offsets[16], object.unidadesPorEmpaque);
  writer.writeString(offsets[17], object.ventaIdFk);
}

DetalleVentaEntity _detalleVentaEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DetalleVentaEntity();
  object.autorizadoPorLinea = reader.readStringOrNull(offsets[0]);
  object.cantidad = reader.readDouble(offsets[1]);
  object.costoUnitarioSnapshot = reader.readDoubleOrNull(offsets[2]);
  object.descuentoPorcentajeLinea = reader.readDouble(offsets[3]);
  object.esDescuentoEspecial = reader.readBoolOrNull(offsets[4]);
  object.id = id;
  object.loteIdIsar = reader.readLongOrNull(offsets[5]);
  object.nombreProducto = reader.readString(offsets[6]);
  object.precioDetalOriginal = reader.readDoubleOrNull(offsets[7]);
  object.precioMayorAplicado = reader.readDoubleOrNull(offsets[8]);
  object.precioOriginal = reader.readDoubleOrNull(offsets[9]);
  object.precioUnidad = reader.readDouble(offsets[10]);
  object.productoId = reader.readLongOrNull(offsets[11]);
  object.subtotal = reader.readDouble(offsets[12]);
  object.syncStatus = reader.readStringOrNull(offsets[13]);
  object.tipoPrecio = reader.readStringOrNull(offsets[14]);
  object.unidadEmpaque = reader.readString(offsets[15]);
  object.unidadesPorEmpaque = reader.readLong(offsets[16]);
  object.ventaIdFk = reader.readStringOrNull(offsets[17]);
  return object;
}

P _detalleVentaEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readLongOrNull(offset)) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readString(offset)) as P;
    case 16:
      return (reader.readLong(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _detalleVentaEntityGetId(DetalleVentaEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _detalleVentaEntityGetLinks(
    DetalleVentaEntity object) {
  return [];
}

void _detalleVentaEntityAttach(
    IsarCollection<dynamic> col, Id id, DetalleVentaEntity object) {
  object.id = id;
}

extension DetalleVentaEntityQueryWhereSort
    on QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QWhere> {
  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension DetalleVentaEntityQueryWhere
    on QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QWhereClause> {
  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterWhereClause>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterWhereClause>
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

extension DetalleVentaEntityQueryFilter
    on QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QFilterCondition> {
  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      autorizadoPorLineaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'autorizadoPorLinea',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      autorizadoPorLineaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'autorizadoPorLinea',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      autorizadoPorLineaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autorizadoPorLinea',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      autorizadoPorLineaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'autorizadoPorLinea',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      autorizadoPorLineaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'autorizadoPorLinea',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      autorizadoPorLineaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'autorizadoPorLinea',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      autorizadoPorLineaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'autorizadoPorLinea',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      autorizadoPorLineaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'autorizadoPorLinea',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      autorizadoPorLineaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'autorizadoPorLinea',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      autorizadoPorLineaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'autorizadoPorLinea',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      autorizadoPorLineaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'autorizadoPorLinea',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      autorizadoPorLineaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'autorizadoPorLinea',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      costoUnitarioSnapshotIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'costoUnitarioSnapshot',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      costoUnitarioSnapshotIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'costoUnitarioSnapshot',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      costoUnitarioSnapshotEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'costoUnitarioSnapshot',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      costoUnitarioSnapshotGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'costoUnitarioSnapshot',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      costoUnitarioSnapshotLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'costoUnitarioSnapshot',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      costoUnitarioSnapshotBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'costoUnitarioSnapshot',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      descuentoPorcentajeLineaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descuentoPorcentajeLinea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      descuentoPorcentajeLineaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descuentoPorcentajeLinea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      descuentoPorcentajeLineaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descuentoPorcentajeLinea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      descuentoPorcentajeLineaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descuentoPorcentajeLinea',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      esDescuentoEspecialIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'esDescuentoEspecial',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      esDescuentoEspecialIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'esDescuentoEspecial',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      esDescuentoEspecialEqualTo(bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'esDescuentoEspecial',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      loteIdIsarIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'loteIdIsar',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      loteIdIsarIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'loteIdIsar',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      loteIdIsarEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'loteIdIsar',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      loteIdIsarGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'loteIdIsar',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      loteIdIsarLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'loteIdIsar',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      loteIdIsarBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'loteIdIsar',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      nombreProductoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombreProducto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      nombreProductoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nombreProducto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      nombreProductoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nombreProducto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      nombreProductoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nombreProducto',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      nombreProductoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nombreProducto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      nombreProductoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nombreProducto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      nombreProductoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombreProducto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      nombreProductoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombreProducto',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      nombreProductoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombreProducto',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      nombreProductoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombreProducto',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioDetalOriginalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'precioDetalOriginal',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioDetalOriginalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'precioDetalOriginal',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioDetalOriginalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precioDetalOriginal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioDetalOriginalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precioDetalOriginal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioDetalOriginalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precioDetalOriginal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioDetalOriginalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precioDetalOriginal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioMayorAplicadoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'precioMayorAplicado',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioMayorAplicadoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'precioMayorAplicado',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioMayorAplicadoEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'precioMayorAplicado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioMayorAplicadoGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'precioMayorAplicado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioMayorAplicadoLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'precioMayorAplicado',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioMayorAplicadoBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'precioMayorAplicado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioOriginalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'precioOriginal',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioOriginalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'precioOriginal',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioOriginalEqualTo(
    double? value, {
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioOriginalGreaterThan(
    double? value, {
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioOriginalLessThan(
    double? value, {
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      precioOriginalBetween(
    double? lower,
    double? upper, {
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      productoIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'productoId',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      productoIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'productoId',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      productoIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      productoIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      productoIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      productoIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'productoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      subtotalEqualTo(
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      subtotalBetween(
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      syncStatusIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncStatus',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      syncStatusIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncStatus',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
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

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      tipoPrecioIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tipoPrecio',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      tipoPrecioIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tipoPrecio',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      tipoPrecioEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoPrecio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      tipoPrecioGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoPrecio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      tipoPrecioLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoPrecio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      tipoPrecioBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoPrecio',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      tipoPrecioStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipoPrecio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      tipoPrecioEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipoPrecio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      tipoPrecioContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipoPrecio',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      tipoPrecioMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipoPrecio',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      tipoPrecioIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoPrecio',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      tipoPrecioIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipoPrecio',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadEmpaqueEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unidadEmpaque',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadEmpaqueGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unidadEmpaque',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadEmpaqueLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unidadEmpaque',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadEmpaqueBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unidadEmpaque',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadEmpaqueStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'unidadEmpaque',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadEmpaqueEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'unidadEmpaque',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadEmpaqueContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'unidadEmpaque',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadEmpaqueMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'unidadEmpaque',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadEmpaqueIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unidadEmpaque',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadEmpaqueIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'unidadEmpaque',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadesPorEmpaqueEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'unidadesPorEmpaque',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadesPorEmpaqueGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'unidadesPorEmpaque',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadesPorEmpaqueLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'unidadesPorEmpaque',
        value: value,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      unidadesPorEmpaqueBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'unidadesPorEmpaque',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      ventaIdFkIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ventaIdFk',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      ventaIdFkIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ventaIdFk',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      ventaIdFkEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaIdFk',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      ventaIdFkGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ventaIdFk',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      ventaIdFkLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ventaIdFk',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      ventaIdFkBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ventaIdFk',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      ventaIdFkStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'ventaIdFk',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      ventaIdFkEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'ventaIdFk',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      ventaIdFkContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'ventaIdFk',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      ventaIdFkMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'ventaIdFk',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      ventaIdFkIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ventaIdFk',
        value: '',
      ));
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterFilterCondition>
      ventaIdFkIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'ventaIdFk',
        value: '',
      ));
    });
  }
}

extension DetalleVentaEntityQueryObject
    on QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QFilterCondition> {}

extension DetalleVentaEntityQueryLinks
    on QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QFilterCondition> {}

extension DetalleVentaEntityQuerySortBy
    on QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QSortBy> {
  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByAutorizadoPorLinea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorLinea', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByAutorizadoPorLineaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorLinea', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByCostoUnitarioSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoUnitarioSnapshot', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByCostoUnitarioSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoUnitarioSnapshot', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByDescuentoPorcentajeLinea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoPorcentajeLinea', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByDescuentoPorcentajeLineaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoPorcentajeLinea', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByEsDescuentoEspecial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esDescuentoEspecial', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByEsDescuentoEspecialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esDescuentoEspecial', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByLoteIdIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loteIdIsar', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByLoteIdIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loteIdIsar', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByNombreProducto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreProducto', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByNombreProductoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreProducto', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByPrecioDetalOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioDetalOriginal', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByPrecioDetalOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioDetalOriginal', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByPrecioMayorAplicado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioMayorAplicado', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByPrecioMayorAplicadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioMayorAplicado', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByPrecioOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioOriginal', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByPrecioOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioOriginal', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByPrecioUnidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnidad', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByPrecioUnidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnidad', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByTipoPrecio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoPrecio', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByTipoPrecioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoPrecio', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByUnidadEmpaque() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadEmpaque', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByUnidadEmpaqueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadEmpaque', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByUnidadesPorEmpaque() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadesPorEmpaque', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByUnidadesPorEmpaqueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadesPorEmpaque', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByVentaIdFk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdFk', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      sortByVentaIdFkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdFk', Sort.desc);
    });
  }
}

extension DetalleVentaEntityQuerySortThenBy
    on QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QSortThenBy> {
  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByAutorizadoPorLinea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorLinea', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByAutorizadoPorLineaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'autorizadoPorLinea', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByCantidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidad', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByCostoUnitarioSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoUnitarioSnapshot', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByCostoUnitarioSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoUnitarioSnapshot', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByDescuentoPorcentajeLinea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoPorcentajeLinea', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByDescuentoPorcentajeLineaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoPorcentajeLinea', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByEsDescuentoEspecial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esDescuentoEspecial', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByEsDescuentoEspecialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esDescuentoEspecial', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByLoteIdIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loteIdIsar', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByLoteIdIsarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'loteIdIsar', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByNombreProducto() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreProducto', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByNombreProductoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombreProducto', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByPrecioDetalOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioDetalOriginal', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByPrecioDetalOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioDetalOriginal', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByPrecioMayorAplicado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioMayorAplicado', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByPrecioMayorAplicadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioMayorAplicado', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByPrecioOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioOriginal', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByPrecioOriginalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioOriginal', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByPrecioUnidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnidad', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByPrecioUnidadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'precioUnidad', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenBySubtotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'subtotal', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByTipoPrecio() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoPrecio', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByTipoPrecioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoPrecio', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByUnidadEmpaque() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadEmpaque', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByUnidadEmpaqueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadEmpaque', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByUnidadesPorEmpaque() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadesPorEmpaque', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByUnidadesPorEmpaqueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'unidadesPorEmpaque', Sort.desc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByVentaIdFk() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdFk', Sort.asc);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QAfterSortBy>
      thenByVentaIdFkDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ventaIdFk', Sort.desc);
    });
  }
}

extension DetalleVentaEntityQueryWhereDistinct
    on QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct> {
  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByAutorizadoPorLinea({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'autorizadoPorLinea',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidad');
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByCostoUnitarioSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costoUnitarioSnapshot');
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByDescuentoPorcentajeLinea() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descuentoPorcentajeLinea');
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByEsDescuentoEspecial() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'esDescuentoEspecial');
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByLoteIdIsar() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'loteIdIsar');
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByNombreProducto({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombreProducto',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByPrecioDetalOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'precioDetalOriginal');
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByPrecioMayorAplicado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'precioMayorAplicado');
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByPrecioOriginal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'precioOriginal');
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByPrecioUnidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'precioUnidad');
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId');
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtotal');
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctBySyncStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByTipoPrecio({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoPrecio', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByUnidadEmpaque({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unidadEmpaque',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByUnidadesPorEmpaque() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'unidadesPorEmpaque');
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByVentaIdFk({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ventaIdFk', caseSensitive: caseSensitive);
    });
  }
}

extension DetalleVentaEntityQueryProperty
    on QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QQueryProperty> {
  QueryBuilder<DetalleVentaEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<DetalleVentaEntity, String?, QQueryOperations>
      autorizadoPorLineaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'autorizadoPorLinea');
    });
  }

  QueryBuilder<DetalleVentaEntity, double, QQueryOperations>
      cantidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidad');
    });
  }

  QueryBuilder<DetalleVentaEntity, double?, QQueryOperations>
      costoUnitarioSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costoUnitarioSnapshot');
    });
  }

  QueryBuilder<DetalleVentaEntity, double, QQueryOperations>
      descuentoPorcentajeLineaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descuentoPorcentajeLinea');
    });
  }

  QueryBuilder<DetalleVentaEntity, bool?, QQueryOperations>
      esDescuentoEspecialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'esDescuentoEspecial');
    });
  }

  QueryBuilder<DetalleVentaEntity, int?, QQueryOperations>
      loteIdIsarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'loteIdIsar');
    });
  }

  QueryBuilder<DetalleVentaEntity, String, QQueryOperations>
      nombreProductoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombreProducto');
    });
  }

  QueryBuilder<DetalleVentaEntity, double?, QQueryOperations>
      precioDetalOriginalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'precioDetalOriginal');
    });
  }

  QueryBuilder<DetalleVentaEntity, double?, QQueryOperations>
      precioMayorAplicadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'precioMayorAplicado');
    });
  }

  QueryBuilder<DetalleVentaEntity, double?, QQueryOperations>
      precioOriginalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'precioOriginal');
    });
  }

  QueryBuilder<DetalleVentaEntity, double, QQueryOperations>
      precioUnidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'precioUnidad');
    });
  }

  QueryBuilder<DetalleVentaEntity, int?, QQueryOperations>
      productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }

  QueryBuilder<DetalleVentaEntity, double, QQueryOperations>
      subtotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtotal');
    });
  }

  QueryBuilder<DetalleVentaEntity, String?, QQueryOperations>
      syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<DetalleVentaEntity, String?, QQueryOperations>
      tipoPrecioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoPrecio');
    });
  }

  QueryBuilder<DetalleVentaEntity, String, QQueryOperations>
      unidadEmpaqueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unidadEmpaque');
    });
  }

  QueryBuilder<DetalleVentaEntity, int, QQueryOperations>
      unidadesPorEmpaqueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'unidadesPorEmpaque');
    });
  }

  QueryBuilder<DetalleVentaEntity, String?, QQueryOperations>
      ventaIdFkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ventaIdFk');
    });
  }
}
