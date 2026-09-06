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
    r'nombreProducto': PropertySchema(
      id: 2,
      name: r'nombreProducto',
      type: IsarType.string,
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
    r'productoId': PropertySchema(
      id: 5,
      name: r'productoId',
      type: IsarType.long,
    ),
    r'subtotal': PropertySchema(
      id: 6,
      name: r'subtotal',
      type: IsarType.double,
    ),
    r'syncStatus': PropertySchema(
      id: 7,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'ventaIdFk': PropertySchema(
      id: 8,
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
  bytesCount += 3 + object.nombreProducto.length * 3;
  {
    final value = object.syncStatus;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
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
  writer.writeDouble(offsets[0], object.cantidad);
  writer.writeBool(offsets[1], object.esDescuentoEspecial);
  writer.writeString(offsets[2], object.nombreProducto);
  writer.writeDouble(offsets[3], object.precioOriginal);
  writer.writeDouble(offsets[4], object.precioUnidad);
  writer.writeLong(offsets[5], object.productoId);
  writer.writeDouble(offsets[6], object.subtotal);
  writer.writeString(offsets[7], object.syncStatus);
  writer.writeString(offsets[8], object.ventaIdFk);
}

DetalleVentaEntity _detalleVentaEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = DetalleVentaEntity();
  object.cantidad = reader.readDouble(offsets[0]);
  object.esDescuentoEspecial = reader.readBoolOrNull(offsets[1]);
  object.id = id;
  object.nombreProducto = reader.readString(offsets[2]);
  object.precioOriginal = reader.readDoubleOrNull(offsets[3]);
  object.precioUnidad = reader.readDouble(offsets[4]);
  object.productoId = reader.readLongOrNull(offsets[5]);
  object.subtotal = reader.readDouble(offsets[6]);
  object.syncStatus = reader.readStringOrNull(offsets[7]);
  object.ventaIdFk = reader.readStringOrNull(offsets[8]);
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
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
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
      distinctByCantidad() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidad');
    });
  }

  QueryBuilder<DetalleVentaEntity, DetalleVentaEntity, QDistinct>
      distinctByEsDescuentoEspecial() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'esDescuentoEspecial');
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

  QueryBuilder<DetalleVentaEntity, double, QQueryOperations>
      cantidadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidad');
    });
  }

  QueryBuilder<DetalleVentaEntity, bool?, QQueryOperations>
      esDescuentoEspecialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'esDescuentoEspecial');
    });
  }

  QueryBuilder<DetalleVentaEntity, String, QQueryOperations>
      nombreProductoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombreProducto');
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
      ventaIdFkProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ventaIdFk');
    });
  }
}
