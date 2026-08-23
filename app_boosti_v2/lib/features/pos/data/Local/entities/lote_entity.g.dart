// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lote_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLoteEntityCollection on Isar {
  IsarCollection<LoteEntity> get loteEntitys => this.collection();
}

const LoteEntitySchema = CollectionSchema(
  name: r'LoteEntity',
  id: 1910462827492268001,
  properties: {
    r'cantidadInicial': PropertySchema(
      id: 0,
      name: r'cantidadInicial',
      type: IsarType.double,
    ),
    r'cantidadRestante': PropertySchema(
      id: 1,
      name: r'cantidadRestante',
      type: IsarType.double,
    ),
    r'codigoLoteProveedor': PropertySchema(
      id: 2,
      name: r'codigoLoteProveedor',
      type: IsarType.string,
    ),
    r'costoUnitario': PropertySchema(
      id: 3,
      name: r'costoUnitario',
      type: IsarType.double,
    ),
    r'estado': PropertySchema(
      id: 4,
      name: r'estado',
      type: IsarType.string,
    ),
    r'fechaIngreso': PropertySchema(
      id: 5,
      name: r'fechaIngreso',
      type: IsarType.dateTime,
    ),
    r'fechaSincronizacion': PropertySchema(
      id: 6,
      name: r'fechaSincronizacion',
      type: IsarType.dateTime,
    ),
    r'fechaVencimiento': PropertySchema(
      id: 7,
      name: r'fechaVencimiento',
      type: IsarType.dateTime,
    ),
    r'productoId': PropertySchema(
      id: 8,
      name: r'productoId',
      type: IsarType.long,
    ),
    r'sincronizado': PropertySchema(
      id: 9,
      name: r'sincronizado',
      type: IsarType.bool,
    )
  },
  estimateSize: _loteEntityEstimateSize,
  serialize: _loteEntitySerialize,
  deserialize: _loteEntityDeserialize,
  deserializeProp: _loteEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _loteEntityGetId,
  getLinks: _loteEntityGetLinks,
  attach: _loteEntityAttach,
  version: '3.1.0+1',
);

int _loteEntityEstimateSize(
  LoteEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.codigoLoteProveedor;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.estado.length * 3;
  return bytesCount;
}

void _loteEntitySerialize(
  LoteEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.cantidadInicial);
  writer.writeDouble(offsets[1], object.cantidadRestante);
  writer.writeString(offsets[2], object.codigoLoteProveedor);
  writer.writeDouble(offsets[3], object.costoUnitario);
  writer.writeString(offsets[4], object.estado);
  writer.writeDateTime(offsets[5], object.fechaIngreso);
  writer.writeDateTime(offsets[6], object.fechaSincronizacion);
  writer.writeDateTime(offsets[7], object.fechaVencimiento);
  writer.writeLong(offsets[8], object.productoId);
  writer.writeBool(offsets[9], object.sincronizado);
}

LoteEntity _loteEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LoteEntity();
  object.cantidadInicial = reader.readDouble(offsets[0]);
  object.cantidadRestante = reader.readDouble(offsets[1]);
  object.codigoLoteProveedor = reader.readStringOrNull(offsets[2]);
  object.costoUnitario = reader.readDoubleOrNull(offsets[3]);
  object.estado = reader.readString(offsets[4]);
  object.fechaIngreso = reader.readDateTime(offsets[5]);
  object.fechaSincronizacion = reader.readDateTimeOrNull(offsets[6]);
  object.fechaVencimiento = reader.readDateTimeOrNull(offsets[7]);
  object.id = id;
  object.productoId = reader.readLong(offsets[8]);
  object.sincronizado = reader.readBool(offsets[9]);
  return object;
}

P _loteEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _loteEntityGetId(LoteEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _loteEntityGetLinks(LoteEntity object) {
  return [];
}

void _loteEntityAttach(IsarCollection<dynamic> col, Id id, LoteEntity object) {
  object.id = id;
}

extension LoteEntityQueryWhereSort
    on QueryBuilder<LoteEntity, LoteEntity, QWhere> {
  QueryBuilder<LoteEntity, LoteEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LoteEntityQueryWhere
    on QueryBuilder<LoteEntity, LoteEntity, QWhereClause> {
  QueryBuilder<LoteEntity, LoteEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterWhereClause> idBetween(
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

extension LoteEntityQueryFilter
    on QueryBuilder<LoteEntity, LoteEntity, QFilterCondition> {
  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      cantidadInicialEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidadInicial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      cantidadInicialGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cantidadInicial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      cantidadInicialLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cantidadInicial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      cantidadInicialBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cantidadInicial',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      cantidadRestanteEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidadRestante',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      cantidadRestanteGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cantidadRestante',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      cantidadRestanteLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cantidadRestante',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      cantidadRestanteBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cantidadRestante',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      codigoLoteProveedorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'codigoLoteProveedor',
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      codigoLoteProveedorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'codigoLoteProveedor',
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      codigoLoteProveedorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoLoteProveedor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      codigoLoteProveedorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codigoLoteProveedor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      codigoLoteProveedorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codigoLoteProveedor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      codigoLoteProveedorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codigoLoteProveedor',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      codigoLoteProveedorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codigoLoteProveedor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      codigoLoteProveedorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codigoLoteProveedor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      codigoLoteProveedorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codigoLoteProveedor',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      codigoLoteProveedorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codigoLoteProveedor',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      codigoLoteProveedorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoLoteProveedor',
        value: '',
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      codigoLoteProveedorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigoLoteProveedor',
        value: '',
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      costoUnitarioIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'costoUnitario',
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      costoUnitarioIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'costoUnitario',
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      costoUnitarioEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'costoUnitario',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      costoUnitarioGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'costoUnitario',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      costoUnitarioLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'costoUnitario',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      costoUnitarioBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'costoUnitario',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> estadoEqualTo(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> estadoGreaterThan(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> estadoLessThan(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> estadoBetween(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> estadoStartsWith(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> estadoEndsWith(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> estadoContains(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> estadoMatches(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> estadoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      estadoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      fechaIngresoEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaIngreso',
        value: value,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      fechaIngresoGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaIngreso',
        value: value,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      fechaIngresoLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaIngreso',
        value: value,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      fechaIngresoBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaIngreso',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      fechaSincronizacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      fechaSincronizacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      fechaSincronizacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      fechaVencimientoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaVencimiento',
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      fechaVencimientoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaVencimiento',
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      fechaVencimientoEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaVencimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      fechaVencimientoGreaterThan(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      fechaVencimientoLessThan(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      fechaVencimientoBetween(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> productoIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'productoId',
        value: value,
      ));
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      productoIdGreaterThan(
    int value, {
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      productoIdLessThan(
    int value, {
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition> productoIdBetween(
    int lower,
    int upper, {
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

  QueryBuilder<LoteEntity, LoteEntity, QAfterFilterCondition>
      sincronizadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sincronizado',
        value: value,
      ));
    });
  }
}

extension LoteEntityQueryObject
    on QueryBuilder<LoteEntity, LoteEntity, QFilterCondition> {}

extension LoteEntityQueryLinks
    on QueryBuilder<LoteEntity, LoteEntity, QFilterCondition> {}

extension LoteEntityQuerySortBy
    on QueryBuilder<LoteEntity, LoteEntity, QSortBy> {
  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> sortByCantidadInicial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadInicial', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      sortByCantidadInicialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadInicial', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> sortByCantidadRestante() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadRestante', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      sortByCantidadRestanteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadRestante', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      sortByCodigoLoteProveedor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoLoteProveedor', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      sortByCodigoLoteProveedorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoLoteProveedor', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> sortByCostoUnitario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoUnitario', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> sortByCostoUnitarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoUnitario', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> sortByFechaIngreso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaIngreso', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> sortByFechaIngresoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaIngreso', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      sortByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      sortByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> sortByFechaVencimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVencimiento', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      sortByFechaVencimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVencimiento', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> sortByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> sortByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> sortBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> sortBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }
}

extension LoteEntityQuerySortThenBy
    on QueryBuilder<LoteEntity, LoteEntity, QSortThenBy> {
  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenByCantidadInicial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadInicial', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      thenByCantidadInicialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadInicial', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenByCantidadRestante() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadRestante', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      thenByCantidadRestanteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadRestante', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      thenByCodigoLoteProveedor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoLoteProveedor', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      thenByCodigoLoteProveedorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoLoteProveedor', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenByCostoUnitario() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoUnitario', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenByCostoUnitarioDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'costoUnitario', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenByFechaIngreso() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaIngreso', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenByFechaIngresoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaIngreso', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      thenByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      thenByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenByFechaVencimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVencimiento', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy>
      thenByFechaVencimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaVencimiento', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenByProductoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'productoId', Sort.desc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QAfterSortBy> thenBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }
}

extension LoteEntityQueryWhereDistinct
    on QueryBuilder<LoteEntity, LoteEntity, QDistinct> {
  QueryBuilder<LoteEntity, LoteEntity, QDistinct> distinctByCantidadInicial() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidadInicial');
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QDistinct> distinctByCantidadRestante() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidadRestante');
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QDistinct> distinctByCodigoLoteProveedor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigoLoteProveedor',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QDistinct> distinctByCostoUnitario() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'costoUnitario');
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QDistinct> distinctByEstado(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QDistinct> distinctByFechaIngreso() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaIngreso');
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QDistinct>
      distinctByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaSincronizacion');
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QDistinct> distinctByFechaVencimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaVencimiento');
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QDistinct> distinctByProductoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'productoId');
    });
  }

  QueryBuilder<LoteEntity, LoteEntity, QDistinct> distinctBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sincronizado');
    });
  }
}

extension LoteEntityQueryProperty
    on QueryBuilder<LoteEntity, LoteEntity, QQueryProperty> {
  QueryBuilder<LoteEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LoteEntity, double, QQueryOperations> cantidadInicialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidadInicial');
    });
  }

  QueryBuilder<LoteEntity, double, QQueryOperations>
      cantidadRestanteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidadRestante');
    });
  }

  QueryBuilder<LoteEntity, String?, QQueryOperations>
      codigoLoteProveedorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigoLoteProveedor');
    });
  }

  QueryBuilder<LoteEntity, double?, QQueryOperations> costoUnitarioProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'costoUnitario');
    });
  }

  QueryBuilder<LoteEntity, String, QQueryOperations> estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<LoteEntity, DateTime, QQueryOperations> fechaIngresoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaIngreso');
    });
  }

  QueryBuilder<LoteEntity, DateTime?, QQueryOperations>
      fechaSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaSincronizacion');
    });
  }

  QueryBuilder<LoteEntity, DateTime?, QQueryOperations>
      fechaVencimientoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaVencimiento');
    });
  }

  QueryBuilder<LoteEntity, int, QQueryOperations> productoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'productoId');
    });
  }

  QueryBuilder<LoteEntity, bool, QQueryOperations> sincronizadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sincronizado');
    });
  }
}
