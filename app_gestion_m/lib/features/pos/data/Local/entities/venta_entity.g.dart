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
    r'cedulaCliente': PropertySchema(
      id: 0,
      name: r'cedulaCliente',
      type: IsarType.string,
    ),
    r'empleado': PropertySchema(
      id: 1,
      name: r'empleado',
      type: IsarType.string,
    ),
    r'fecha': PropertySchema(
      id: 2,
      name: r'fecha',
      type: IsarType.dateTime,
    ),
    r'impuesto': PropertySchema(
      id: 3,
      name: r'impuesto',
      type: IsarType.double,
    ),
    r'items': PropertySchema(
      id: 4,
      name: r'items',
      type: IsarType.objectList,
      target: r'VentaItemEntity',
    ),
    r'metodoPago': PropertySchema(
      id: 5,
      name: r'metodoPago',
      type: IsarType.string,
    ),
    r'sincronizado': PropertySchema(
      id: 6,
      name: r'sincronizado',
      type: IsarType.bool,
    ),
    r'subtotal': PropertySchema(
      id: 7,
      name: r'subtotal',
      type: IsarType.double,
    ),
    r'tasaBcv': PropertySchema(
      id: 8,
      name: r'tasaBcv',
      type: IsarType.double,
    ),
    r'total': PropertySchema(
      id: 9,
      name: r'total',
      type: IsarType.double,
    ),
    r'totalBolivares': PropertySchema(
      id: 10,
      name: r'totalBolivares',
      type: IsarType.double,
    ),
    r'ventaIdString': PropertySchema(
      id: 11,
      name: r'ventaIdString',
      type: IsarType.string,
    )
  },
  estimateSize: _ventaEntityEstimateSize,
  serialize: _ventaEntitySerialize,
  deserialize: _ventaEntityDeserialize,
  deserializeProp: _ventaEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {r'VentaItemEntity': VentaItemEntitySchema},
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
  bytesCount += 3 + object.cedulaCliente.length * 3;
  bytesCount += 3 + object.empleado.length * 3;
  bytesCount += 3 + object.items.length * 3;
  {
    final offsets = allOffsets[VentaItemEntity]!;
    for (var i = 0; i < object.items.length; i++) {
      final value = object.items[i];
      bytesCount +=
          VentaItemEntitySchema.estimateSize(value, offsets, allOffsets);
    }
  }
  bytesCount += 3 + object.metodoPago.length * 3;
  bytesCount += 3 + object.ventaIdString.length * 3;
  return bytesCount;
}

void _ventaEntitySerialize(
  VentaEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.cedulaCliente);
  writer.writeString(offsets[1], object.empleado);
  writer.writeDateTime(offsets[2], object.fecha);
  writer.writeDouble(offsets[3], object.impuesto);
  writer.writeObjectList<VentaItemEntity>(
    offsets[4],
    allOffsets,
    VentaItemEntitySchema.serialize,
    object.items,
  );
  writer.writeString(offsets[5], object.metodoPago);
  writer.writeBool(offsets[6], object.sincronizado);
  writer.writeDouble(offsets[7], object.subtotal);
  writer.writeDouble(offsets[8], object.tasaBcv);
  writer.writeDouble(offsets[9], object.total);
  writer.writeDouble(offsets[10], object.totalBolivares);
  writer.writeString(offsets[11], object.ventaIdString);
}

VentaEntity _ventaEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VentaEntity();
  object.cedulaCliente = reader.readString(offsets[0]);
  object.empleado = reader.readString(offsets[1]);
  object.fecha = reader.readDateTime(offsets[2]);
  object.id = id;
  object.impuesto = reader.readDouble(offsets[3]);
  object.items = reader.readObjectList<VentaItemEntity>(
        offsets[4],
        VentaItemEntitySchema.deserialize,
        allOffsets,
        VentaItemEntity(),
      ) ??
      [];
  object.metodoPago = reader.readString(offsets[5]);
  object.sincronizado = reader.readBool(offsets[6]);
  object.subtotal = reader.readDouble(offsets[7]);
  object.tasaBcv = reader.readDouble(offsets[8]);
  object.total = reader.readDouble(offsets[9]);
  object.totalBolivares = reader.readDouble(offsets[10]);
  object.ventaIdString = reader.readString(offsets[11]);
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
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readObjectList<VentaItemEntity>(
            offset,
            VentaItemEntitySchema.deserialize,
            allOffsets,
            VentaItemEntity(),
          ) ??
          []) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ventaEntityGetId(VentaEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ventaEntityGetLinks(VentaEntity object) {
  return [];
}

void _ventaEntityAttach(
    IsarCollection<dynamic> col, Id id, VentaEntity object) {
  object.id = id;
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
}

extension VentaEntityQueryFilter
    on QueryBuilder<VentaEntity, VentaEntity, QFilterCondition> {
  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      cedulaClienteEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cedulaCliente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      cedulaClienteGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cedulaCliente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      cedulaClienteLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cedulaCliente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      cedulaClienteBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cedulaCliente',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      cedulaClienteStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cedulaCliente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      cedulaClienteEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cedulaCliente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      cedulaClienteContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cedulaCliente',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      cedulaClienteMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cedulaCliente',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      cedulaClienteIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cedulaCliente',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
      cedulaClienteIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cedulaCliente',
        value: '',
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> fechaEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> fechaLessThan(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> fechaBetween(
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> itemsIsEmpty() {
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition>
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
      sincronizadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sincronizado',
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
    on QueryBuilder<VentaEntity, VentaEntity, QFilterCondition> {
  QueryBuilder<VentaEntity, VentaEntity, QAfterFilterCondition> itemsElement(
      FilterQuery<VentaItemEntity> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'items');
    });
  }
}

extension VentaEntityQueryLinks
    on QueryBuilder<VentaEntity, VentaEntity, QFilterCondition> {}

extension VentaEntityQuerySortBy
    on QueryBuilder<VentaEntity, VentaEntity, QSortBy> {
  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortByCedulaCliente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cedulaCliente', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortByCedulaClienteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cedulaCliente', Sort.desc);
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> sortBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      sortBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
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
  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenByCedulaCliente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cedulaCliente', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenByCedulaClienteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cedulaCliente', Sort.desc);
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

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy> thenBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QAfterSortBy>
      thenBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
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
  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByCedulaCliente(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cedulaCliente',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByEmpleado(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empleado', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fecha');
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

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sincronizado');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctBySubtotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'subtotal');
    });
  }

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByTasaBcv() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tasaBcv');
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

  QueryBuilder<VentaEntity, String, QQueryOperations> cedulaClienteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cedulaCliente');
    });
  }

  QueryBuilder<VentaEntity, String, QQueryOperations> empleadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empleado');
    });
  }

  QueryBuilder<VentaEntity, DateTime, QQueryOperations> fechaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fecha');
    });
  }

  QueryBuilder<VentaEntity, double, QQueryOperations> impuestoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'impuesto');
    });
  }

  QueryBuilder<VentaEntity, List<VentaItemEntity>, QQueryOperations>
      itemsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'items');
    });
  }

  QueryBuilder<VentaEntity, String, QQueryOperations> metodoPagoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'metodoPago');
    });
  }

  QueryBuilder<VentaEntity, bool, QQueryOperations> sincronizadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sincronizado');
    });
  }

  QueryBuilder<VentaEntity, double, QQueryOperations> subtotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'subtotal');
    });
  }

  QueryBuilder<VentaEntity, double, QQueryOperations> tasaBcvProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tasaBcv');
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

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const VentaItemEntitySchema = Schema(
  name: r'VentaItemEntity',
  id: -1708947212487214268,
  properties: {
    r'cantidad': PropertySchema(
      id: 0,
      name: r'cantidad',
      type: IsarType.double,
    ),
    r'nombreProducto': PropertySchema(
      id: 1,
      name: r'nombreProducto',
      type: IsarType.string,
    ),
    r'precioUnidad': PropertySchema(
      id: 2,
      name: r'precioUnidad',
      type: IsarType.double,
    ),
    r'subtotal': PropertySchema(
      id: 3,
      name: r'subtotal',
      type: IsarType.double,
    )
  },
  estimateSize: _ventaItemEntityEstimateSize,
  serialize: _ventaItemEntitySerialize,
  deserialize: _ventaItemEntityDeserialize,
  deserializeProp: _ventaItemEntityDeserializeProp,
);

int _ventaItemEntityEstimateSize(
  VentaItemEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.nombreProducto.length * 3;
  return bytesCount;
}

void _ventaItemEntitySerialize(
  VentaItemEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cantidad);
  writer.writeString(offsets[1], object.nombreProducto);
  writer.writeDouble(offsets[2], object.precioUnidad);
  writer.writeDouble(offsets[3], object.subtotal);
}

VentaItemEntity _ventaItemEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VentaItemEntity();
  object.cantidad = reader.readDouble(offsets[0]);
  object.nombreProducto = reader.readString(offsets[1]);
  object.precioUnidad = reader.readDouble(offsets[2]);
  object.subtotal = reader.readDouble(offsets[3]);
  return object;
}

P _ventaItemEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension VentaItemEntityQueryFilter
    on QueryBuilder<VentaItemEntity, VentaItemEntity, QFilterCondition> {
  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
      nombreProductoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombreProducto',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
      nombreProductoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombreProducto',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
      nombreProductoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombreProducto',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
      nombreProductoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombreProducto',
        value: '',
      ));
    });
  }

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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

  QueryBuilder<VentaItemEntity, VentaItemEntity, QAfterFilterCondition>
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
}

extension VentaItemEntityQueryObject
    on QueryBuilder<VentaItemEntity, VentaItemEntity, QFilterCondition> {}
