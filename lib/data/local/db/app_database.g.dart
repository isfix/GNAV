// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MountainRegionsTable extends MountainRegions
    with TableInfo<$MountainRegionsTable, MountainRegion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MountainRegionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _localMapPathMeta =
      const VerificationMeta('localMapPath');
  @override
  late final GeneratedColumn<String> localMapPath = GeneratedColumn<String>(
      'local_map_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _boundaryJsonMeta =
      const VerificationMeta('boundaryJson');
  @override
  late final GeneratedColumn<String> boundaryJson = GeneratedColumn<String>(
      'boundary_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _isDownloadedMeta =
      const VerificationMeta('isDownloaded');
  @override
  late final GeneratedColumn<bool> isDownloaded = GeneratedColumn<bool>(
      'is_downloaded', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_downloaded" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        localMapPath,
        boundaryJson,
        lat,
        lng,
        version,
        isDownloaded
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mountain_regions';
  @override
  VerificationContext validateIntegrity(Insertable<MountainRegion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('local_map_path')) {
      context.handle(
          _localMapPathMeta,
          localMapPath.isAcceptableOrUnknown(
              data['local_map_path']!, _localMapPathMeta));
    }
    if (data.containsKey('boundary_json')) {
      context.handle(
          _boundaryJsonMeta,
          boundaryJson.isAcceptableOrUnknown(
              data['boundary_json']!, _boundaryJsonMeta));
    } else if (isInserting) {
      context.missing(_boundaryJsonMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    }
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('is_downloaded')) {
      context.handle(
          _isDownloadedMeta,
          isDownloaded.isAcceptableOrUnknown(
              data['is_downloaded']!, _isDownloadedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MountainRegion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MountainRegion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      localMapPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_map_path']),
      boundaryJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}boundary_json'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version'])!,
      isDownloaded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_downloaded'])!,
    );
  }

  @override
  $MountainRegionsTable createAlias(String alias) {
    return $MountainRegionsTable(attachedDatabase, alias);
  }
}

class MountainRegion extends DataClass implements Insertable<MountainRegion> {
  final String id;
  final String name;
  final String? description;
  final String? localMapPath;
  final String boundaryJson;
  final double lat;
  final double lng;
  final int version;
  final bool isDownloaded;
  const MountainRegion(
      {required this.id,
      required this.name,
      this.description,
      this.localMapPath,
      required this.boundaryJson,
      required this.lat,
      required this.lng,
      required this.version,
      required this.isDownloaded});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || localMapPath != null) {
      map['local_map_path'] = Variable<String>(localMapPath);
    }
    map['boundary_json'] = Variable<String>(boundaryJson);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['version'] = Variable<int>(version);
    map['is_downloaded'] = Variable<bool>(isDownloaded);
    return map;
  }

  MountainRegionsCompanion toCompanion(bool nullToAbsent) {
    return MountainRegionsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      localMapPath: localMapPath == null && nullToAbsent
          ? const Value.absent()
          : Value(localMapPath),
      boundaryJson: Value(boundaryJson),
      lat: Value(lat),
      lng: Value(lng),
      version: Value(version),
      isDownloaded: Value(isDownloaded),
    );
  }

  factory MountainRegion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MountainRegion(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      localMapPath: serializer.fromJson<String?>(json['localMapPath']),
      boundaryJson: serializer.fromJson<String>(json['boundaryJson']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      version: serializer.fromJson<int>(json['version']),
      isDownloaded: serializer.fromJson<bool>(json['isDownloaded']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'localMapPath': serializer.toJson<String?>(localMapPath),
      'boundaryJson': serializer.toJson<String>(boundaryJson),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'version': serializer.toJson<int>(version),
      'isDownloaded': serializer.toJson<bool>(isDownloaded),
    };
  }

  MountainRegion copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> localMapPath = const Value.absent(),
          String? boundaryJson,
          double? lat,
          double? lng,
          int? version,
          bool? isDownloaded}) =>
      MountainRegion(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        localMapPath:
            localMapPath.present ? localMapPath.value : this.localMapPath,
        boundaryJson: boundaryJson ?? this.boundaryJson,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        version: version ?? this.version,
        isDownloaded: isDownloaded ?? this.isDownloaded,
      );
  MountainRegion copyWithCompanion(MountainRegionsCompanion data) {
    return MountainRegion(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      localMapPath: data.localMapPath.present
          ? data.localMapPath.value
          : this.localMapPath,
      boundaryJson: data.boundaryJson.present
          ? data.boundaryJson.value
          : this.boundaryJson,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      version: data.version.present ? data.version.value : this.version,
      isDownloaded: data.isDownloaded.present
          ? data.isDownloaded.value
          : this.isDownloaded,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MountainRegion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('localMapPath: $localMapPath, ')
          ..write('boundaryJson: $boundaryJson, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('version: $version, ')
          ..write('isDownloaded: $isDownloaded')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, localMapPath,
      boundaryJson, lat, lng, version, isDownloaded);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MountainRegion &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.localMapPath == this.localMapPath &&
          other.boundaryJson == this.boundaryJson &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.version == this.version &&
          other.isDownloaded == this.isDownloaded);
}

class MountainRegionsCompanion extends UpdateCompanion<MountainRegion> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> localMapPath;
  final Value<String> boundaryJson;
  final Value<double> lat;
  final Value<double> lng;
  final Value<int> version;
  final Value<bool> isDownloaded;
  final Value<int> rowid;
  const MountainRegionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.localMapPath = const Value.absent(),
    this.boundaryJson = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.version = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MountainRegionsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.localMapPath = const Value.absent(),
    required String boundaryJson,
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.version = const Value.absent(),
    this.isDownloaded = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        boundaryJson = Value(boundaryJson);
  static Insertable<MountainRegion> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? localMapPath,
    Expression<String>? boundaryJson,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<int>? version,
    Expression<bool>? isDownloaded,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (localMapPath != null) 'local_map_path': localMapPath,
      if (boundaryJson != null) 'boundary_json': boundaryJson,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (version != null) 'version': version,
      if (isDownloaded != null) 'is_downloaded': isDownloaded,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MountainRegionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? localMapPath,
      Value<String>? boundaryJson,
      Value<double>? lat,
      Value<double>? lng,
      Value<int>? version,
      Value<bool>? isDownloaded,
      Value<int>? rowid}) {
    return MountainRegionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      localMapPath: localMapPath ?? this.localMapPath,
      boundaryJson: boundaryJson ?? this.boundaryJson,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      version: version ?? this.version,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (localMapPath.present) {
      map['local_map_path'] = Variable<String>(localMapPath.value);
    }
    if (boundaryJson.present) {
      map['boundary_json'] = Variable<String>(boundaryJson.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDownloaded.present) {
      map['is_downloaded'] = Variable<bool>(isDownloaded.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MountainRegionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('localMapPath: $localMapPath, ')
          ..write('boundaryJson: $boundaryJson, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('version: $version, ')
          ..write('isDownloaded: $isDownloaded, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrailsTable extends Trails with TableInfo<$TrailsTable, Trail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mountainIdMeta =
      const VerificationMeta('mountainId');
  @override
  late final GeneratedColumn<String> mountainId = GeneratedColumn<String>(
      'mountain_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES mountain_regions (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<List<TrailPoint>, String>
      geometryJson = GeneratedColumn<String>(
              'geometry_json', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<List<TrailPoint>>($TrailsTable.$convertergeometryJson);
  static const VerificationMeta _distanceMeta =
      const VerificationMeta('distance');
  @override
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
      'distance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _elevationGainMeta =
      const VerificationMeta('elevationGain');
  @override
  late final GeneratedColumn<double> elevationGain = GeneratedColumn<double>(
      'elevation_gain', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _summitIndexMeta =
      const VerificationMeta('summitIndex');
  @override
  late final GeneratedColumn<int> summitIndex = GeneratedColumn<int>(
      'summit_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _minLatMeta = const VerificationMeta('minLat');
  @override
  late final GeneratedColumn<double> minLat = GeneratedColumn<double>(
      'min_lat', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _maxLatMeta = const VerificationMeta('maxLat');
  @override
  late final GeneratedColumn<double> maxLat = GeneratedColumn<double>(
      'max_lat', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _minLngMeta = const VerificationMeta('minLng');
  @override
  late final GeneratedColumn<double> minLng = GeneratedColumn<double>(
      'min_lng', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _maxLngMeta = const VerificationMeta('maxLng');
  @override
  late final GeneratedColumn<double> maxLng = GeneratedColumn<double>(
      'max_lng', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _startLatMeta =
      const VerificationMeta('startLat');
  @override
  late final GeneratedColumn<double> startLat = GeneratedColumn<double>(
      'start_lat', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _startLngMeta =
      const VerificationMeta('startLng');
  @override
  late final GeneratedColumn<double> startLng = GeneratedColumn<double>(
      'start_lng', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _isOfficialMeta =
      const VerificationMeta('isOfficial');
  @override
  late final GeneratedColumn<bool> isOfficial = GeneratedColumn<bool>(
      'is_official', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_official" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        mountainId,
        name,
        geometryJson,
        distance,
        elevationGain,
        difficulty,
        summitIndex,
        minLat,
        maxLat,
        minLng,
        maxLng,
        startLat,
        startLng,
        isOfficial
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trails';
  @override
  VerificationContext validateIntegrity(Insertable<Trail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mountain_id')) {
      context.handle(
          _mountainIdMeta,
          mountainId.isAcceptableOrUnknown(
              data['mountain_id']!, _mountainIdMeta));
    } else if (isInserting) {
      context.missing(_mountainIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('distance')) {
      context.handle(_distanceMeta,
          distance.isAcceptableOrUnknown(data['distance']!, _distanceMeta));
    }
    if (data.containsKey('elevation_gain')) {
      context.handle(
          _elevationGainMeta,
          elevationGain.isAcceptableOrUnknown(
              data['elevation_gain']!, _elevationGainMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('summit_index')) {
      context.handle(
          _summitIndexMeta,
          summitIndex.isAcceptableOrUnknown(
              data['summit_index']!, _summitIndexMeta));
    }
    if (data.containsKey('min_lat')) {
      context.handle(_minLatMeta,
          minLat.isAcceptableOrUnknown(data['min_lat']!, _minLatMeta));
    }
    if (data.containsKey('max_lat')) {
      context.handle(_maxLatMeta,
          maxLat.isAcceptableOrUnknown(data['max_lat']!, _maxLatMeta));
    }
    if (data.containsKey('min_lng')) {
      context.handle(_minLngMeta,
          minLng.isAcceptableOrUnknown(data['min_lng']!, _minLngMeta));
    }
    if (data.containsKey('max_lng')) {
      context.handle(_maxLngMeta,
          maxLng.isAcceptableOrUnknown(data['max_lng']!, _maxLngMeta));
    }
    if (data.containsKey('start_lat')) {
      context.handle(_startLatMeta,
          startLat.isAcceptableOrUnknown(data['start_lat']!, _startLatMeta));
    }
    if (data.containsKey('start_lng')) {
      context.handle(_startLngMeta,
          startLng.isAcceptableOrUnknown(data['start_lng']!, _startLngMeta));
    }
    if (data.containsKey('is_official')) {
      context.handle(
          _isOfficialMeta,
          isOfficial.isAcceptableOrUnknown(
              data['is_official']!, _isOfficialMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trail(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mountainId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mountain_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      geometryJson: $TrailsTable.$convertergeometryJson.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}geometry_json'])!),
      distance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance'])!,
      elevationGain: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}elevation_gain'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}difficulty'])!,
      summitIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}summit_index'])!,
      minLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}min_lat'])!,
      maxLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}max_lat'])!,
      minLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}min_lng'])!,
      maxLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}max_lng'])!,
      startLat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}start_lat']),
      startLng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}start_lng']),
      isOfficial: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_official'])!,
    );
  }

  @override
  $TrailsTable createAlias(String alias) {
    return $TrailsTable(attachedDatabase, alias);
  }

  static TypeConverter<List<TrailPoint>, String> $convertergeometryJson =
      const GeoJsonConverter();
}

class Trail extends DataClass implements Insertable<Trail> {
  final String id;
  final String mountainId;
  final String name;
  final List<TrailPoint> geometryJson;
  final double distance;
  final double elevationGain;
  final int difficulty;
  final int summitIndex;
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;
  final double? startLat;
  final double? startLng;
  final bool isOfficial;
  const Trail(
      {required this.id,
      required this.mountainId,
      required this.name,
      required this.geometryJson,
      required this.distance,
      required this.elevationGain,
      required this.difficulty,
      required this.summitIndex,
      required this.minLat,
      required this.maxLat,
      required this.minLng,
      required this.maxLng,
      this.startLat,
      this.startLng,
      required this.isOfficial});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mountain_id'] = Variable<String>(mountainId);
    map['name'] = Variable<String>(name);
    {
      map['geometry_json'] = Variable<String>(
          $TrailsTable.$convertergeometryJson.toSql(geometryJson));
    }
    map['distance'] = Variable<double>(distance);
    map['elevation_gain'] = Variable<double>(elevationGain);
    map['difficulty'] = Variable<int>(difficulty);
    map['summit_index'] = Variable<int>(summitIndex);
    map['min_lat'] = Variable<double>(minLat);
    map['max_lat'] = Variable<double>(maxLat);
    map['min_lng'] = Variable<double>(minLng);
    map['max_lng'] = Variable<double>(maxLng);
    if (!nullToAbsent || startLat != null) {
      map['start_lat'] = Variable<double>(startLat);
    }
    if (!nullToAbsent || startLng != null) {
      map['start_lng'] = Variable<double>(startLng);
    }
    map['is_official'] = Variable<bool>(isOfficial);
    return map;
  }

  TrailsCompanion toCompanion(bool nullToAbsent) {
    return TrailsCompanion(
      id: Value(id),
      mountainId: Value(mountainId),
      name: Value(name),
      geometryJson: Value(geometryJson),
      distance: Value(distance),
      elevationGain: Value(elevationGain),
      difficulty: Value(difficulty),
      summitIndex: Value(summitIndex),
      minLat: Value(minLat),
      maxLat: Value(maxLat),
      minLng: Value(minLng),
      maxLng: Value(maxLng),
      startLat: startLat == null && nullToAbsent
          ? const Value.absent()
          : Value(startLat),
      startLng: startLng == null && nullToAbsent
          ? const Value.absent()
          : Value(startLng),
      isOfficial: Value(isOfficial),
    );
  }

  factory Trail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trail(
      id: serializer.fromJson<String>(json['id']),
      mountainId: serializer.fromJson<String>(json['mountainId']),
      name: serializer.fromJson<String>(json['name']),
      geometryJson: serializer.fromJson<List<TrailPoint>>(json['geometryJson']),
      distance: serializer.fromJson<double>(json['distance']),
      elevationGain: serializer.fromJson<double>(json['elevationGain']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      summitIndex: serializer.fromJson<int>(json['summitIndex']),
      minLat: serializer.fromJson<double>(json['minLat']),
      maxLat: serializer.fromJson<double>(json['maxLat']),
      minLng: serializer.fromJson<double>(json['minLng']),
      maxLng: serializer.fromJson<double>(json['maxLng']),
      startLat: serializer.fromJson<double?>(json['startLat']),
      startLng: serializer.fromJson<double?>(json['startLng']),
      isOfficial: serializer.fromJson<bool>(json['isOfficial']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mountainId': serializer.toJson<String>(mountainId),
      'name': serializer.toJson<String>(name),
      'geometryJson': serializer.toJson<List<TrailPoint>>(geometryJson),
      'distance': serializer.toJson<double>(distance),
      'elevationGain': serializer.toJson<double>(elevationGain),
      'difficulty': serializer.toJson<int>(difficulty),
      'summitIndex': serializer.toJson<int>(summitIndex),
      'minLat': serializer.toJson<double>(minLat),
      'maxLat': serializer.toJson<double>(maxLat),
      'minLng': serializer.toJson<double>(minLng),
      'maxLng': serializer.toJson<double>(maxLng),
      'startLat': serializer.toJson<double?>(startLat),
      'startLng': serializer.toJson<double?>(startLng),
      'isOfficial': serializer.toJson<bool>(isOfficial),
    };
  }

  Trail copyWith(
          {String? id,
          String? mountainId,
          String? name,
          List<TrailPoint>? geometryJson,
          double? distance,
          double? elevationGain,
          int? difficulty,
          int? summitIndex,
          double? minLat,
          double? maxLat,
          double? minLng,
          double? maxLng,
          Value<double?> startLat = const Value.absent(),
          Value<double?> startLng = const Value.absent(),
          bool? isOfficial}) =>
      Trail(
        id: id ?? this.id,
        mountainId: mountainId ?? this.mountainId,
        name: name ?? this.name,
        geometryJson: geometryJson ?? this.geometryJson,
        distance: distance ?? this.distance,
        elevationGain: elevationGain ?? this.elevationGain,
        difficulty: difficulty ?? this.difficulty,
        summitIndex: summitIndex ?? this.summitIndex,
        minLat: minLat ?? this.minLat,
        maxLat: maxLat ?? this.maxLat,
        minLng: minLng ?? this.minLng,
        maxLng: maxLng ?? this.maxLng,
        startLat: startLat.present ? startLat.value : this.startLat,
        startLng: startLng.present ? startLng.value : this.startLng,
        isOfficial: isOfficial ?? this.isOfficial,
      );
  Trail copyWithCompanion(TrailsCompanion data) {
    return Trail(
      id: data.id.present ? data.id.value : this.id,
      mountainId:
          data.mountainId.present ? data.mountainId.value : this.mountainId,
      name: data.name.present ? data.name.value : this.name,
      geometryJson: data.geometryJson.present
          ? data.geometryJson.value
          : this.geometryJson,
      distance: data.distance.present ? data.distance.value : this.distance,
      elevationGain: data.elevationGain.present
          ? data.elevationGain.value
          : this.elevationGain,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      summitIndex:
          data.summitIndex.present ? data.summitIndex.value : this.summitIndex,
      minLat: data.minLat.present ? data.minLat.value : this.minLat,
      maxLat: data.maxLat.present ? data.maxLat.value : this.maxLat,
      minLng: data.minLng.present ? data.minLng.value : this.minLng,
      maxLng: data.maxLng.present ? data.maxLng.value : this.maxLng,
      startLat: data.startLat.present ? data.startLat.value : this.startLat,
      startLng: data.startLng.present ? data.startLng.value : this.startLng,
      isOfficial:
          data.isOfficial.present ? data.isOfficial.value : this.isOfficial,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trail(')
          ..write('id: $id, ')
          ..write('mountainId: $mountainId, ')
          ..write('name: $name, ')
          ..write('geometryJson: $geometryJson, ')
          ..write('distance: $distance, ')
          ..write('elevationGain: $elevationGain, ')
          ..write('difficulty: $difficulty, ')
          ..write('summitIndex: $summitIndex, ')
          ..write('minLat: $minLat, ')
          ..write('maxLat: $maxLat, ')
          ..write('minLng: $minLng, ')
          ..write('maxLng: $maxLng, ')
          ..write('startLat: $startLat, ')
          ..write('startLng: $startLng, ')
          ..write('isOfficial: $isOfficial')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      mountainId,
      name,
      geometryJson,
      distance,
      elevationGain,
      difficulty,
      summitIndex,
      minLat,
      maxLat,
      minLng,
      maxLng,
      startLat,
      startLng,
      isOfficial);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trail &&
          other.id == this.id &&
          other.mountainId == this.mountainId &&
          other.name == this.name &&
          other.geometryJson == this.geometryJson &&
          other.distance == this.distance &&
          other.elevationGain == this.elevationGain &&
          other.difficulty == this.difficulty &&
          other.summitIndex == this.summitIndex &&
          other.minLat == this.minLat &&
          other.maxLat == this.maxLat &&
          other.minLng == this.minLng &&
          other.maxLng == this.maxLng &&
          other.startLat == this.startLat &&
          other.startLng == this.startLng &&
          other.isOfficial == this.isOfficial);
}

class TrailsCompanion extends UpdateCompanion<Trail> {
  final Value<String> id;
  final Value<String> mountainId;
  final Value<String> name;
  final Value<List<TrailPoint>> geometryJson;
  final Value<double> distance;
  final Value<double> elevationGain;
  final Value<int> difficulty;
  final Value<int> summitIndex;
  final Value<double> minLat;
  final Value<double> maxLat;
  final Value<double> minLng;
  final Value<double> maxLng;
  final Value<double?> startLat;
  final Value<double?> startLng;
  final Value<bool> isOfficial;
  final Value<int> rowid;
  const TrailsCompanion({
    this.id = const Value.absent(),
    this.mountainId = const Value.absent(),
    this.name = const Value.absent(),
    this.geometryJson = const Value.absent(),
    this.distance = const Value.absent(),
    this.elevationGain = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.summitIndex = const Value.absent(),
    this.minLat = const Value.absent(),
    this.maxLat = const Value.absent(),
    this.minLng = const Value.absent(),
    this.maxLng = const Value.absent(),
    this.startLat = const Value.absent(),
    this.startLng = const Value.absent(),
    this.isOfficial = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrailsCompanion.insert({
    required String id,
    required String mountainId,
    required String name,
    required List<TrailPoint> geometryJson,
    this.distance = const Value.absent(),
    this.elevationGain = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.summitIndex = const Value.absent(),
    this.minLat = const Value.absent(),
    this.maxLat = const Value.absent(),
    this.minLng = const Value.absent(),
    this.maxLng = const Value.absent(),
    this.startLat = const Value.absent(),
    this.startLng = const Value.absent(),
    this.isOfficial = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        mountainId = Value(mountainId),
        name = Value(name),
        geometryJson = Value(geometryJson);
  static Insertable<Trail> custom({
    Expression<String>? id,
    Expression<String>? mountainId,
    Expression<String>? name,
    Expression<String>? geometryJson,
    Expression<double>? distance,
    Expression<double>? elevationGain,
    Expression<int>? difficulty,
    Expression<int>? summitIndex,
    Expression<double>? minLat,
    Expression<double>? maxLat,
    Expression<double>? minLng,
    Expression<double>? maxLng,
    Expression<double>? startLat,
    Expression<double>? startLng,
    Expression<bool>? isOfficial,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mountainId != null) 'mountain_id': mountainId,
      if (name != null) 'name': name,
      if (geometryJson != null) 'geometry_json': geometryJson,
      if (distance != null) 'distance': distance,
      if (elevationGain != null) 'elevation_gain': elevationGain,
      if (difficulty != null) 'difficulty': difficulty,
      if (summitIndex != null) 'summit_index': summitIndex,
      if (minLat != null) 'min_lat': minLat,
      if (maxLat != null) 'max_lat': maxLat,
      if (minLng != null) 'min_lng': minLng,
      if (maxLng != null) 'max_lng': maxLng,
      if (startLat != null) 'start_lat': startLat,
      if (startLng != null) 'start_lng': startLng,
      if (isOfficial != null) 'is_official': isOfficial,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrailsCompanion copyWith(
      {Value<String>? id,
      Value<String>? mountainId,
      Value<String>? name,
      Value<List<TrailPoint>>? geometryJson,
      Value<double>? distance,
      Value<double>? elevationGain,
      Value<int>? difficulty,
      Value<int>? summitIndex,
      Value<double>? minLat,
      Value<double>? maxLat,
      Value<double>? minLng,
      Value<double>? maxLng,
      Value<double?>? startLat,
      Value<double?>? startLng,
      Value<bool>? isOfficial,
      Value<int>? rowid}) {
    return TrailsCompanion(
      id: id ?? this.id,
      mountainId: mountainId ?? this.mountainId,
      name: name ?? this.name,
      geometryJson: geometryJson ?? this.geometryJson,
      distance: distance ?? this.distance,
      elevationGain: elevationGain ?? this.elevationGain,
      difficulty: difficulty ?? this.difficulty,
      summitIndex: summitIndex ?? this.summitIndex,
      minLat: minLat ?? this.minLat,
      maxLat: maxLat ?? this.maxLat,
      minLng: minLng ?? this.minLng,
      maxLng: maxLng ?? this.maxLng,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      isOfficial: isOfficial ?? this.isOfficial,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mountainId.present) {
      map['mountain_id'] = Variable<String>(mountainId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (geometryJson.present) {
      map['geometry_json'] = Variable<String>(
          $TrailsTable.$convertergeometryJson.toSql(geometryJson.value));
    }
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    if (elevationGain.present) {
      map['elevation_gain'] = Variable<double>(elevationGain.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (summitIndex.present) {
      map['summit_index'] = Variable<int>(summitIndex.value);
    }
    if (minLat.present) {
      map['min_lat'] = Variable<double>(minLat.value);
    }
    if (maxLat.present) {
      map['max_lat'] = Variable<double>(maxLat.value);
    }
    if (minLng.present) {
      map['min_lng'] = Variable<double>(minLng.value);
    }
    if (maxLng.present) {
      map['max_lng'] = Variable<double>(maxLng.value);
    }
    if (startLat.present) {
      map['start_lat'] = Variable<double>(startLat.value);
    }
    if (startLng.present) {
      map['start_lng'] = Variable<double>(startLng.value);
    }
    if (isOfficial.present) {
      map['is_official'] = Variable<bool>(isOfficial.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrailsCompanion(')
          ..write('id: $id, ')
          ..write('mountainId: $mountainId, ')
          ..write('name: $name, ')
          ..write('geometryJson: $geometryJson, ')
          ..write('distance: $distance, ')
          ..write('elevationGain: $elevationGain, ')
          ..write('difficulty: $difficulty, ')
          ..write('summitIndex: $summitIndex, ')
          ..write('minLat: $minLat, ')
          ..write('maxLat: $maxLat, ')
          ..write('minLng: $minLng, ')
          ..write('maxLng: $maxLng, ')
          ..write('startLat: $startLat, ')
          ..write('startLng: $startLng, ')
          ..write('isOfficial: $isOfficial, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PointsOfInterestTable extends PointsOfInterest
    with TableInfo<$PointsOfInterestTable, PointOfInterest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PointsOfInterestTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mountainIdMeta =
      const VerificationMeta('mountainId');
  @override
  late final GeneratedColumn<String> mountainId = GeneratedColumn<String>(
      'mountain_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES mountain_regions (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('POI'));
  @override
  late final GeneratedColumnWithTypeConverter<PoiType, int> type =
      GeneratedColumn<int>('type', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<PoiType>($PointsOfInterestTable.$convertertype);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _elevationMeta =
      const VerificationMeta('elevation');
  @override
  late final GeneratedColumn<double> elevation = GeneratedColumn<double>(
      'elevation', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _metadataJsonMeta =
      const VerificationMeta('metadataJson');
  @override
  late final GeneratedColumn<String> metadataJson = GeneratedColumn<String>(
      'metadata_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, mountainId, name, type, lat, lng, elevation, metadataJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'points_of_interest';
  @override
  VerificationContext validateIntegrity(Insertable<PointOfInterest> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mountain_id')) {
      context.handle(
          _mountainIdMeta,
          mountainId.isAcceptableOrUnknown(
              data['mountain_id']!, _mountainIdMeta));
    } else if (isInserting) {
      context.missing(_mountainIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('elevation')) {
      context.handle(_elevationMeta,
          elevation.isAcceptableOrUnknown(data['elevation']!, _elevationMeta));
    }
    if (data.containsKey('metadata_json')) {
      context.handle(
          _metadataJsonMeta,
          metadataJson.isAcceptableOrUnknown(
              data['metadata_json']!, _metadataJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PointOfInterest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PointOfInterest(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mountainId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mountain_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: $PointsOfInterestTable.$convertertype.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!),
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      elevation: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}elevation']),
      metadataJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata_json']),
    );
  }

  @override
  $PointsOfInterestTable createAlias(String alias) {
    return $PointsOfInterestTable(attachedDatabase, alias);
  }

  static TypeConverter<PoiType, int> $convertertype = const PoiTypeConverter();
}

class PointOfInterest extends DataClass implements Insertable<PointOfInterest> {
  final String id;
  final String mountainId;
  final String name;
  final PoiType type;
  final double lat;
  final double lng;
  final double? elevation;
  final String? metadataJson;
  const PointOfInterest(
      {required this.id,
      required this.mountainId,
      required this.name,
      required this.type,
      required this.lat,
      required this.lng,
      this.elevation,
      this.metadataJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['mountain_id'] = Variable<String>(mountainId);
    map['name'] = Variable<String>(name);
    {
      map['type'] =
          Variable<int>($PointsOfInterestTable.$convertertype.toSql(type));
    }
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || elevation != null) {
      map['elevation'] = Variable<double>(elevation);
    }
    if (!nullToAbsent || metadataJson != null) {
      map['metadata_json'] = Variable<String>(metadataJson);
    }
    return map;
  }

  PointsOfInterestCompanion toCompanion(bool nullToAbsent) {
    return PointsOfInterestCompanion(
      id: Value(id),
      mountainId: Value(mountainId),
      name: Value(name),
      type: Value(type),
      lat: Value(lat),
      lng: Value(lng),
      elevation: elevation == null && nullToAbsent
          ? const Value.absent()
          : Value(elevation),
      metadataJson: metadataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(metadataJson),
    );
  }

  factory PointOfInterest.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PointOfInterest(
      id: serializer.fromJson<String>(json['id']),
      mountainId: serializer.fromJson<String>(json['mountainId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<PoiType>(json['type']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      elevation: serializer.fromJson<double?>(json['elevation']),
      metadataJson: serializer.fromJson<String?>(json['metadataJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mountainId': serializer.toJson<String>(mountainId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<PoiType>(type),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'elevation': serializer.toJson<double?>(elevation),
      'metadataJson': serializer.toJson<String?>(metadataJson),
    };
  }

  PointOfInterest copyWith(
          {String? id,
          String? mountainId,
          String? name,
          PoiType? type,
          double? lat,
          double? lng,
          Value<double?> elevation = const Value.absent(),
          Value<String?> metadataJson = const Value.absent()}) =>
      PointOfInterest(
        id: id ?? this.id,
        mountainId: mountainId ?? this.mountainId,
        name: name ?? this.name,
        type: type ?? this.type,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        elevation: elevation.present ? elevation.value : this.elevation,
        metadataJson:
            metadataJson.present ? metadataJson.value : this.metadataJson,
      );
  PointOfInterest copyWithCompanion(PointsOfInterestCompanion data) {
    return PointOfInterest(
      id: data.id.present ? data.id.value : this.id,
      mountainId:
          data.mountainId.present ? data.mountainId.value : this.mountainId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      elevation: data.elevation.present ? data.elevation.value : this.elevation,
      metadataJson: data.metadataJson.present
          ? data.metadataJson.value
          : this.metadataJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PointOfInterest(')
          ..write('id: $id, ')
          ..write('mountainId: $mountainId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('elevation: $elevation, ')
          ..write('metadataJson: $metadataJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, mountainId, name, type, lat, lng, elevation, metadataJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PointOfInterest &&
          other.id == this.id &&
          other.mountainId == this.mountainId &&
          other.name == this.name &&
          other.type == this.type &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.elevation == this.elevation &&
          other.metadataJson == this.metadataJson);
}

class PointsOfInterestCompanion extends UpdateCompanion<PointOfInterest> {
  final Value<String> id;
  final Value<String> mountainId;
  final Value<String> name;
  final Value<PoiType> type;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double?> elevation;
  final Value<String?> metadataJson;
  final Value<int> rowid;
  const PointsOfInterestCompanion({
    this.id = const Value.absent(),
    this.mountainId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.elevation = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PointsOfInterestCompanion.insert({
    required String id,
    required String mountainId,
    this.name = const Value.absent(),
    required PoiType type,
    required double lat,
    required double lng,
    this.elevation = const Value.absent(),
    this.metadataJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        mountainId = Value(mountainId),
        type = Value(type),
        lat = Value(lat),
        lng = Value(lng);
  static Insertable<PointOfInterest> custom({
    Expression<String>? id,
    Expression<String>? mountainId,
    Expression<String>? name,
    Expression<int>? type,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? elevation,
    Expression<String>? metadataJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mountainId != null) 'mountain_id': mountainId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (elevation != null) 'elevation': elevation,
      if (metadataJson != null) 'metadata_json': metadataJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PointsOfInterestCompanion copyWith(
      {Value<String>? id,
      Value<String>? mountainId,
      Value<String>? name,
      Value<PoiType>? type,
      Value<double>? lat,
      Value<double>? lng,
      Value<double?>? elevation,
      Value<String?>? metadataJson,
      Value<int>? rowid}) {
    return PointsOfInterestCompanion(
      id: id ?? this.id,
      mountainId: mountainId ?? this.mountainId,
      name: name ?? this.name,
      type: type ?? this.type,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      elevation: elevation ?? this.elevation,
      metadataJson: metadataJson ?? this.metadataJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mountainId.present) {
      map['mountain_id'] = Variable<String>(mountainId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
          $PointsOfInterestTable.$convertertype.toSql(type.value));
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (elevation.present) {
      map['elevation'] = Variable<double>(elevation.value);
    }
    if (metadataJson.present) {
      map['metadata_json'] = Variable<String>(metadataJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PointsOfInterestCompanion(')
          ..write('id: $id, ')
          ..write('mountainId: $mountainId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('elevation: $elevation, ')
          ..write('metadataJson: $metadataJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserBreadcrumbsTable extends UserBreadcrumbs
    with TableInfo<$UserBreadcrumbsTable, UserBreadcrumb> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserBreadcrumbsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _sessionIdMeta =
      const VerificationMeta('sessionId');
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
      'session_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
      'lat', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
      'lng', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _altitudeMeta =
      const VerificationMeta('altitude');
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
      'altitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _accuracyMeta =
      const VerificationMeta('accuracy');
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
      'accuracy', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
      'speed', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSyncedMeta =
      const VerificationMeta('isSynced');
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
      'is_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, sessionId, lat, lng, altitude, accuracy, speed, timestamp, isSynced];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_breadcrumbs';
  @override
  VerificationContext validateIntegrity(Insertable<UserBreadcrumb> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(_sessionIdMeta,
          sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta));
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
          _latMeta, lat.isAcceptableOrUnknown(data['lat']!, _latMeta));
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
          _lngMeta, lng.isAcceptableOrUnknown(data['lng']!, _lngMeta));
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(_altitudeMeta,
          altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta));
    }
    if (data.containsKey('accuracy')) {
      context.handle(_accuracyMeta,
          accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta));
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('is_synced')) {
      context.handle(_isSyncedMeta,
          isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserBreadcrumb map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserBreadcrumb(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      sessionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_id'])!,
      lat: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lat'])!,
      lng: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}lng'])!,
      altitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}altitude']),
      accuracy: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}accuracy'])!,
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}speed']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      isSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_synced'])!,
    );
  }

  @override
  $UserBreadcrumbsTable createAlias(String alias) {
    return $UserBreadcrumbsTable(attachedDatabase, alias);
  }
}

class UserBreadcrumb extends DataClass implements Insertable<UserBreadcrumb> {
  final int id;
  final String sessionId;
  final double lat;
  final double lng;
  final double? altitude;
  final double accuracy;
  final double? speed;
  final DateTime timestamp;
  final bool isSynced;
  const UserBreadcrumb(
      {required this.id,
      required this.sessionId,
      required this.lat,
      required this.lng,
      this.altitude,
      required this.accuracy,
      this.speed,
      required this.timestamp,
      required this.isSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    map['accuracy'] = Variable<double>(accuracy);
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<double>(speed);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  UserBreadcrumbsCompanion toCompanion(bool nullToAbsent) {
    return UserBreadcrumbsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      lat: Value(lat),
      lng: Value(lng),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      accuracy: Value(accuracy),
      speed:
          speed == null && nullToAbsent ? const Value.absent() : Value(speed),
      timestamp: Value(timestamp),
      isSynced: Value(isSynced),
    );
  }

  factory UserBreadcrumb.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserBreadcrumb(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      speed: serializer.fromJson<double?>(json['speed']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'altitude': serializer.toJson<double?>(altitude),
      'accuracy': serializer.toJson<double>(accuracy),
      'speed': serializer.toJson<double?>(speed),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  UserBreadcrumb copyWith(
          {int? id,
          String? sessionId,
          double? lat,
          double? lng,
          Value<double?> altitude = const Value.absent(),
          double? accuracy,
          Value<double?> speed = const Value.absent(),
          DateTime? timestamp,
          bool? isSynced}) =>
      UserBreadcrumb(
        id: id ?? this.id,
        sessionId: sessionId ?? this.sessionId,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        altitude: altitude.present ? altitude.value : this.altitude,
        accuracy: accuracy ?? this.accuracy,
        speed: speed.present ? speed.value : this.speed,
        timestamp: timestamp ?? this.timestamp,
        isSynced: isSynced ?? this.isSynced,
      );
  UserBreadcrumb copyWithCompanion(UserBreadcrumbsCompanion data) {
    return UserBreadcrumb(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      speed: data.speed.present ? data.speed.value : this.speed,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserBreadcrumb(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('speed: $speed, ')
          ..write('timestamp: $timestamp, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, sessionId, lat, lng, altitude, accuracy, speed, timestamp, isSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserBreadcrumb &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.altitude == this.altitude &&
          other.accuracy == this.accuracy &&
          other.speed == this.speed &&
          other.timestamp == this.timestamp &&
          other.isSynced == this.isSynced);
}

class UserBreadcrumbsCompanion extends UpdateCompanion<UserBreadcrumb> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<double> lat;
  final Value<double> lng;
  final Value<double?> altitude;
  final Value<double> accuracy;
  final Value<double?> speed;
  final Value<DateTime> timestamp;
  final Value<bool> isSynced;
  const UserBreadcrumbsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.altitude = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.speed = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  UserBreadcrumbsCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required double lat,
    required double lng,
    this.altitude = const Value.absent(),
    required double accuracy,
    this.speed = const Value.absent(),
    required DateTime timestamp,
    this.isSynced = const Value.absent(),
  })  : sessionId = Value(sessionId),
        lat = Value(lat),
        lng = Value(lng),
        accuracy = Value(accuracy),
        timestamp = Value(timestamp);
  static Insertable<UserBreadcrumb> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<double>? altitude,
    Expression<double>? accuracy,
    Expression<double>? speed,
    Expression<DateTime>? timestamp,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      if (timestamp != null) 'timestamp': timestamp,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  UserBreadcrumbsCompanion copyWith(
      {Value<int>? id,
      Value<String>? sessionId,
      Value<double>? lat,
      Value<double>? lng,
      Value<double?>? altitude,
      Value<double>? accuracy,
      Value<double?>? speed,
      Value<DateTime>? timestamp,
      Value<bool>? isSynced}) {
    return UserBreadcrumbsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserBreadcrumbsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('altitude: $altitude, ')
          ..write('accuracy: $accuracy, ')
          ..write('speed: $speed, ')
          ..write('timestamp: $timestamp, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $OfflineMapPackagesTable extends OfflineMapPackages
    with TableInfo<$OfflineMapPackagesTable, OfflineMapPackage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OfflineMapPackagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _regionIdMeta =
      const VerificationMeta('regionId');
  @override
  late final GeneratedColumn<String> regionId = GeneratedColumn<String>(
      'region_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filePathMeta =
      const VerificationMeta('filePath');
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
      'file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sizeBytesMeta =
      const VerificationMeta('sizeBytes');
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
      'size_bytes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isVectorMeta =
      const VerificationMeta('isVector');
  @override
  late final GeneratedColumn<bool> isVector = GeneratedColumn<bool>(
      'is_vector', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_vector" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [regionId, filePath, sizeBytes, isVector, status, lastUpdated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'offline_map_packages';
  @override
  VerificationContext validateIntegrity(Insertable<OfflineMapPackage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('region_id')) {
      context.handle(_regionIdMeta,
          regionId.isAcceptableOrUnknown(data['region_id']!, _regionIdMeta));
    } else if (isInserting) {
      context.missing(_regionIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(_filePathMeta,
          filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta));
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(_sizeBytesMeta,
          sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta));
    }
    if (data.containsKey('is_vector')) {
      context.handle(_isVectorMeta,
          isVector.isAcceptableOrUnknown(data['is_vector']!, _isVectorMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {regionId};
  @override
  OfflineMapPackage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OfflineMapPackage(
      regionId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}region_id'])!,
      filePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}file_path'])!,
      sizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size_bytes'])!,
      isVector: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_vector'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated']),
    );
  }

  @override
  $OfflineMapPackagesTable createAlias(String alias) {
    return $OfflineMapPackagesTable(attachedDatabase, alias);
  }
}

class OfflineMapPackage extends DataClass
    implements Insertable<OfflineMapPackage> {
  final String regionId;
  final String filePath;
  final int sizeBytes;
  final bool isVector;
  final int status;
  final DateTime? lastUpdated;
  const OfflineMapPackage(
      {required this.regionId,
      required this.filePath,
      required this.sizeBytes,
      required this.isVector,
      required this.status,
      this.lastUpdated});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['region_id'] = Variable<String>(regionId);
    map['file_path'] = Variable<String>(filePath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['is_vector'] = Variable<bool>(isVector);
    map['status'] = Variable<int>(status);
    if (!nullToAbsent || lastUpdated != null) {
      map['last_updated'] = Variable<DateTime>(lastUpdated);
    }
    return map;
  }

  OfflineMapPackagesCompanion toCompanion(bool nullToAbsent) {
    return OfflineMapPackagesCompanion(
      regionId: Value(regionId),
      filePath: Value(filePath),
      sizeBytes: Value(sizeBytes),
      isVector: Value(isVector),
      status: Value(status),
      lastUpdated: lastUpdated == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdated),
    );
  }

  factory OfflineMapPackage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OfflineMapPackage(
      regionId: serializer.fromJson<String>(json['regionId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      isVector: serializer.fromJson<bool>(json['isVector']),
      status: serializer.fromJson<int>(json['status']),
      lastUpdated: serializer.fromJson<DateTime?>(json['lastUpdated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'regionId': serializer.toJson<String>(regionId),
      'filePath': serializer.toJson<String>(filePath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'isVector': serializer.toJson<bool>(isVector),
      'status': serializer.toJson<int>(status),
      'lastUpdated': serializer.toJson<DateTime?>(lastUpdated),
    };
  }

  OfflineMapPackage copyWith(
          {String? regionId,
          String? filePath,
          int? sizeBytes,
          bool? isVector,
          int? status,
          Value<DateTime?> lastUpdated = const Value.absent()}) =>
      OfflineMapPackage(
        regionId: regionId ?? this.regionId,
        filePath: filePath ?? this.filePath,
        sizeBytes: sizeBytes ?? this.sizeBytes,
        isVector: isVector ?? this.isVector,
        status: status ?? this.status,
        lastUpdated: lastUpdated.present ? lastUpdated.value : this.lastUpdated,
      );
  OfflineMapPackage copyWithCompanion(OfflineMapPackagesCompanion data) {
    return OfflineMapPackage(
      regionId: data.regionId.present ? data.regionId.value : this.regionId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      isVector: data.isVector.present ? data.isVector.value : this.isVector,
      status: data.status.present ? data.status.value : this.status,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OfflineMapPackage(')
          ..write('regionId: $regionId, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('isVector: $isVector, ')
          ..write('status: $status, ')
          ..write('lastUpdated: $lastUpdated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(regionId, filePath, sizeBytes, isVector, status, lastUpdated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OfflineMapPackage &&
          other.regionId == this.regionId &&
          other.filePath == this.filePath &&
          other.sizeBytes == this.sizeBytes &&
          other.isVector == this.isVector &&
          other.status == this.status &&
          other.lastUpdated == this.lastUpdated);
}

class OfflineMapPackagesCompanion extends UpdateCompanion<OfflineMapPackage> {
  final Value<String> regionId;
  final Value<String> filePath;
  final Value<int> sizeBytes;
  final Value<bool> isVector;
  final Value<int> status;
  final Value<DateTime?> lastUpdated;
  final Value<int> rowid;
  const OfflineMapPackagesCompanion({
    this.regionId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.isVector = const Value.absent(),
    this.status = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OfflineMapPackagesCompanion.insert({
    required String regionId,
    required String filePath,
    this.sizeBytes = const Value.absent(),
    this.isVector = const Value.absent(),
    this.status = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : regionId = Value(regionId),
        filePath = Value(filePath);
  static Insertable<OfflineMapPackage> custom({
    Expression<String>? regionId,
    Expression<String>? filePath,
    Expression<int>? sizeBytes,
    Expression<bool>? isVector,
    Expression<int>? status,
    Expression<DateTime>? lastUpdated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (regionId != null) 'region_id': regionId,
      if (filePath != null) 'file_path': filePath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (isVector != null) 'is_vector': isVector,
      if (status != null) 'status': status,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OfflineMapPackagesCompanion copyWith(
      {Value<String>? regionId,
      Value<String>? filePath,
      Value<int>? sizeBytes,
      Value<bool>? isVector,
      Value<int>? status,
      Value<DateTime?>? lastUpdated,
      Value<int>? rowid}) {
    return OfflineMapPackagesCompanion(
      regionId: regionId ?? this.regionId,
      filePath: filePath ?? this.filePath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      isVector: isVector ?? this.isVector,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (regionId.present) {
      map['region_id'] = Variable<String>(regionId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (isVector.present) {
      map['is_vector'] = Variable<bool>(isVector.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OfflineMapPackagesCompanion(')
          ..write('regionId: $regionId, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('isVector: $isVector, ')
          ..write('status: $status, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MountainRegionsTable mountainRegions =
      $MountainRegionsTable(this);
  late final $TrailsTable trails = $TrailsTable(this);
  late final $PointsOfInterestTable pointsOfInterest =
      $PointsOfInterestTable(this);
  late final $UserBreadcrumbsTable userBreadcrumbs =
      $UserBreadcrumbsTable(this);
  late final $OfflineMapPackagesTable offlineMapPackages =
      $OfflineMapPackagesTable(this);
  late final Index trailsMountainIdx = Index('trails_mountain_idx',
      'CREATE INDEX trails_mountain_idx ON trails (mountain_id)');
  late final Index poiMountainIdx = Index('poi_mountain_idx',
      'CREATE INDEX poi_mountain_idx ON points_of_interest (mountain_id)');
  late final Index breadcrumbsSessionIdx = Index('breadcrumbs_session_idx',
      'CREATE INDEX breadcrumbs_session_idx ON user_breadcrumbs (session_id, timestamp)');
  late final Index breadcrumbsSyncedIdx = Index('breadcrumbs_synced_idx',
      'CREATE INDEX breadcrumbs_synced_idx ON user_breadcrumbs (is_synced)');
  late final MountainDao mountainDao = MountainDao(this as AppDatabase);
  late final NavigationDao navigationDao = NavigationDao(this as AppDatabase);
  late final TrackingDao trackingDao = TrackingDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        mountainRegions,
        trails,
        pointsOfInterest,
        userBreadcrumbs,
        offlineMapPackages,
        trailsMountainIdx,
        poiMountainIdx,
        breadcrumbsSessionIdx,
        breadcrumbsSyncedIdx
      ];
}

typedef $$MountainRegionsTableCreateCompanionBuilder = MountainRegionsCompanion
    Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<String?> localMapPath,
  required String boundaryJson,
  Value<double> lat,
  Value<double> lng,
  Value<int> version,
  Value<bool> isDownloaded,
  Value<int> rowid,
});
typedef $$MountainRegionsTableUpdateCompanionBuilder = MountainRegionsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> localMapPath,
  Value<String> boundaryJson,
  Value<double> lat,
  Value<double> lng,
  Value<int> version,
  Value<bool> isDownloaded,
  Value<int> rowid,
});

final class $$MountainRegionsTableReferences extends BaseReferences<
    _$AppDatabase, $MountainRegionsTable, MountainRegion> {
  $$MountainRegionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TrailsTable, List<Trail>> _trailsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.trails,
          aliasName: $_aliasNameGenerator(
              db.mountainRegions.id, db.trails.mountainId));

  $$TrailsTableProcessedTableManager get trailsRefs {
    final manager = $$TrailsTableTableManager($_db, $_db.trails)
        .filter((f) => f.mountainId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_trailsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PointsOfInterestTable, List<PointOfInterest>>
      _pointsOfInterestRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.pointsOfInterest,
              aliasName: $_aliasNameGenerator(
                  db.mountainRegions.id, db.pointsOfInterest.mountainId));

  $$PointsOfInterestTableProcessedTableManager get pointsOfInterestRefs {
    final manager = $$PointsOfInterestTableTableManager(
            $_db, $_db.pointsOfInterest)
        .filter((f) => f.mountainId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_pointsOfInterestRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MountainRegionsTableFilterComposer
    extends Composer<_$AppDatabase, $MountainRegionsTable> {
  $$MountainRegionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localMapPath => $composableBuilder(
      column: $table.localMapPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get boundaryJson => $composableBuilder(
      column: $table.boundaryJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded, builder: (column) => ColumnFilters(column));

  Expression<bool> trailsRefs(
      Expression<bool> Function($$TrailsTableFilterComposer f) f) {
    final $$TrailsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.trails,
        getReferencedColumn: (t) => t.mountainId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrailsTableFilterComposer(
              $db: $db,
              $table: $db.trails,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pointsOfInterestRefs(
      Expression<bool> Function($$PointsOfInterestTableFilterComposer f) f) {
    final $$PointsOfInterestTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pointsOfInterest,
        getReferencedColumn: (t) => t.mountainId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PointsOfInterestTableFilterComposer(
              $db: $db,
              $table: $db.pointsOfInterest,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MountainRegionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MountainRegionsTable> {
  $$MountainRegionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localMapPath => $composableBuilder(
      column: $table.localMapPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get boundaryJson => $composableBuilder(
      column: $table.boundaryJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get version => $composableBuilder(
      column: $table.version, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded,
      builder: (column) => ColumnOrderings(column));
}

class $$MountainRegionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MountainRegionsTable> {
  $$MountainRegionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get localMapPath => $composableBuilder(
      column: $table.localMapPath, builder: (column) => column);

  GeneratedColumn<String> get boundaryJson => $composableBuilder(
      column: $table.boundaryJson, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get isDownloaded => $composableBuilder(
      column: $table.isDownloaded, builder: (column) => column);

  Expression<T> trailsRefs<T extends Object>(
      Expression<T> Function($$TrailsTableAnnotationComposer a) f) {
    final $$TrailsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.trails,
        getReferencedColumn: (t) => t.mountainId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TrailsTableAnnotationComposer(
              $db: $db,
              $table: $db.trails,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pointsOfInterestRefs<T extends Object>(
      Expression<T> Function($$PointsOfInterestTableAnnotationComposer a) f) {
    final $$PointsOfInterestTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.pointsOfInterest,
        getReferencedColumn: (t) => t.mountainId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PointsOfInterestTableAnnotationComposer(
              $db: $db,
              $table: $db.pointsOfInterest,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MountainRegionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MountainRegionsTable,
    MountainRegion,
    $$MountainRegionsTableFilterComposer,
    $$MountainRegionsTableOrderingComposer,
    $$MountainRegionsTableAnnotationComposer,
    $$MountainRegionsTableCreateCompanionBuilder,
    $$MountainRegionsTableUpdateCompanionBuilder,
    (MountainRegion, $$MountainRegionsTableReferences),
    MountainRegion,
    PrefetchHooks Function({bool trailsRefs, bool pointsOfInterestRefs})> {
  $$MountainRegionsTableTableManager(
      _$AppDatabase db, $MountainRegionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MountainRegionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MountainRegionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MountainRegionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> localMapPath = const Value.absent(),
            Value<String> boundaryJson = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lng = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDownloaded = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MountainRegionsCompanion(
            id: id,
            name: name,
            description: description,
            localMapPath: localMapPath,
            boundaryJson: boundaryJson,
            lat: lat,
            lng: lng,
            version: version,
            isDownloaded: isDownloaded,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> localMapPath = const Value.absent(),
            required String boundaryJson,
            Value<double> lat = const Value.absent(),
            Value<double> lng = const Value.absent(),
            Value<int> version = const Value.absent(),
            Value<bool> isDownloaded = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MountainRegionsCompanion.insert(
            id: id,
            name: name,
            description: description,
            localMapPath: localMapPath,
            boundaryJson: boundaryJson,
            lat: lat,
            lng: lng,
            version: version,
            isDownloaded: isDownloaded,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MountainRegionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {trailsRefs = false, pointsOfInterestRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (trailsRefs) db.trails,
                if (pointsOfInterestRefs) db.pointsOfInterest
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trailsRefs)
                    await $_getPrefetchedData<MountainRegion,
                            $MountainRegionsTable, Trail>(
                        currentTable: table,
                        referencedTable: $$MountainRegionsTableReferences
                            ._trailsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MountainRegionsTableReferences(db, table, p0)
                                .trailsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.mountainId == item.id),
                        typedResults: items),
                  if (pointsOfInterestRefs)
                    await $_getPrefetchedData<MountainRegion,
                            $MountainRegionsTable, PointOfInterest>(
                        currentTable: table,
                        referencedTable: $$MountainRegionsTableReferences
                            ._pointsOfInterestRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MountainRegionsTableReferences(db, table, p0)
                                .pointsOfInterestRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.mountainId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MountainRegionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MountainRegionsTable,
    MountainRegion,
    $$MountainRegionsTableFilterComposer,
    $$MountainRegionsTableOrderingComposer,
    $$MountainRegionsTableAnnotationComposer,
    $$MountainRegionsTableCreateCompanionBuilder,
    $$MountainRegionsTableUpdateCompanionBuilder,
    (MountainRegion, $$MountainRegionsTableReferences),
    MountainRegion,
    PrefetchHooks Function({bool trailsRefs, bool pointsOfInterestRefs})>;
typedef $$TrailsTableCreateCompanionBuilder = TrailsCompanion Function({
  required String id,
  required String mountainId,
  required String name,
  required List<TrailPoint> geometryJson,
  Value<double> distance,
  Value<double> elevationGain,
  Value<int> difficulty,
  Value<int> summitIndex,
  Value<double> minLat,
  Value<double> maxLat,
  Value<double> minLng,
  Value<double> maxLng,
  Value<double?> startLat,
  Value<double?> startLng,
  Value<bool> isOfficial,
  Value<int> rowid,
});
typedef $$TrailsTableUpdateCompanionBuilder = TrailsCompanion Function({
  Value<String> id,
  Value<String> mountainId,
  Value<String> name,
  Value<List<TrailPoint>> geometryJson,
  Value<double> distance,
  Value<double> elevationGain,
  Value<int> difficulty,
  Value<int> summitIndex,
  Value<double> minLat,
  Value<double> maxLat,
  Value<double> minLng,
  Value<double> maxLng,
  Value<double?> startLat,
  Value<double?> startLng,
  Value<bool> isOfficial,
  Value<int> rowid,
});

final class $$TrailsTableReferences
    extends BaseReferences<_$AppDatabase, $TrailsTable, Trail> {
  $$TrailsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MountainRegionsTable _mountainIdTable(_$AppDatabase db) =>
      db.mountainRegions.createAlias(
          $_aliasNameGenerator(db.trails.mountainId, db.mountainRegions.id));

  $$MountainRegionsTableProcessedTableManager get mountainId {
    final $_column = $_itemColumn<String>('mountain_id')!;

    final manager =
        $$MountainRegionsTableTableManager($_db, $_db.mountainRegions)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mountainIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$TrailsTableFilterComposer
    extends Composer<_$AppDatabase, $TrailsTable> {
  $$TrailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<List<TrailPoint>, List<TrailPoint>, String>
      get geometryJson => $composableBuilder(
          column: $table.geometryJson,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get elevationGain => $composableBuilder(
      column: $table.elevationGain, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get summitIndex => $composableBuilder(
      column: $table.summitIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minLat => $composableBuilder(
      column: $table.minLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maxLat => $composableBuilder(
      column: $table.maxLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get minLng => $composableBuilder(
      column: $table.minLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get maxLng => $composableBuilder(
      column: $table.maxLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get startLat => $composableBuilder(
      column: $table.startLat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get startLng => $composableBuilder(
      column: $table.startLng, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isOfficial => $composableBuilder(
      column: $table.isOfficial, builder: (column) => ColumnFilters(column));

  $$MountainRegionsTableFilterComposer get mountainId {
    final $$MountainRegionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mountainId,
        referencedTable: $db.mountainRegions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MountainRegionsTableFilterComposer(
              $db: $db,
              $table: $db.mountainRegions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TrailsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrailsTable> {
  $$TrailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get geometryJson => $composableBuilder(
      column: $table.geometryJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get elevationGain => $composableBuilder(
      column: $table.elevationGain,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get summitIndex => $composableBuilder(
      column: $table.summitIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minLat => $composableBuilder(
      column: $table.minLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maxLat => $composableBuilder(
      column: $table.maxLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get minLng => $composableBuilder(
      column: $table.minLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get maxLng => $composableBuilder(
      column: $table.maxLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get startLat => $composableBuilder(
      column: $table.startLat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get startLng => $composableBuilder(
      column: $table.startLng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isOfficial => $composableBuilder(
      column: $table.isOfficial, builder: (column) => ColumnOrderings(column));

  $$MountainRegionsTableOrderingComposer get mountainId {
    final $$MountainRegionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mountainId,
        referencedTable: $db.mountainRegions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MountainRegionsTableOrderingComposer(
              $db: $db,
              $table: $db.mountainRegions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TrailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrailsTable> {
  $$TrailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<TrailPoint>, String> get geometryJson =>
      $composableBuilder(
          column: $table.geometryJson, builder: (column) => column);

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<double> get elevationGain => $composableBuilder(
      column: $table.elevationGain, builder: (column) => column);

  GeneratedColumn<int> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<int> get summitIndex => $composableBuilder(
      column: $table.summitIndex, builder: (column) => column);

  GeneratedColumn<double> get minLat =>
      $composableBuilder(column: $table.minLat, builder: (column) => column);

  GeneratedColumn<double> get maxLat =>
      $composableBuilder(column: $table.maxLat, builder: (column) => column);

  GeneratedColumn<double> get minLng =>
      $composableBuilder(column: $table.minLng, builder: (column) => column);

  GeneratedColumn<double> get maxLng =>
      $composableBuilder(column: $table.maxLng, builder: (column) => column);

  GeneratedColumn<double> get startLat =>
      $composableBuilder(column: $table.startLat, builder: (column) => column);

  GeneratedColumn<double> get startLng =>
      $composableBuilder(column: $table.startLng, builder: (column) => column);

  GeneratedColumn<bool> get isOfficial => $composableBuilder(
      column: $table.isOfficial, builder: (column) => column);

  $$MountainRegionsTableAnnotationComposer get mountainId {
    final $$MountainRegionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mountainId,
        referencedTable: $db.mountainRegions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MountainRegionsTableAnnotationComposer(
              $db: $db,
              $table: $db.mountainRegions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TrailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TrailsTable,
    Trail,
    $$TrailsTableFilterComposer,
    $$TrailsTableOrderingComposer,
    $$TrailsTableAnnotationComposer,
    $$TrailsTableCreateCompanionBuilder,
    $$TrailsTableUpdateCompanionBuilder,
    (Trail, $$TrailsTableReferences),
    Trail,
    PrefetchHooks Function({bool mountainId})> {
  $$TrailsTableTableManager(_$AppDatabase db, $TrailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> mountainId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<List<TrailPoint>> geometryJson = const Value.absent(),
            Value<double> distance = const Value.absent(),
            Value<double> elevationGain = const Value.absent(),
            Value<int> difficulty = const Value.absent(),
            Value<int> summitIndex = const Value.absent(),
            Value<double> minLat = const Value.absent(),
            Value<double> maxLat = const Value.absent(),
            Value<double> minLng = const Value.absent(),
            Value<double> maxLng = const Value.absent(),
            Value<double?> startLat = const Value.absent(),
            Value<double?> startLng = const Value.absent(),
            Value<bool> isOfficial = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrailsCompanion(
            id: id,
            mountainId: mountainId,
            name: name,
            geometryJson: geometryJson,
            distance: distance,
            elevationGain: elevationGain,
            difficulty: difficulty,
            summitIndex: summitIndex,
            minLat: minLat,
            maxLat: maxLat,
            minLng: minLng,
            maxLng: maxLng,
            startLat: startLat,
            startLng: startLng,
            isOfficial: isOfficial,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String mountainId,
            required String name,
            required List<TrailPoint> geometryJson,
            Value<double> distance = const Value.absent(),
            Value<double> elevationGain = const Value.absent(),
            Value<int> difficulty = const Value.absent(),
            Value<int> summitIndex = const Value.absent(),
            Value<double> minLat = const Value.absent(),
            Value<double> maxLat = const Value.absent(),
            Value<double> minLng = const Value.absent(),
            Value<double> maxLng = const Value.absent(),
            Value<double?> startLat = const Value.absent(),
            Value<double?> startLng = const Value.absent(),
            Value<bool> isOfficial = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TrailsCompanion.insert(
            id: id,
            mountainId: mountainId,
            name: name,
            geometryJson: geometryJson,
            distance: distance,
            elevationGain: elevationGain,
            difficulty: difficulty,
            summitIndex: summitIndex,
            minLat: minLat,
            maxLat: maxLat,
            minLng: minLng,
            maxLng: maxLng,
            startLat: startLat,
            startLng: startLng,
            isOfficial: isOfficial,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TrailsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({mountainId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (mountainId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mountainId,
                    referencedTable:
                        $$TrailsTableReferences._mountainIdTable(db),
                    referencedColumn:
                        $$TrailsTableReferences._mountainIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$TrailsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TrailsTable,
    Trail,
    $$TrailsTableFilterComposer,
    $$TrailsTableOrderingComposer,
    $$TrailsTableAnnotationComposer,
    $$TrailsTableCreateCompanionBuilder,
    $$TrailsTableUpdateCompanionBuilder,
    (Trail, $$TrailsTableReferences),
    Trail,
    PrefetchHooks Function({bool mountainId})>;
typedef $$PointsOfInterestTableCreateCompanionBuilder
    = PointsOfInterestCompanion Function({
  required String id,
  required String mountainId,
  Value<String> name,
  required PoiType type,
  required double lat,
  required double lng,
  Value<double?> elevation,
  Value<String?> metadataJson,
  Value<int> rowid,
});
typedef $$PointsOfInterestTableUpdateCompanionBuilder
    = PointsOfInterestCompanion Function({
  Value<String> id,
  Value<String> mountainId,
  Value<String> name,
  Value<PoiType> type,
  Value<double> lat,
  Value<double> lng,
  Value<double?> elevation,
  Value<String?> metadataJson,
  Value<int> rowid,
});

final class $$PointsOfInterestTableReferences extends BaseReferences<
    _$AppDatabase, $PointsOfInterestTable, PointOfInterest> {
  $$PointsOfInterestTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MountainRegionsTable _mountainIdTable(_$AppDatabase db) =>
      db.mountainRegions.createAlias($_aliasNameGenerator(
          db.pointsOfInterest.mountainId, db.mountainRegions.id));

  $$MountainRegionsTableProcessedTableManager get mountainId {
    final $_column = $_itemColumn<String>('mountain_id')!;

    final manager =
        $$MountainRegionsTableTableManager($_db, $_db.mountainRegions)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mountainIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$PointsOfInterestTableFilterComposer
    extends Composer<_$AppDatabase, $PointsOfInterestTable> {
  $$PointsOfInterestTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<PoiType, PoiType, int> get type =>
      $composableBuilder(
          column: $table.type,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get elevation => $composableBuilder(
      column: $table.elevation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => ColumnFilters(column));

  $$MountainRegionsTableFilterComposer get mountainId {
    final $$MountainRegionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mountainId,
        referencedTable: $db.mountainRegions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MountainRegionsTableFilterComposer(
              $db: $db,
              $table: $db.mountainRegions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PointsOfInterestTableOrderingComposer
    extends Composer<_$AppDatabase, $PointsOfInterestTable> {
  $$PointsOfInterestTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get elevation => $composableBuilder(
      column: $table.elevation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson,
      builder: (column) => ColumnOrderings(column));

  $$MountainRegionsTableOrderingComposer get mountainId {
    final $$MountainRegionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mountainId,
        referencedTable: $db.mountainRegions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MountainRegionsTableOrderingComposer(
              $db: $db,
              $table: $db.mountainRegions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PointsOfInterestTableAnnotationComposer
    extends Composer<_$AppDatabase, $PointsOfInterestTable> {
  $$PointsOfInterestTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PoiType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get elevation =>
      $composableBuilder(column: $table.elevation, builder: (column) => column);

  GeneratedColumn<String> get metadataJson => $composableBuilder(
      column: $table.metadataJson, builder: (column) => column);

  $$MountainRegionsTableAnnotationComposer get mountainId {
    final $$MountainRegionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mountainId,
        referencedTable: $db.mountainRegions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MountainRegionsTableAnnotationComposer(
              $db: $db,
              $table: $db.mountainRegions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PointsOfInterestTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PointsOfInterestTable,
    PointOfInterest,
    $$PointsOfInterestTableFilterComposer,
    $$PointsOfInterestTableOrderingComposer,
    $$PointsOfInterestTableAnnotationComposer,
    $$PointsOfInterestTableCreateCompanionBuilder,
    $$PointsOfInterestTableUpdateCompanionBuilder,
    (PointOfInterest, $$PointsOfInterestTableReferences),
    PointOfInterest,
    PrefetchHooks Function({bool mountainId})> {
  $$PointsOfInterestTableTableManager(
      _$AppDatabase db, $PointsOfInterestTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PointsOfInterestTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PointsOfInterestTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PointsOfInterestTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> mountainId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<PoiType> type = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lng = const Value.absent(),
            Value<double?> elevation = const Value.absent(),
            Value<String?> metadataJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PointsOfInterestCompanion(
            id: id,
            mountainId: mountainId,
            name: name,
            type: type,
            lat: lat,
            lng: lng,
            elevation: elevation,
            metadataJson: metadataJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String mountainId,
            Value<String> name = const Value.absent(),
            required PoiType type,
            required double lat,
            required double lng,
            Value<double?> elevation = const Value.absent(),
            Value<String?> metadataJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PointsOfInterestCompanion.insert(
            id: id,
            mountainId: mountainId,
            name: name,
            type: type,
            lat: lat,
            lng: lng,
            elevation: elevation,
            metadataJson: metadataJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PointsOfInterestTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({mountainId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (mountainId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mountainId,
                    referencedTable:
                        $$PointsOfInterestTableReferences._mountainIdTable(db),
                    referencedColumn: $$PointsOfInterestTableReferences
                        ._mountainIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$PointsOfInterestTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PointsOfInterestTable,
    PointOfInterest,
    $$PointsOfInterestTableFilterComposer,
    $$PointsOfInterestTableOrderingComposer,
    $$PointsOfInterestTableAnnotationComposer,
    $$PointsOfInterestTableCreateCompanionBuilder,
    $$PointsOfInterestTableUpdateCompanionBuilder,
    (PointOfInterest, $$PointsOfInterestTableReferences),
    PointOfInterest,
    PrefetchHooks Function({bool mountainId})>;
typedef $$UserBreadcrumbsTableCreateCompanionBuilder = UserBreadcrumbsCompanion
    Function({
  Value<int> id,
  required String sessionId,
  required double lat,
  required double lng,
  Value<double?> altitude,
  required double accuracy,
  Value<double?> speed,
  required DateTime timestamp,
  Value<bool> isSynced,
});
typedef $$UserBreadcrumbsTableUpdateCompanionBuilder = UserBreadcrumbsCompanion
    Function({
  Value<int> id,
  Value<String> sessionId,
  Value<double> lat,
  Value<double> lng,
  Value<double?> altitude,
  Value<double> accuracy,
  Value<double?> speed,
  Value<DateTime> timestamp,
  Value<bool> isSynced,
});

class $$UserBreadcrumbsTableFilterComposer
    extends Composer<_$AppDatabase, $UserBreadcrumbsTable> {
  $$UserBreadcrumbsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get altitude => $composableBuilder(
      column: $table.altitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnFilters(column));
}

class $$UserBreadcrumbsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserBreadcrumbsTable> {
  $$UserBreadcrumbsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionId => $composableBuilder(
      column: $table.sessionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lat => $composableBuilder(
      column: $table.lat, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get lng => $composableBuilder(
      column: $table.lng, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get altitude => $composableBuilder(
      column: $table.altitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get accuracy => $composableBuilder(
      column: $table.accuracy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSynced => $composableBuilder(
      column: $table.isSynced, builder: (column) => ColumnOrderings(column));
}

class $$UserBreadcrumbsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserBreadcrumbsTable> {
  $$UserBreadcrumbsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$UserBreadcrumbsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserBreadcrumbsTable,
    UserBreadcrumb,
    $$UserBreadcrumbsTableFilterComposer,
    $$UserBreadcrumbsTableOrderingComposer,
    $$UserBreadcrumbsTableAnnotationComposer,
    $$UserBreadcrumbsTableCreateCompanionBuilder,
    $$UserBreadcrumbsTableUpdateCompanionBuilder,
    (
      UserBreadcrumb,
      BaseReferences<_$AppDatabase, $UserBreadcrumbsTable, UserBreadcrumb>
    ),
    UserBreadcrumb,
    PrefetchHooks Function()> {
  $$UserBreadcrumbsTableTableManager(
      _$AppDatabase db, $UserBreadcrumbsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserBreadcrumbsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserBreadcrumbsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserBreadcrumbsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> sessionId = const Value.absent(),
            Value<double> lat = const Value.absent(),
            Value<double> lng = const Value.absent(),
            Value<double?> altitude = const Value.absent(),
            Value<double> accuracy = const Value.absent(),
            Value<double?> speed = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<bool> isSynced = const Value.absent(),
          }) =>
              UserBreadcrumbsCompanion(
            id: id,
            sessionId: sessionId,
            lat: lat,
            lng: lng,
            altitude: altitude,
            accuracy: accuracy,
            speed: speed,
            timestamp: timestamp,
            isSynced: isSynced,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String sessionId,
            required double lat,
            required double lng,
            Value<double?> altitude = const Value.absent(),
            required double accuracy,
            Value<double?> speed = const Value.absent(),
            required DateTime timestamp,
            Value<bool> isSynced = const Value.absent(),
          }) =>
              UserBreadcrumbsCompanion.insert(
            id: id,
            sessionId: sessionId,
            lat: lat,
            lng: lng,
            altitude: altitude,
            accuracy: accuracy,
            speed: speed,
            timestamp: timestamp,
            isSynced: isSynced,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserBreadcrumbsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserBreadcrumbsTable,
    UserBreadcrumb,
    $$UserBreadcrumbsTableFilterComposer,
    $$UserBreadcrumbsTableOrderingComposer,
    $$UserBreadcrumbsTableAnnotationComposer,
    $$UserBreadcrumbsTableCreateCompanionBuilder,
    $$UserBreadcrumbsTableUpdateCompanionBuilder,
    (
      UserBreadcrumb,
      BaseReferences<_$AppDatabase, $UserBreadcrumbsTable, UserBreadcrumb>
    ),
    UserBreadcrumb,
    PrefetchHooks Function()>;
typedef $$OfflineMapPackagesTableCreateCompanionBuilder
    = OfflineMapPackagesCompanion Function({
  required String regionId,
  required String filePath,
  Value<int> sizeBytes,
  Value<bool> isVector,
  Value<int> status,
  Value<DateTime?> lastUpdated,
  Value<int> rowid,
});
typedef $$OfflineMapPackagesTableUpdateCompanionBuilder
    = OfflineMapPackagesCompanion Function({
  Value<String> regionId,
  Value<String> filePath,
  Value<int> sizeBytes,
  Value<bool> isVector,
  Value<int> status,
  Value<DateTime?> lastUpdated,
  Value<int> rowid,
});

class $$OfflineMapPackagesTableFilterComposer
    extends Composer<_$AppDatabase, $OfflineMapPackagesTable> {
  $$OfflineMapPackagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get regionId => $composableBuilder(
      column: $table.regionId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVector => $composableBuilder(
      column: $table.isVector, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));
}

class $$OfflineMapPackagesTableOrderingComposer
    extends Composer<_$AppDatabase, $OfflineMapPackagesTable> {
  $$OfflineMapPackagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get regionId => $composableBuilder(
      column: $table.regionId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get filePath => $composableBuilder(
      column: $table.filePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
      column: $table.sizeBytes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVector => $composableBuilder(
      column: $table.isVector, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));
}

class $$OfflineMapPackagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OfflineMapPackagesTable> {
  $$OfflineMapPackagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get regionId =>
      $composableBuilder(column: $table.regionId, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<bool> get isVector =>
      $composableBuilder(column: $table.isVector, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);
}

class $$OfflineMapPackagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OfflineMapPackagesTable,
    OfflineMapPackage,
    $$OfflineMapPackagesTableFilterComposer,
    $$OfflineMapPackagesTableOrderingComposer,
    $$OfflineMapPackagesTableAnnotationComposer,
    $$OfflineMapPackagesTableCreateCompanionBuilder,
    $$OfflineMapPackagesTableUpdateCompanionBuilder,
    (
      OfflineMapPackage,
      BaseReferences<_$AppDatabase, $OfflineMapPackagesTable, OfflineMapPackage>
    ),
    OfflineMapPackage,
    PrefetchHooks Function()> {
  $$OfflineMapPackagesTableTableManager(
      _$AppDatabase db, $OfflineMapPackagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OfflineMapPackagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OfflineMapPackagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OfflineMapPackagesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> regionId = const Value.absent(),
            Value<String> filePath = const Value.absent(),
            Value<int> sizeBytes = const Value.absent(),
            Value<bool> isVector = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<DateTime?> lastUpdated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineMapPackagesCompanion(
            regionId: regionId,
            filePath: filePath,
            sizeBytes: sizeBytes,
            isVector: isVector,
            status: status,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String regionId,
            required String filePath,
            Value<int> sizeBytes = const Value.absent(),
            Value<bool> isVector = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<DateTime?> lastUpdated = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OfflineMapPackagesCompanion.insert(
            regionId: regionId,
            filePath: filePath,
            sizeBytes: sizeBytes,
            isVector: isVector,
            status: status,
            lastUpdated: lastUpdated,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OfflineMapPackagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OfflineMapPackagesTable,
    OfflineMapPackage,
    $$OfflineMapPackagesTableFilterComposer,
    $$OfflineMapPackagesTableOrderingComposer,
    $$OfflineMapPackagesTableAnnotationComposer,
    $$OfflineMapPackagesTableCreateCompanionBuilder,
    $$OfflineMapPackagesTableUpdateCompanionBuilder,
    (
      OfflineMapPackage,
      BaseReferences<_$AppDatabase, $OfflineMapPackagesTable, OfflineMapPackage>
    ),
    OfflineMapPackage,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MountainRegionsTableTableManager get mountainRegions =>
      $$MountainRegionsTableTableManager(_db, _db.mountainRegions);
  $$TrailsTableTableManager get trails =>
      $$TrailsTableTableManager(_db, _db.trails);
  $$PointsOfInterestTableTableManager get pointsOfInterest =>
      $$PointsOfInterestTableTableManager(_db, _db.pointsOfInterest);
  $$UserBreadcrumbsTableTableManager get userBreadcrumbs =>
      $$UserBreadcrumbsTableTableManager(_db, _db.userBreadcrumbs);
  $$OfflineMapPackagesTableTableManager get offlineMapPackages =>
      $$OfflineMapPackagesTableTableManager(_db, _db.offlineMapPackages);
}
