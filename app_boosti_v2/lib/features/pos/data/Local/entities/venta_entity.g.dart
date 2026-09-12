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
    r'clienteDocumento': PropertySchema(
      id: 0,
      name: r'clienteDocumento',
      type: IsarType.string,
    ),
    r'clienteId': PropertySchema(
      id: 1,
      name: r'clienteId',
      type: IsarType.long,
    ),
    r'clienteNombre': PropertySchema(
      id: 2,
      name: r'clienteNombre',
      type: IsarType.string,
    ),
    r'documento': PropertySchema(
      id: 3,
      name: r'documento',
      type: IsarType.long,
    ),
    r'empleado': PropertySchema(
      id: 4,
      name: r'empleado',
      type: IsarType.string,
    ),
    r'empleadoNombre': PropertySchema(
      id: 5,
      name: r'empleadoNombre',
      type: IsarType.string,
    ),
    r'fecha': PropertySchema(
      id: 6,
      name: r'fecha',
      type: IsarType.dateTime,
    ),
    r'idSupabase': PropertySchema(
      id: 7,
      name: r'idSupabase',
      type: IsarType.string,
    ),
    r'impuesto': PropertySchema(
      id: 8,
      name: r'impuesto',
      type: IsarType.double,
    ),
    r'metodoPago': PropertySchema(
      id: 9,
      name: r'metodoPago',
      type: IsarType.string,
    ),
    r'montoDescuentoTotal': PropertySchema(
      id: 10,
      name: r'montoDescuentoTotal',
      type: IsarType.double,
    ),
    r'subtotal': PropertySchema(
      id: 11,
      name: r'subtotal',
      type: IsarType.double,
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
    r'tieneDescuentoEspecial': PropertySchema(
      id: 14,
      name: r'tieneDescuentoEspecial',
      type: IsarType.bool,
    ),
    r'total': PropertySchema(
      id: 15,
      name: r'total',
      type: IsarType.double,
    ),
    r'totalBolivares': PropertySchema(
      id: 16,
      name: r'totalBolivares',
      type: IsarType.double,
    ),
    r'ventaIdString': PropertySchema(
      id: 17,
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
    )
  },
  links: {
    r'items': LinkSchema(
      id: 1883162638632567218,
      name: r'items',
      target: r'DetalleVentaEntity',
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
  bytesCount += 3 + object.ventaIdString.length * 3;
  return bytesCount;
}

void _ventaEntitySerialize(
  VentaEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.clienteDocumento);
  writer.writeLong(offsets[1], object.clienteId);
  writer.writeString(offsets[2], object.clienteNombre);
  writer.writeLong(offsets[3], object.documento);
  writer.writeString(offsets[4], object.empleado);
  writer.writeString(offsets[5], object.empleadoNombre);
  writer.writeDateTime(offsets[6], object.fecha);
  writer.writeString(offsets[7], object.idSupabase);
  writer.writeDouble(offsets[8], object.impuesto);
  writer.writeString(offsets[9], object.metodoPago);
  writer.writeDouble(offsets[10], object.montoDescuentoTotal);
  writer.writeDouble(offsets[11], object.subtotal);
  writer.writeString(offsets[12], object.syncStatus);
  writer.writeDouble(offsets[13], object.tasaBcv);
  writer.writeBool(offsets[14], object.tieneDescuentoEspecial);
  writer.writeDouble(offsets[15], object.total);
  writer.writeDouble(offsets[16], object.totalBolivares);
  writer.writeString(offsets[17], object.ventaIdString);
}

VentaEntity _ventaEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = VentaEntity();
  object.clienteDocumento = reader.readStringOrNull(offsets[0]);
  object.clienteId = reader.readLongOrNull(offsets[1]);
  object.clienteNombre = reader.readStringOrNull(offsets[2]);
  object.documento = reader.readLong(offsets[3]);
  object.empleado = reader.readString(offsets[4]);
  object.fecha = reader.readDateTimeOrNull(offsets[6]);
  object.id = id;
  object.idSupabase = reader.readStringOrNull(offsets[7]);
  object.impuesto = reader.readDouble(offsets[8]);
  object.metodoPago = reader.readString(offsets[9]);
  object.montoDescuentoTotal = reader.readDouble(offsets[10]);
  object.subtotal = reader.readDouble(offsets[11]);
  object.syncStatus = reader.readStringOrNull(offsets[12]);
  object.tasaBcv = reader.readDouble(offsets[13]);
  object.tieneDescuentoEspecial = reader.readBool(offsets[14]);
  object.total = reader.readDouble(offsets[15]);
  object.totalBolivares = reader.readDouble(offsets[16]);
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
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readBool(offset)) as P;
    case 15:
      return (reader.readDouble(offset)) as P;
    case 16:
      return (reader.readDouble(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _ventaEntityGetId(VentaEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _ventaEntityGetLinks(VentaEntity object) {
  return [object.items];
}

void _ventaEntityAttach(
    IsarCollection<dynamic> col, Id id, VentaEntity object) {
  object.id = id;
  object.items
      .attach(col, col.isar.collection<DetalleVentaEntity>(), r'items', id);
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
}

extension VentaEntityQueryFilter
    on QueryBuilder<VentaEntity, VentaEntity, QFilterCondition> {
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
}

extension VentaEntityQuerySortBy
    on QueryBuilder<VentaEntity, VentaEntity, QSortBy> {
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

  QueryBuilder<VentaEntity, VentaEntity, QDistinct> distinctByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fecha');
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
      distinctByMontoDescuentoTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'montoDescuentoTotal');
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

  QueryBuilder<VentaEntity, DateTime?, QQueryOperations> fechaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fecha');
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
      montoDescuentoTotalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'montoDescuentoTotal');
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
