// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cliente_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetClienteEntityCollection on Isar {
  IsarCollection<ClienteEntity> get clienteEntitys => this.collection();
}

const ClienteEntitySchema = CollectionSchema(
  name: r'ClienteEntity',
  id: -7095570591501621264,
  properties: {
    r'activo': PropertySchema(
      id: 0,
      name: r'activo',
      type: IsarType.bool,
    ),
    r'cantidadCompras': PropertySchema(
      id: 1,
      name: r'cantidadCompras',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'descuentoPreferencial': PropertySchema(
      id: 3,
      name: r'descuentoPreferencial',
      type: IsarType.double,
    ),
    r'diasCredito': PropertySchema(
      id: 4,
      name: r'diasCredito',
      type: IsarType.long,
    ),
    r'direccion': PropertySchema(
      id: 5,
      name: r'direccion',
      type: IsarType.string,
    ),
    r'documento': PropertySchema(
      id: 6,
      name: r'documento',
      type: IsarType.long,
    ),
    r'documentoDisplay': PropertySchema(
      id: 7,
      name: r'documentoDisplay',
      type: IsarType.string,
    ),
    r'documentoFormateado': PropertySchema(
      id: 8,
      name: r'documentoFormateado',
      type: IsarType.string,
    ),
    r'email': PropertySchema(
      id: 9,
      name: r'email',
      type: IsarType.string,
    ),
    r'esMayorista': PropertySchema(
      id: 10,
      name: r'esMayorista',
      type: IsarType.bool,
    ),
    r'fechaNacimiento': PropertySchema(
      id: 11,
      name: r'fechaNacimiento',
      type: IsarType.dateTime,
    ),
    r'fechaRegistro': PropertySchema(
      id: 12,
      name: r'fechaRegistro',
      type: IsarType.dateTime,
    ),
    r'frecuente': PropertySchema(
      id: 13,
      name: r'frecuente',
      type: IsarType.bool,
    ),
    r'limiteCredito': PropertySchema(
      id: 14,
      name: r'limiteCredito',
      type: IsarType.double,
    ),
    r'localId': PropertySchema(
      id: 15,
      name: r'localId',
      type: IsarType.long,
    ),
    r'localSupabaseId': PropertySchema(
      id: 16,
      name: r'localSupabaseId',
      type: IsarType.string,
    ),
    r'nombre': PropertySchema(
      id: 17,
      name: r'nombre',
      type: IsarType.string,
    ),
    r'notas': PropertySchema(
      id: 18,
      name: r'notas',
      type: IsarType.string,
    ),
    r'preferenciasMarketing': PropertySchema(
      id: 19,
      name: r'preferenciasMarketing',
      type: IsarType.bool,
    ),
    r'razonSocial': PropertySchema(
      id: 20,
      name: r'razonSocial',
      type: IsarType.string,
    ),
    r'rif': PropertySchema(
      id: 21,
      name: r'rif',
      type: IsarType.string,
    ),
    r'supabaseId': PropertySchema(
      id: 22,
      name: r'supabaseId',
      type: IsarType.string,
    ),
    r'syncStatus': PropertySchema(
      id: 23,
      name: r'syncStatus',
      type: IsarType.string,
    ),
    r'telefono': PropertySchema(
      id: 24,
      name: r'telefono',
      type: IsarType.string,
    ),
    r'tipoDocumento': PropertySchema(
      id: 25,
      name: r'tipoDocumento',
      type: IsarType.string,
    ),
    r'tipoDocumentoLabel': PropertySchema(
      id: 26,
      name: r'tipoDocumentoLabel',
      type: IsarType.string,
    ),
    r'totalCompras': PropertySchema(
      id: 27,
      name: r'totalCompras',
      type: IsarType.double,
    ),
    r'ultimaCompra': PropertySchema(
      id: 28,
      name: r'ultimaCompra',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 29,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _clienteEntityEstimateSize,
  serialize: _clienteEntitySerialize,
  deserialize: _clienteEntityDeserialize,
  deserializeProp: _clienteEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'esMayorista': IndexSchema(
      id: -7403752653037538023,
      name: r'esMayorista',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'esMayorista',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _clienteEntityGetId,
  getLinks: _clienteEntityGetLinks,
  attach: _clienteEntityAttach,
  version: '3.1.0+1',
);

int _clienteEntityEstimateSize(
  ClienteEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.direccion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.documentoDisplay.length * 3;
  bytesCount += 3 + object.documentoFormateado.length * 3;
  {
    final value = object.email;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.localSupabaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.nombre.length * 3;
  {
    final value = object.notas;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.razonSocial;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rif;
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
    final value = object.telefono;
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
  bytesCount += 3 + object.tipoDocumentoLabel.length * 3;
  return bytesCount;
}

void _clienteEntitySerialize(
  ClienteEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.activo);
  writer.writeLong(offsets[1], object.cantidadCompras);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeDouble(offsets[3], object.descuentoPreferencial);
  writer.writeLong(offsets[4], object.diasCredito);
  writer.writeString(offsets[5], object.direccion);
  writer.writeLong(offsets[6], object.documento);
  writer.writeString(offsets[7], object.documentoDisplay);
  writer.writeString(offsets[8], object.documentoFormateado);
  writer.writeString(offsets[9], object.email);
  writer.writeBool(offsets[10], object.esMayorista);
  writer.writeDateTime(offsets[11], object.fechaNacimiento);
  writer.writeDateTime(offsets[12], object.fechaRegistro);
  writer.writeBool(offsets[13], object.frecuente);
  writer.writeDouble(offsets[14], object.limiteCredito);
  writer.writeLong(offsets[15], object.localId);
  writer.writeString(offsets[16], object.localSupabaseId);
  writer.writeString(offsets[17], object.nombre);
  writer.writeString(offsets[18], object.notas);
  writer.writeBool(offsets[19], object.preferenciasMarketing);
  writer.writeString(offsets[20], object.razonSocial);
  writer.writeString(offsets[21], object.rif);
  writer.writeString(offsets[22], object.supabaseId);
  writer.writeString(offsets[23], object.syncStatus);
  writer.writeString(offsets[24], object.telefono);
  writer.writeString(offsets[25], object.tipoDocumento);
  writer.writeString(offsets[26], object.tipoDocumentoLabel);
  writer.writeDouble(offsets[27], object.totalCompras);
  writer.writeDateTime(offsets[28], object.ultimaCompra);
  writer.writeDateTime(offsets[29], object.updatedAt);
}

ClienteEntity _clienteEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ClienteEntity();
  object.activo = reader.readBool(offsets[0]);
  object.cantidadCompras = reader.readLong(offsets[1]);
  object.createdAt = reader.readDateTimeOrNull(offsets[2]);
  object.descuentoPreferencial = reader.readDoubleOrNull(offsets[3]);
  object.diasCredito = reader.readLongOrNull(offsets[4]);
  object.direccion = reader.readStringOrNull(offsets[5]);
  object.documento = reader.readLongOrNull(offsets[6]);
  object.email = reader.readStringOrNull(offsets[9]);
  object.esMayorista = reader.readBool(offsets[10]);
  object.fechaNacimiento = reader.readDateTimeOrNull(offsets[11]);
  object.fechaRegistro = reader.readDateTime(offsets[12]);
  object.frecuente = reader.readBool(offsets[13]);
  object.id = id;
  object.limiteCredito = reader.readDoubleOrNull(offsets[14]);
  object.localId = reader.readLongOrNull(offsets[15]);
  object.localSupabaseId = reader.readStringOrNull(offsets[16]);
  object.nombre = reader.readString(offsets[17]);
  object.notas = reader.readStringOrNull(offsets[18]);
  object.preferenciasMarketing = reader.readBool(offsets[19]);
  object.razonSocial = reader.readStringOrNull(offsets[20]);
  object.rif = reader.readStringOrNull(offsets[21]);
  object.supabaseId = reader.readStringOrNull(offsets[22]);
  object.syncStatus = reader.readString(offsets[23]);
  object.telefono = reader.readStringOrNull(offsets[24]);
  object.tipoDocumento = reader.readStringOrNull(offsets[25]);
  object.totalCompras = reader.readDouble(offsets[27]);
  object.ultimaCompra = reader.readDateTimeOrNull(offsets[28]);
  object.updatedAt = reader.readDateTimeOrNull(offsets[29]);
  return object;
}

P _clienteEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 12:
      return (reader.readDateTime(offset)) as P;
    case 13:
      return (reader.readBool(offset)) as P;
    case 14:
      return (reader.readDoubleOrNull(offset)) as P;
    case 15:
      return (reader.readLongOrNull(offset)) as P;
    case 16:
      return (reader.readStringOrNull(offset)) as P;
    case 17:
      return (reader.readString(offset)) as P;
    case 18:
      return (reader.readStringOrNull(offset)) as P;
    case 19:
      return (reader.readBool(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset)) as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readString(offset)) as P;
    case 24:
      return (reader.readStringOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readString(offset)) as P;
    case 27:
      return (reader.readDouble(offset)) as P;
    case 28:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 29:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _clienteEntityGetId(ClienteEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _clienteEntityGetLinks(ClienteEntity object) {
  return [];
}

void _clienteEntityAttach(
    IsarCollection<dynamic> col, Id id, ClienteEntity object) {
  object.id = id;
}

extension ClienteEntityQueryWhereSort
    on QueryBuilder<ClienteEntity, ClienteEntity, QWhere> {
  QueryBuilder<ClienteEntity, ClienteEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterWhere> anyEsMayorista() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'esMayorista'),
      );
    });
  }
}

extension ClienteEntityQueryWhere
    on QueryBuilder<ClienteEntity, ClienteEntity, QWhereClause> {
  QueryBuilder<ClienteEntity, ClienteEntity, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterWhereClause>
      esMayoristaEqualTo(bool esMayorista) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'esMayorista',
        value: [esMayorista],
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterWhereClause>
      esMayoristaNotEqualTo(bool esMayorista) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'esMayorista',
              lower: [],
              upper: [esMayorista],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'esMayorista',
              lower: [esMayorista],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'esMayorista',
              lower: [esMayorista],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'esMayorista',
              lower: [],
              upper: [esMayorista],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ClienteEntityQueryFilter
    on QueryBuilder<ClienteEntity, ClienteEntity, QFilterCondition> {
  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      activoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activo',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      cantidadComprasEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cantidadCompras',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      cantidadComprasGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cantidadCompras',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      cantidadComprasLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cantidadCompras',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      cantidadComprasBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cantidadCompras',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      descuentoPreferencialIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'descuentoPreferencial',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      descuentoPreferencialIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'descuentoPreferencial',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      descuentoPreferencialEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'descuentoPreferencial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      descuentoPreferencialGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'descuentoPreferencial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      descuentoPreferencialLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'descuentoPreferencial',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      descuentoPreferencialBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'descuentoPreferencial',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      diasCreditoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'diasCredito',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      diasCreditoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'diasCredito',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      diasCreditoEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'diasCredito',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      diasCreditoGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'diasCredito',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      diasCreditoLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'diasCredito',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      diasCreditoBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'diasCredito',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      direccionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'direccion',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      direccionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'direccion',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      direccionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'direccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      direccionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'direccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      direccionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'direccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      direccionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'direccion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      direccionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'direccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      direccionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'direccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      direccionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'direccion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      direccionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'direccion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      direccionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'direccion',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      direccionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'direccion',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'documento',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'documento',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documento',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoGreaterThan(
    int? value, {
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoLessThan(
    int? value, {
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoDisplayEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentoDisplay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoDisplayGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentoDisplay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoDisplayLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentoDisplay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoDisplayBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentoDisplay',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoDisplayStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentoDisplay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoDisplayEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentoDisplay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoDisplayContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentoDisplay',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoDisplayMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentoDisplay',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoDisplayIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentoDisplay',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoDisplayIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentoDisplay',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoFormateadoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentoFormateado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoFormateadoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentoFormateado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoFormateadoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentoFormateado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoFormateadoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentoFormateado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoFormateadoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentoFormateado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoFormateadoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentoFormateado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoFormateadoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentoFormateado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoFormateadoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentoFormateado',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoFormateadoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentoFormateado',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      documentoFormateadoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentoFormateado',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      emailIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      emailIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'email',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      emailEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      emailGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      emailLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      emailBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'email',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      emailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      emailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      emailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'email',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      emailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'email',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      emailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      emailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'email',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      esMayoristaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'esMayorista',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      fechaNacimientoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaNacimiento',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      fechaNacimientoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaNacimiento',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      fechaNacimientoEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaNacimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      fechaNacimientoGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaNacimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      fechaNacimientoLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaNacimiento',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      fechaNacimientoBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaNacimiento',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      fechaRegistroEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      fechaRegistroGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      fechaRegistroLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaRegistro',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      fechaRegistroBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaRegistro',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      frecuenteEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'frecuente',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      limiteCreditoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'limiteCredito',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      limiteCreditoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'limiteCredito',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      limiteCreditoEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'limiteCredito',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      limiteCreditoGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'limiteCredito',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      limiteCreditoLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'limiteCredito',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      limiteCreditoBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'limiteCredito',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      localIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localId',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      localIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localId',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      localIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localId',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      localIdGreaterThan(
    int? value, {
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      localIdLessThan(
    int? value, {
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      localIdBetween(
    int? lower,
    int? upper, {
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      localSupabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'localSupabaseId',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      localSupabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'localSupabaseId',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      localSupabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'localSupabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      localSupabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'localSupabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      localSupabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      localSupabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'localSupabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      nombreEqualTo(
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      nombreGreaterThan(
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      nombreLessThan(
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      nombreBetween(
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      nombreStartsWith(
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      nombreEndsWith(
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      nombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      nombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      nombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      nombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombre',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      notasIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notas',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      notasIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notas',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      notasEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      notasGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      notasLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      notasBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notas',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      notasStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      notasEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      notasContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notas',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      notasMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notas',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      notasIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notas',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      notasIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notas',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      preferenciasMarketingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preferenciasMarketing',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      razonSocialIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'razonSocial',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      razonSocialIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'razonSocial',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      razonSocialEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'razonSocial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      razonSocialGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'razonSocial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      razonSocialLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'razonSocial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      razonSocialBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'razonSocial',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      razonSocialStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'razonSocial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      razonSocialEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'razonSocial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      razonSocialContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'razonSocial',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      razonSocialMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'razonSocial',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      razonSocialIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'razonSocial',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      razonSocialIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'razonSocial',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      rifIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rif',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      rifIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rif',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition> rifEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      rifGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition> rifLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition> rifBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rif',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      rifStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition> rifEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition> rifContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition> rifMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rif',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      rifIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rif',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      rifIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rif',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      supabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      supabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      syncStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'syncStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      syncStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'syncStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      syncStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      syncStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'syncStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      telefonoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'telefono',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      telefonoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'telefono',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      telefonoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'telefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      telefonoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'telefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      telefonoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'telefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      telefonoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'telefono',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      telefonoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'telefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      telefonoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'telefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      telefonoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'telefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      telefonoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'telefono',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      telefonoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'telefono',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      telefonoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'telefono',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tipoDocumento',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tipoDocumento',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipoDocumento',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipoDocumento',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoDocumento',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipoDocumento',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoLabelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoDocumentoLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tipoDocumentoLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tipoDocumentoLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tipoDocumentoLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tipoDocumentoLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tipoDocumentoLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoLabelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tipoDocumentoLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoLabelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tipoDocumentoLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tipoDocumentoLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      tipoDocumentoLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tipoDocumentoLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      totalComprasEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalCompras',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      totalComprasGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalCompras',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      totalComprasLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalCompras',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      totalComprasBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalCompras',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      ultimaCompraIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'ultimaCompra',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      ultimaCompraIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'ultimaCompra',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      ultimaCompraEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ultimaCompra',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      ultimaCompraGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ultimaCompra',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      ultimaCompraLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ultimaCompra',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      ultimaCompraBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ultimaCompra',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      updatedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      updatedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'updatedAt',
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
      updatedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterFilterCondition>
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
}

extension ClienteEntityQueryObject
    on QueryBuilder<ClienteEntity, ClienteEntity, QFilterCondition> {}

extension ClienteEntityQueryLinks
    on QueryBuilder<ClienteEntity, ClienteEntity, QFilterCondition> {}

extension ClienteEntityQuerySortBy
    on QueryBuilder<ClienteEntity, ClienteEntity, QSortBy> {
  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByCantidadCompras() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadCompras', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByCantidadComprasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadCompras', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByDescuentoPreferencial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoPreferencial', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByDescuentoPreferencialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoPreferencial', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByDiasCredito() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diasCredito', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByDiasCreditoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diasCredito', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByDireccion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direccion', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByDireccionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direccion', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documento', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByDocumentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documento', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByDocumentoDisplay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentoDisplay', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByDocumentoDisplayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentoDisplay', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByDocumentoFormateado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentoFormateado', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByDocumentoFormateadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentoFormateado', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByEsMayorista() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esMayorista', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByEsMayoristaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esMayorista', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByFechaNacimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaNacimiento', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByFechaNacimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaNacimiento', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByFrecuente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frecuente', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByFrecuenteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frecuente', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByLimiteCredito() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limiteCredito', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByLimiteCreditoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limiteCredito', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByLocalSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByLocalSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByNotas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notas', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByNotasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notas', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByPreferenciasMarketing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferenciasMarketing', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByPreferenciasMarketingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferenciasMarketing', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByRazonSocial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'razonSocial', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByRazonSocialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'razonSocial', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByRif() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rif', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByRifDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rif', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByTelefono() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telefono', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByTelefonoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telefono', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByTipoDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDocumento', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByTipoDocumentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDocumento', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByTipoDocumentoLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDocumentoLabel', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByTipoDocumentoLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDocumentoLabel', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByTotalCompras() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCompras', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByTotalComprasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCompras', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByUltimaCompra() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaCompra', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByUltimaCompraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaCompra', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ClienteEntityQuerySortThenBy
    on QueryBuilder<ClienteEntity, ClienteEntity, QSortThenBy> {
  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByCantidadCompras() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadCompras', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByCantidadComprasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cantidadCompras', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByDescuentoPreferencial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoPreferencial', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByDescuentoPreferencialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'descuentoPreferencial', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByDiasCredito() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diasCredito', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByDiasCreditoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diasCredito', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByDireccion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direccion', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByDireccionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'direccion', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documento', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByDocumentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documento', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByDocumentoDisplay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentoDisplay', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByDocumentoDisplayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentoDisplay', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByDocumentoFormateado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentoFormateado', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByDocumentoFormateadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentoFormateado', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByEmail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByEmailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'email', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByEsMayorista() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esMayorista', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByEsMayoristaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'esMayorista', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByFechaNacimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaNacimiento', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByFechaNacimientoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaNacimiento', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByFechaRegistroDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaRegistro', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByFrecuente() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frecuente', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByFrecuenteDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'frecuente', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByLimiteCredito() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limiteCredito', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByLimiteCreditoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'limiteCredito', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByLocalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localId', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByLocalSupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localSupabaseId', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByLocalSupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localSupabaseId', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombre', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByNotas() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notas', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByNotasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notas', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByPreferenciasMarketing() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferenciasMarketing', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByPreferenciasMarketingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferenciasMarketing', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByRazonSocial() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'razonSocial', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByRazonSocialDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'razonSocial', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByRif() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rif', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByRifDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rif', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenBySyncStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenBySyncStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncStatus', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByTelefono() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telefono', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByTelefonoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'telefono', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByTipoDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDocumento', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByTipoDocumentoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDocumento', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByTipoDocumentoLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDocumentoLabel', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByTipoDocumentoLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tipoDocumentoLabel', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByTotalCompras() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCompras', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByTotalComprasDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalCompras', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByUltimaCompra() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaCompra', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByUltimaCompraDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ultimaCompra', Sort.desc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension ClienteEntityQueryWhereDistinct
    on QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> {
  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activo');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByCantidadCompras() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cantidadCompras');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByDescuentoPreferencial() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'descuentoPreferencial');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByDiasCredito() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diasCredito');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByDireccion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'direccion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByDocumento() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documento');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByDocumentoDisplay({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentoDisplay',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByDocumentoFormateado({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentoFormateado',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByEmail(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'email', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByEsMayorista() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'esMayorista');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByFechaNacimiento() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaNacimiento');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByFechaRegistro() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaRegistro');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByFrecuente() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'frecuente');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByLimiteCredito() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'limiteCredito');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByLocalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localId');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByLocalSupabaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localSupabaseId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByNombre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByNotas(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notas', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByPreferenciasMarketing() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preferenciasMarketing');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByRazonSocial(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'razonSocial', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByRif(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rif', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctBySupabaseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctBySyncStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncStatus', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByTelefono(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'telefono', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByTipoDocumento(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoDocumento',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByTipoDocumentoLabel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tipoDocumentoLabel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByTotalCompras() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalCompras');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct>
      distinctByUltimaCompra() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ultimaCompra');
    });
  }

  QueryBuilder<ClienteEntity, ClienteEntity, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension ClienteEntityQueryProperty
    on QueryBuilder<ClienteEntity, ClienteEntity, QQueryProperty> {
  QueryBuilder<ClienteEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ClienteEntity, bool, QQueryOperations> activoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activo');
    });
  }

  QueryBuilder<ClienteEntity, int, QQueryOperations> cantidadComprasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cantidadCompras');
    });
  }

  QueryBuilder<ClienteEntity, DateTime?, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<ClienteEntity, double?, QQueryOperations>
      descuentoPreferencialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'descuentoPreferencial');
    });
  }

  QueryBuilder<ClienteEntity, int?, QQueryOperations> diasCreditoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diasCredito');
    });
  }

  QueryBuilder<ClienteEntity, String?, QQueryOperations> direccionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'direccion');
    });
  }

  QueryBuilder<ClienteEntity, int?, QQueryOperations> documentoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documento');
    });
  }

  QueryBuilder<ClienteEntity, String, QQueryOperations>
      documentoDisplayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentoDisplay');
    });
  }

  QueryBuilder<ClienteEntity, String, QQueryOperations>
      documentoFormateadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentoFormateado');
    });
  }

  QueryBuilder<ClienteEntity, String?, QQueryOperations> emailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'email');
    });
  }

  QueryBuilder<ClienteEntity, bool, QQueryOperations> esMayoristaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'esMayorista');
    });
  }

  QueryBuilder<ClienteEntity, DateTime?, QQueryOperations>
      fechaNacimientoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaNacimiento');
    });
  }

  QueryBuilder<ClienteEntity, DateTime, QQueryOperations>
      fechaRegistroProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaRegistro');
    });
  }

  QueryBuilder<ClienteEntity, bool, QQueryOperations> frecuenteProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'frecuente');
    });
  }

  QueryBuilder<ClienteEntity, double?, QQueryOperations>
      limiteCreditoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'limiteCredito');
    });
  }

  QueryBuilder<ClienteEntity, int?, QQueryOperations> localIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localId');
    });
  }

  QueryBuilder<ClienteEntity, String?, QQueryOperations>
      localSupabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localSupabaseId');
    });
  }

  QueryBuilder<ClienteEntity, String, QQueryOperations> nombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombre');
    });
  }

  QueryBuilder<ClienteEntity, String?, QQueryOperations> notasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notas');
    });
  }

  QueryBuilder<ClienteEntity, bool, QQueryOperations>
      preferenciasMarketingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preferenciasMarketing');
    });
  }

  QueryBuilder<ClienteEntity, String?, QQueryOperations> razonSocialProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'razonSocial');
    });
  }

  QueryBuilder<ClienteEntity, String?, QQueryOperations> rifProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rif');
    });
  }

  QueryBuilder<ClienteEntity, String?, QQueryOperations> supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<ClienteEntity, String, QQueryOperations> syncStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncStatus');
    });
  }

  QueryBuilder<ClienteEntity, String?, QQueryOperations> telefonoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'telefono');
    });
  }

  QueryBuilder<ClienteEntity, String?, QQueryOperations>
      tipoDocumentoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoDocumento');
    });
  }

  QueryBuilder<ClienteEntity, String, QQueryOperations>
      tipoDocumentoLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tipoDocumentoLabel');
    });
  }

  QueryBuilder<ClienteEntity, double, QQueryOperations> totalComprasProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalCompras');
    });
  }

  QueryBuilder<ClienteEntity, DateTime?, QQueryOperations>
      ultimaCompraProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ultimaCompra');
    });
  }

  QueryBuilder<ClienteEntity, DateTime?, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
