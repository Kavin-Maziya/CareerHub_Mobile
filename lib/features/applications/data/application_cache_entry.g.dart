// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'application_cache_entry.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetApplicationCacheEntryCollection on Isar {
  IsarCollection<ApplicationCacheEntry> get applicationCacheEntrys =>
      this.collection();
}

const ApplicationCacheEntrySchema = CollectionSchema(
  name: r'ApplicationCacheEntry',
  id: 734851948631662707,
  properties: {
    r'applicationId': PropertySchema(
      id: 0,
      name: r'applicationId',
      type: IsarType.string,
    ),
    r'jobTitle': PropertySchema(
      id: 1,
      name: r'jobTitle',
      type: IsarType.string,
    ),
    r'status': PropertySchema(id: 2, name: r'status', type: IsarType.string),
    r'submittedAt': PropertySchema(
      id: 3,
      name: r'submittedAt',
      type: IsarType.dateTime,
    ),
  },

  estimateSize: _applicationCacheEntryEstimateSize,
  serialize: _applicationCacheEntrySerialize,
  deserialize: _applicationCacheEntryDeserialize,
  deserializeProp: _applicationCacheEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'applicationId': IndexSchema(
      id: -6637474116175318442,
      name: r'applicationId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'applicationId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _applicationCacheEntryGetId,
  getLinks: _applicationCacheEntryGetLinks,
  attach: _applicationCacheEntryAttach,
  version: '3.3.2',
);

int _applicationCacheEntryEstimateSize(
  ApplicationCacheEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.applicationId.length * 3;
  bytesCount += 3 + object.jobTitle.length * 3;
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _applicationCacheEntrySerialize(
  ApplicationCacheEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.applicationId);
  writer.writeString(offsets[1], object.jobTitle);
  writer.writeString(offsets[2], object.status);
  writer.writeDateTime(offsets[3], object.submittedAt);
}

ApplicationCacheEntry _applicationCacheEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ApplicationCacheEntry();
  object.applicationId = reader.readString(offsets[0]);
  object.id = id;
  object.jobTitle = reader.readString(offsets[1]);
  object.status = reader.readString(offsets[2]);
  object.submittedAt = reader.readDateTime(offsets[3]);
  return object;
}

P _applicationCacheEntryDeserializeProp<P>(
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
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _applicationCacheEntryGetId(ApplicationCacheEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _applicationCacheEntryGetLinks(
  ApplicationCacheEntry object,
) {
  return [];
}

void _applicationCacheEntryAttach(
  IsarCollection<dynamic> col,
  Id id,
  ApplicationCacheEntry object,
) {
  object.id = id;
}

extension ApplicationCacheEntryByIndex
    on IsarCollection<ApplicationCacheEntry> {
  Future<ApplicationCacheEntry?> getByApplicationId(String applicationId) {
    return getByIndex(r'applicationId', [applicationId]);
  }

  ApplicationCacheEntry? getByApplicationIdSync(String applicationId) {
    return getByIndexSync(r'applicationId', [applicationId]);
  }

  Future<bool> deleteByApplicationId(String applicationId) {
    return deleteByIndex(r'applicationId', [applicationId]);
  }

  bool deleteByApplicationIdSync(String applicationId) {
    return deleteByIndexSync(r'applicationId', [applicationId]);
  }

  Future<List<ApplicationCacheEntry?>> getAllByApplicationId(
    List<String> applicationIdValues,
  ) {
    final values = applicationIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'applicationId', values);
  }

  List<ApplicationCacheEntry?> getAllByApplicationIdSync(
    List<String> applicationIdValues,
  ) {
    final values = applicationIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'applicationId', values);
  }

  Future<int> deleteAllByApplicationId(List<String> applicationIdValues) {
    final values = applicationIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'applicationId', values);
  }

  int deleteAllByApplicationIdSync(List<String> applicationIdValues) {
    final values = applicationIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'applicationId', values);
  }

  Future<Id> putByApplicationId(ApplicationCacheEntry object) {
    return putByIndex(r'applicationId', object);
  }

  Id putByApplicationIdSync(
    ApplicationCacheEntry object, {
    bool saveLinks = true,
  }) {
    return putByIndexSync(r'applicationId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByApplicationId(List<ApplicationCacheEntry> objects) {
    return putAllByIndex(r'applicationId', objects);
  }

  List<Id> putAllByApplicationIdSync(
    List<ApplicationCacheEntry> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'applicationId', objects, saveLinks: saveLinks);
  }
}

extension ApplicationCacheEntryQueryWhereSort
    on QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QWhere> {
  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterWhere>
  anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ApplicationCacheEntryQueryWhere
    on
        QueryBuilder<
          ApplicationCacheEntry,
          ApplicationCacheEntry,
          QWhereClause
        > {
  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterWhereClause>
  idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterWhereClause>
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

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterWhereClause>
  idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterWhereClause>
  idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterWhereClause>
  applicationIdEqualTo(String applicationId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(
          indexName: r'applicationId',
          value: [applicationId],
        ),
      );
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterWhereClause>
  applicationIdNotEqualTo(String applicationId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'applicationId',
                lower: [],
                upper: [applicationId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'applicationId',
                lower: [applicationId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'applicationId',
                lower: [applicationId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'applicationId',
                lower: [],
                upper: [applicationId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension ApplicationCacheEntryQueryFilter
    on
        QueryBuilder<
          ApplicationCacheEntry,
          ApplicationCacheEntry,
          QFilterCondition
        > {
  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  applicationIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'applicationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  applicationIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'applicationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  applicationIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'applicationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  applicationIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'applicationId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  applicationIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'applicationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  applicationIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'applicationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  applicationIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'applicationId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  applicationIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'applicationId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  applicationIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'applicationId', value: ''),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  applicationIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'applicationId', value: ''),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  idLessThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  jobTitleEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'jobTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  jobTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'jobTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  jobTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'jobTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  jobTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'jobTitle',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  jobTitleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'jobTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  jobTitleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'jobTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  jobTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'jobTitle',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  jobTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'jobTitle',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  jobTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'jobTitle', value: ''),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  jobTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'jobTitle', value: ''),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  statusEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  statusStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  statusEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  submittedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'submittedAt', value: value),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  submittedAtGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'submittedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  submittedAtLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'submittedAt',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<
    ApplicationCacheEntry,
    ApplicationCacheEntry,
    QAfterFilterCondition
  >
  submittedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'submittedAt',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension ApplicationCacheEntryQueryObject
    on
        QueryBuilder<
          ApplicationCacheEntry,
          ApplicationCacheEntry,
          QFilterCondition
        > {}

extension ApplicationCacheEntryQueryLinks
    on
        QueryBuilder<
          ApplicationCacheEntry,
          ApplicationCacheEntry,
          QFilterCondition
        > {}

extension ApplicationCacheEntryQuerySortBy
    on QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QSortBy> {
  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  sortByApplicationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applicationId', Sort.asc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  sortByApplicationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applicationId', Sort.desc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  sortByJobTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobTitle', Sort.asc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  sortByJobTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobTitle', Sort.desc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  sortBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  sortBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }
}

extension ApplicationCacheEntryQuerySortThenBy
    on QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QSortThenBy> {
  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  thenByApplicationId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applicationId', Sort.asc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  thenByApplicationIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'applicationId', Sort.desc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  thenByJobTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobTitle', Sort.asc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  thenByJobTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'jobTitle', Sort.desc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  thenBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.asc);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QAfterSortBy>
  thenBySubmittedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'submittedAt', Sort.desc);
    });
  }
}

extension ApplicationCacheEntryQueryWhereDistinct
    on QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QDistinct> {
  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QDistinct>
  distinctByApplicationId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'applicationId',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QDistinct>
  distinctByJobTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'jobTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QDistinct>
  distinctByStatus({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ApplicationCacheEntry, ApplicationCacheEntry, QDistinct>
  distinctBySubmittedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'submittedAt');
    });
  }
}

extension ApplicationCacheEntryQueryProperty
    on
        QueryBuilder<
          ApplicationCacheEntry,
          ApplicationCacheEntry,
          QQueryProperty
        > {
  QueryBuilder<ApplicationCacheEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ApplicationCacheEntry, String, QQueryOperations>
  applicationIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'applicationId');
    });
  }

  QueryBuilder<ApplicationCacheEntry, String, QQueryOperations>
  jobTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'jobTitle');
    });
  }

  QueryBuilder<ApplicationCacheEntry, String, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<ApplicationCacheEntry, DateTime, QQueryOperations>
  submittedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'submittedAt');
    });
  }
}
