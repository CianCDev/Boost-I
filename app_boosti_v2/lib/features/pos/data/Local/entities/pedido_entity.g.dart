// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pedido_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPedidoEntityCollection on Isar {
  IsarCollection<PedidoEntity> get pedidoEntitys => this.collection();
}

const PedidoEntitySchema = CollectionSchema(
  name: r'PedidoEntity',
  id: -1153166160075393522,
  properties: {
    r'estado': PropertySchema(
      id: 0,
      name: r'estado',
      type: IsarType.string,
      enumMap: _PedidoEntityestadoEnumValueMap,
    ),
    r'fechaPedido': PropertySchema(
      id: 1,
      name: r'fechaPedido',
      type: IsarType.dateTime,
    ),
    r'fechaSincronizacion': PropertySchema(
      id: 2,
      name: r'fechaSincronizacion',
      type: IsarType.dateTime,
    ),
    r'localDestinoId': PropertySchema(
      id: 3,
      name: r'localDestinoId',
      type: IsarType.long,
    ),
    r'localOrigenId': PropertySchema(
      id: 4,
      name: r'localOrigenId',
      type: IsarType.long,
    ),
    r'observaciones': PropertySchema(
      id: 5,
      name: r'observaciones',
      type: IsarType.string,
    ),
    r'proveedorCedula': PropertySchema(
      id: 6,
      name: r'proveedorCedula',
      type: IsarType.string,
    ),
    r'proveedorEmpresa': PropertySchema(
      id: 7,
      name: r'proveedorEmpresa',
      type: IsarType.string,
    ),
    r'proveedorNombre': PropertySchema(
      id: 8,
      name: r'proveedorNombre',
      type: IsarType.string,
    ),
    r'proveedorTelefono': PropertySchema(
      id: 9,
      name: r'proveedorTelefono',
      type: IsarType.string,
    ),
    r'sincronizado': PropertySchema(
      id: 10,
      name: r'sincronizado',
      type: IsarType.bool,
    ),
    r'supabaseId': PropertySchema(
      id: 11,
      name: r'supabaseId',
      type: IsarType.string,
    ),
    r'total': PropertySchema(
      id: 12,
      name: r'total',
      type: IsarType.double,
    ),
    r'usuarioId': PropertySchema(
      id: 13,
      name: r'usuarioId',
      type: IsarType.long,
    )
  },
  estimateSize: _pedidoEntityEstimateSize,
  serialize: _pedidoEntitySerialize,
  deserialize: _pedidoEntityDeserialize,
  deserializeProp: _pedidoEntityDeserializeProp,
  idName: r'id',
  indexes: {
    r'localOrigenId': IndexSchema(
      id: 8109924210662928475,
      name: r'localOrigenId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'localOrigenId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'localDestinoId': IndexSchema(
      id: 8650599709989308864,
      name: r'localDestinoId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'localDestinoId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'usuarioId': IndexSchema(
      id: -6806307564427522310,
      name: r'usuarioId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'usuarioId',
          type: IndexType.value,
          caseSensitive: false,
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
    ),
    r'sincronizado': IndexSchema(
      id: -5635005241243394166,
      name: r'sincronizado',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sincronizado',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pedidoEntityGetId,
  getLinks: _pedidoEntityGetLinks,
  attach: _pedidoEntityAttach,
  version: '3.1.0+1',
);

int _pedidoEntityEstimateSize(
  PedidoEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.estado.name.length * 3;
  {
    final value = object.observaciones;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.proveedorCedula;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.proveedorEmpresa;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.proveedorNombre.length * 3;
  {
    final value = object.proveedorTelefono;
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
  return bytesCount;
}

void _pedidoEntitySerialize(
  PedidoEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.estado.name);
  writer.writeDateTime(offsets[1], object.fechaPedido);
  writer.writeDateTime(offsets[2], object.fechaSincronizacion);
  writer.writeLong(offsets[3], object.localDestinoId);
  writer.writeLong(offsets[4], object.localOrigenId);
  writer.writeString(offsets[5], object.observaciones);
  writer.writeString(offsets[6], object.proveedorCedula);
  writer.writeString(offsets[7], object.proveedorEmpresa);
  writer.writeString(offsets[8], object.proveedorNombre);
  writer.writeString(offsets[9], object.proveedorTelefono);
  writer.writeBool(offsets[10], object.sincronizado);
  writer.writeString(offsets[11], object.supabaseId);
  writer.writeDouble(offsets[12], object.total);
  writer.writeLong(offsets[13], object.usuarioId);
}

PedidoEntity _pedidoEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PedidoEntity();
  object.estado =
      _PedidoEntityestadoValueEnumMap[reader.readStringOrNull(offsets[0])] ??
          EstadoPedido.pendiente;
  object.fechaPedido = reader.readDateTime(offsets[1]);
  object.fechaSincronizacion = reader.readDateTimeOrNull(offsets[2]);
  object.id = id;
  object.localDestinoId = reader.readLong(offsets[3]);
  object.localOrigenId = reader.readLong(offsets[4]);
  object.observaciones = reader.readStringOrNull(offsets[5]);
  object.proveedorCedula = reader.readStringOrNull(offsets[6]);
  object.proveedorEmpresa = reader.readStringOrNull(offsets[7]);
  object.proveedorNombre = reader.readString(offsets[8]);
  object.proveedorTelefono = reader.readStringOrNull(offsets[9]);
  object.sincronizado = reader.readBool(offsets[10]);
  object.supabaseId = reader.readStringOrNull(offsets[11]);
  object.total = reader.readDouble(offsets[12]);
  object.usuarioId = reader.readLong(offsets[13]);
  return object;
}

P _pedidoEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_PedidoEntityestadoValueEnumMap[
              reader.readStringOrNull(offset)] ??
          EstadoPedido.pendiente) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readDouble(offset)) as P;
    case 13:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _PedidoEntityestadoEnumValueMap = {
  r'pendiente': r'pendiente',
  r'recibido': r'recibido',
  r'cancelado': r'cancelado',
};
const _PedidoEntityestadoValueEnumMap = {
  r'pendiente': EstadoPedido.pendiente,
  r'recibido': EstadoPedido.recibido,
  r'cancelado': EstadoPedido.cancelado,
};

Id _pedidoEntityGetId(PedidoEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pedidoEntityGetLinks(PedidoEntity object) {
  return [];
}

void _pedidoEntityAttach(
    IsarCollection<dynamic> col, Id id, PedidoEntity object) {
  object.id = id;
}

extension PedidoEntityQueryWhereSort
    on QueryBuilder<PedidoEntity, PedidoEntity, QWhere> {
  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhere> anyLocalOrigenId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'localOrigenId'),
      );
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhere> anyLocalDestinoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'localDestinoId'),
      );
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhere> anyUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'usuarioId'),
      );
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhere> anySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sincronizado'),
      );
    });
  }
}

extension PedidoEntityQueryWhere
    on QueryBuilder<PedidoEntity, PedidoEntity, QWhereClause> {
  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause> idBetween(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      localOrigenIdEqualTo(int localOrigenId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'localOrigenId',
        value: [localOrigenId],
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      localOrigenIdNotEqualTo(int localOrigenId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localOrigenId',
              lower: [],
              upper: [localOrigenId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localOrigenId',
              lower: [localOrigenId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localOrigenId',
              lower: [localOrigenId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localOrigenId',
              lower: [],
              upper: [localOrigenId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      localOrigenIdGreaterThan(
    int localOrigenId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'localOrigenId',
        lower: [localOrigenId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      localOrigenIdLessThan(
    int localOrigenId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'localOrigenId',
        lower: [],
        upper: [localOrigenId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      localOrigenIdBetween(
    int lowerLocalOrigenId,
    int upperLocalOrigenId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'localOrigenId',
        lower: [lowerLocalOrigenId],
        includeLower: includeLower,
        upper: [upperLocalOrigenId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      localDestinoIdEqualTo(int localDestinoId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'localDestinoId',
        value: [localDestinoId],
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      localDestinoIdNotEqualTo(int localDestinoId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localDestinoId',
              lower: [],
              upper: [localDestinoId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localDestinoId',
              lower: [localDestinoId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localDestinoId',
              lower: [localDestinoId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'localDestinoId',
              lower: [],
              upper: [localDestinoId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      localDestinoIdGreaterThan(
    int localDestinoId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'localDestinoId',
        lower: [localDestinoId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      localDestinoIdLessThan(
    int localDestinoId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'localDestinoId',
        lower: [],
        upper: [localDestinoId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      localDestinoIdBetween(
    int lowerLocalDestinoId,
    int upperLocalDestinoId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'localDestinoId',
        lower: [lowerLocalDestinoId],
        includeLower: includeLower,
        upper: [upperLocalDestinoId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause> usuarioIdEqualTo(
      int usuarioId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'usuarioId',
        value: [usuarioId],
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      usuarioIdNotEqualTo(int usuarioId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [],
              upper: [usuarioId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [usuarioId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [usuarioId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'usuarioId',
              lower: [],
              upper: [usuarioId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      usuarioIdGreaterThan(
    int usuarioId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'usuarioId',
        lower: [usuarioId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause> usuarioIdLessThan(
    int usuarioId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'usuarioId',
        lower: [],
        upper: [usuarioId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause> usuarioIdBetween(
    int lowerUsuarioId,
    int upperUsuarioId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'usuarioId',
        lower: [lowerUsuarioId],
        includeLower: includeLower,
        upper: [upperUsuarioId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause> estadoEqualTo(
      EstadoPedido estado) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'estado',
        value: [estado],
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause> estadoNotEqualTo(
      EstadoPedido estado) {
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      sincronizadoEqualTo(bool sincronizado) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sincronizado',
        value: [sincronizado],
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterWhereClause>
      sincronizadoNotEqualTo(bool sincronizado) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sincronizado',
              lower: [],
              upper: [sincronizado],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sincronizado',
              lower: [sincronizado],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sincronizado',
              lower: [sincronizado],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sincronizado',
              lower: [],
              upper: [sincronizado],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PedidoEntityQueryFilter
    on QueryBuilder<PedidoEntity, PedidoEntity, QFilterCondition> {
  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition> estadoEqualTo(
    EstadoPedido value, {
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      estadoGreaterThan(
    EstadoPedido value, {
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      estadoLessThan(
    EstadoPedido value, {
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition> estadoBetween(
    EstadoPedido lower,
    EstadoPedido upper, {
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      estadoStartsWith(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      estadoEndsWith(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      estadoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'estado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition> estadoMatches(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      estadoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      estadoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'estado',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      fechaPedidoEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaPedido',
        value: value,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      fechaPedidoGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fechaPedido',
        value: value,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      fechaPedidoLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fechaPedido',
        value: value,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      fechaPedidoBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fechaPedido',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      fechaSincronizacionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      fechaSincronizacionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fechaSincronizacion',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      fechaSincronizacionEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fechaSincronizacion',
        value: value,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      localDestinoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localDestinoId',
        value: value,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      localDestinoIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localDestinoId',
        value: value,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      localDestinoIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localDestinoId',
        value: value,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      localDestinoIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localDestinoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      localOrigenIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'localOrigenId',
        value: value,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      localOrigenIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'localOrigenId',
        value: value,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      localOrigenIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'localOrigenId',
        value: value,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      localOrigenIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'localOrigenId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      observacionesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'observaciones',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      observacionesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'observaciones',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      observacionesEqualTo(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      observacionesGreaterThan(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      observacionesLessThan(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      observacionesBetween(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      observacionesStartsWith(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      observacionesEndsWith(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      observacionesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'observaciones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      observacionesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'observaciones',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      observacionesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'observaciones',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      observacionesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'observaciones',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorCedulaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'proveedorCedula',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorCedulaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'proveedorCedula',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorCedulaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorCedula',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorCedulaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proveedorCedula',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorCedulaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proveedorCedula',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorCedulaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proveedorCedula',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorCedulaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'proveedorCedula',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorCedulaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'proveedorCedula',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorCedulaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'proveedorCedula',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorCedulaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'proveedorCedula',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorCedulaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorCedula',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorCedulaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'proveedorCedula',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorEmpresaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'proveedorEmpresa',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorEmpresaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'proveedorEmpresa',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorEmpresaEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorEmpresa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorEmpresaGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proveedorEmpresa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorEmpresaLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proveedorEmpresa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorEmpresaBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proveedorEmpresa',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorEmpresaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'proveedorEmpresa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorEmpresaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'proveedorEmpresa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorEmpresaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'proveedorEmpresa',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorEmpresaMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'proveedorEmpresa',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorEmpresaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorEmpresa',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorEmpresaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'proveedorEmpresa',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorNombreEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorNombreGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proveedorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorNombreLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proveedorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorNombreBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proveedorNombre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorNombreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'proveedorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorNombreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'proveedorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'proveedorNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'proveedorNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'proveedorNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorTelefonoIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'proveedorTelefono',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorTelefonoIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'proveedorTelefono',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorTelefonoEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorTelefonoGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proveedorTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorTelefonoLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proveedorTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorTelefonoBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proveedorTelefono',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorTelefonoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'proveedorTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorTelefonoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'proveedorTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorTelefonoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'proveedorTelefono',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorTelefonoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'proveedorTelefono',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorTelefonoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proveedorTelefono',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      proveedorTelefonoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'proveedorTelefono',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      sincronizadoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sincronizado',
        value: value,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      supabaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      supabaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition> totalEqualTo(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition> totalLessThan(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition> totalBetween(
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      usuarioIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioId',
        value: value,
      ));
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      usuarioIdGreaterThan(
    int value, {
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      usuarioIdLessThan(
    int value, {
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

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterFilterCondition>
      usuarioIdBetween(
    int lower,
    int upper, {
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
}

extension PedidoEntityQueryObject
    on QueryBuilder<PedidoEntity, PedidoEntity, QFilterCondition> {}

extension PedidoEntityQueryLinks
    on QueryBuilder<PedidoEntity, PedidoEntity, QFilterCondition> {}

extension PedidoEntityQuerySortBy
    on QueryBuilder<PedidoEntity, PedidoEntity, QSortBy> {
  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> sortByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> sortByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> sortByFechaPedido() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaPedido', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByFechaPedidoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaPedido', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByLocalDestinoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localDestinoId', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByLocalDestinoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localDestinoId', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> sortByLocalOrigenId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localOrigenId', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByLocalOrigenIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localOrigenId', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> sortByObservaciones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByObservacionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByProveedorCedula() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorCedula', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByProveedorCedulaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorCedula', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByProveedorEmpresa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorEmpresa', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByProveedorEmpresaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorEmpresa', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByProveedorNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorNombre', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByProveedorNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorNombre', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByProveedorTelefono() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorTelefono', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortByProveedorTelefonoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorTelefono', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> sortBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> sortByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> sortByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> sortByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> sortByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension PedidoEntityQuerySortThenBy
    on QueryBuilder<PedidoEntity, PedidoEntity, QSortThenBy> {
  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> thenByEstado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> thenByEstadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'estado', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> thenByFechaPedido() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaPedido', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByFechaPedidoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaPedido', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByFechaSincronizacionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fechaSincronizacion', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByLocalDestinoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localDestinoId', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByLocalDestinoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localDestinoId', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> thenByLocalOrigenId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localOrigenId', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByLocalOrigenIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'localOrigenId', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> thenByObservaciones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByObservacionesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'observaciones', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByProveedorCedula() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorCedula', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByProveedorCedulaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorCedula', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByProveedorEmpresa() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorEmpresa', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByProveedorEmpresaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorEmpresa', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByProveedorNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorNombre', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByProveedorNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorNombre', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByProveedorTelefono() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorTelefono', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenByProveedorTelefonoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proveedorTelefono', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> thenBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy>
      thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> thenByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> thenByTotalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'total', Sort.desc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> thenByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.asc);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QAfterSortBy> thenByUsuarioIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioId', Sort.desc);
    });
  }
}

extension PedidoEntityQueryWhereDistinct
    on QueryBuilder<PedidoEntity, PedidoEntity, QDistinct> {
  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct> distinctByEstado(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'estado', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct> distinctByFechaPedido() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaPedido');
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct>
      distinctByFechaSincronizacion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fechaSincronizacion');
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct>
      distinctByLocalDestinoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localDestinoId');
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct>
      distinctByLocalOrigenId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'localOrigenId');
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct> distinctByObservaciones(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'observaciones',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct> distinctByProveedorCedula(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proveedorCedula',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct>
      distinctByProveedorEmpresa({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proveedorEmpresa',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct> distinctByProveedorNombre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proveedorNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct>
      distinctByProveedorTelefono({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proveedorTelefono',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct> distinctBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sincronizado');
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct> distinctBySupabaseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct> distinctByTotal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'total');
    });
  }

  QueryBuilder<PedidoEntity, PedidoEntity, QDistinct> distinctByUsuarioId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioId');
    });
  }
}

extension PedidoEntityQueryProperty
    on QueryBuilder<PedidoEntity, PedidoEntity, QQueryProperty> {
  QueryBuilder<PedidoEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PedidoEntity, EstadoPedido, QQueryOperations> estadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'estado');
    });
  }

  QueryBuilder<PedidoEntity, DateTime, QQueryOperations> fechaPedidoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaPedido');
    });
  }

  QueryBuilder<PedidoEntity, DateTime?, QQueryOperations>
      fechaSincronizacionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fechaSincronizacion');
    });
  }

  QueryBuilder<PedidoEntity, int, QQueryOperations> localDestinoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localDestinoId');
    });
  }

  QueryBuilder<PedidoEntity, int, QQueryOperations> localOrigenIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'localOrigenId');
    });
  }

  QueryBuilder<PedidoEntity, String?, QQueryOperations>
      observacionesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'observaciones');
    });
  }

  QueryBuilder<PedidoEntity, String?, QQueryOperations>
      proveedorCedulaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proveedorCedula');
    });
  }

  QueryBuilder<PedidoEntity, String?, QQueryOperations>
      proveedorEmpresaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proveedorEmpresa');
    });
  }

  QueryBuilder<PedidoEntity, String, QQueryOperations>
      proveedorNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proveedorNombre');
    });
  }

  QueryBuilder<PedidoEntity, String?, QQueryOperations>
      proveedorTelefonoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proveedorTelefono');
    });
  }

  QueryBuilder<PedidoEntity, bool, QQueryOperations> sincronizadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sincronizado');
    });
  }

  QueryBuilder<PedidoEntity, String?, QQueryOperations> supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<PedidoEntity, double, QQueryOperations> totalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'total');
    });
  }

  QueryBuilder<PedidoEntity, int, QQueryOperations> usuarioIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioId');
    });
  }
}
