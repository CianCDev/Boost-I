// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_entity.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLogEntityCollection on Isar {
  IsarCollection<LogEntity> get logEntitys => this.collection();
}

const LogEntitySchema = CollectionSchema(
  name: r'LogEntity',
  id: 3974793294907107472,
  properties: {
    r'accion': PropertySchema(
      id: 0,
      name: r'accion',
      type: IsarType.string,
    ),
    r'detalles': PropertySchema(
      id: 1,
      name: r'detalles',
      type: IsarType.string,
    ),
    r'fecha': PropertySchema(
      id: 2,
      name: r'fecha',
      type: IsarType.dateTime,
    ),
    r'sincronizado': PropertySchema(
      id: 3,
      name: r'sincronizado',
      type: IsarType.bool,
    ),
    r'usuarioNombre': PropertySchema(
      id: 4,
      name: r'usuarioNombre',
      type: IsarType.string,
    ),
    r'usuarioRol': PropertySchema(
      id: 5,
      name: r'usuarioRol',
      type: IsarType.string,
    )
  },
  estimateSize: _logEntityEstimateSize,
  serialize: _logEntitySerialize,
  deserialize: _logEntityDeserialize,
  deserializeProp: _logEntityDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _logEntityGetId,
  getLinks: _logEntityGetLinks,
  attach: _logEntityAttach,
  version: '3.1.0+1',
);

int _logEntityEstimateSize(
  LogEntity object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.accion.length * 3;
  {
    final value = object.detalles;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.usuarioNombre.length * 3;
  bytesCount += 3 + object.usuarioRol.length * 3;
  return bytesCount;
}

void _logEntitySerialize(
  LogEntity object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accion);
  writer.writeString(offsets[1], object.detalles);
  writer.writeDateTime(offsets[2], object.fecha);
  writer.writeBool(offsets[3], object.sincronizado);
  writer.writeString(offsets[4], object.usuarioNombre);
  writer.writeString(offsets[5], object.usuarioRol);
}

LogEntity _logEntityDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LogEntity();
  object.accion = reader.readString(offsets[0]);
  object.detalles = reader.readStringOrNull(offsets[1]);
  object.fecha = reader.readDateTime(offsets[2]);
  object.id = id;
  object.sincronizado = reader.readBool(offsets[3]);
  object.usuarioNombre = reader.readString(offsets[4]);
  object.usuarioRol = reader.readString(offsets[5]);
  return object;
}

P _logEntityDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _logEntityGetId(LogEntity object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _logEntityGetLinks(LogEntity object) {
  return [];
}

void _logEntityAttach(IsarCollection<dynamic> col, Id id, LogEntity object) {
  object.id = id;
}

extension LogEntityQueryWhereSort
    on QueryBuilder<LogEntity, LogEntity, QWhere> {
  QueryBuilder<LogEntity, LogEntity, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LogEntityQueryWhere
    on QueryBuilder<LogEntity, LogEntity, QWhereClause> {
  QueryBuilder<LogEntity, LogEntity, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<LogEntity, LogEntity, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterWhereClause> idBetween(
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

extension LogEntityQueryFilter
    on QueryBuilder<LogEntity, LogEntity, QFilterCondition> {
  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> accionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> accionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> accionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> accionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> accionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> accionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> accionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> accionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> accionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accion',
        value: '',
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> accionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accion',
        value: '',
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> detallesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'detalles',
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      detallesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'detalles',
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> detallesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detalles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> detallesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'detalles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> detallesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'detalles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> detallesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'detalles',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> detallesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'detalles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> detallesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'detalles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> detallesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'detalles',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> detallesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'detalles',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> detallesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'detalles',
        value: '',
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      detallesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'detalles',
        value: '',
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> fechaEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fecha',
        value: value,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> fechaGreaterThan(
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

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> fechaLessThan(
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

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> fechaBetween(
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

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> sincronizadoEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sincronizado',
        value: value,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioNombreEqualTo(
    String value, {
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

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioNombreGreaterThan(
    String value, {
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

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioNombreLessThan(
    String value, {
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

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioNombreBetween(
    String lower,
    String upper, {
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

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioNombreStartsWith(
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

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioNombreEndsWith(
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

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioNombreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioNombre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioNombreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioNombre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioNombreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioNombreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioNombre',
        value: '',
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> usuarioRolEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioRolGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'usuarioRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> usuarioRolLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'usuarioRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> usuarioRolBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'usuarioRol',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioRolStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'usuarioRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> usuarioRolEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'usuarioRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> usuarioRolContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'usuarioRol',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition> usuarioRolMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'usuarioRol',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioRolIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'usuarioRol',
        value: '',
      ));
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterFilterCondition>
      usuarioRolIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'usuarioRol',
        value: '',
      ));
    });
  }
}

extension LogEntityQueryObject
    on QueryBuilder<LogEntity, LogEntity, QFilterCondition> {}

extension LogEntityQueryLinks
    on QueryBuilder<LogEntity, LogEntity, QFilterCondition> {}

extension LogEntityQuerySortBy on QueryBuilder<LogEntity, LogEntity, QSortBy> {
  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> sortByAccion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accion', Sort.asc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> sortByAccionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accion', Sort.desc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> sortByDetalles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detalles', Sort.asc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> sortByDetallesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detalles', Sort.desc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> sortByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> sortByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> sortBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> sortBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> sortByUsuarioNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.asc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> sortByUsuarioNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.desc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> sortByUsuarioRol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRol', Sort.asc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> sortByUsuarioRolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRol', Sort.desc);
    });
  }
}

extension LogEntityQuerySortThenBy
    on QueryBuilder<LogEntity, LogEntity, QSortThenBy> {
  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenByAccion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accion', Sort.asc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenByAccionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accion', Sort.desc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenByDetalles() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detalles', Sort.asc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenByDetallesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'detalles', Sort.desc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.asc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenByFechaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fecha', Sort.desc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.asc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenBySincronizadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sincronizado', Sort.desc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenByUsuarioNombre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.asc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenByUsuarioNombreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioNombre', Sort.desc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenByUsuarioRol() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRol', Sort.asc);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QAfterSortBy> thenByUsuarioRolDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'usuarioRol', Sort.desc);
    });
  }
}

extension LogEntityQueryWhereDistinct
    on QueryBuilder<LogEntity, LogEntity, QDistinct> {
  QueryBuilder<LogEntity, LogEntity, QDistinct> distinctByAccion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QDistinct> distinctByDetalles(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'detalles', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QDistinct> distinctByFecha() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fecha');
    });
  }

  QueryBuilder<LogEntity, LogEntity, QDistinct> distinctBySincronizado() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sincronizado');
    });
  }

  QueryBuilder<LogEntity, LogEntity, QDistinct> distinctByUsuarioNombre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioNombre',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LogEntity, LogEntity, QDistinct> distinctByUsuarioRol(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'usuarioRol', caseSensitive: caseSensitive);
    });
  }
}

extension LogEntityQueryProperty
    on QueryBuilder<LogEntity, LogEntity, QQueryProperty> {
  QueryBuilder<LogEntity, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LogEntity, String, QQueryOperations> accionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accion');
    });
  }

  QueryBuilder<LogEntity, String?, QQueryOperations> detallesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'detalles');
    });
  }

  QueryBuilder<LogEntity, DateTime, QQueryOperations> fechaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fecha');
    });
  }

  QueryBuilder<LogEntity, bool, QQueryOperations> sincronizadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sincronizado');
    });
  }

  QueryBuilder<LogEntity, String, QQueryOperations> usuarioNombreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioNombre');
    });
  }

  QueryBuilder<LogEntity, String, QQueryOperations> usuarioRolProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'usuarioRol');
    });
  }
}
