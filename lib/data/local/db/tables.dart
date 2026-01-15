import 'package:drift/drift.dart';
import 'converters.dart';

// Table A: MountainRegions
// Force Rebuild
class MountainRegions extends Table {
  TextColumn get id => text()(); // Primary Key
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get localMapPath => text().nullable()();
  TextColumn get boundaryJson => text()(); // GeoJSON Polygon
  RealColumn get lat =>
      real().withDefault(const Constant(0.0))(); // Center/Basecamp Lat
  RealColumn get lng =>
      real().withDefault(const Constant(0.0))(); // Center/Basecamp Lng
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDownloaded => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Table B: Trails
class Trails extends Table {
  TextColumn get id => text()();
  TextColumn get mountainId => text().references(MountainRegions, #id)();
  TextColumn get name => text()();
  TextColumn get geometryJson => text().map(const GeoJsonConverter())();

  // Metadata
  RealColumn get distance =>
      real().withDefault(const Constant(0.0))(); // Total length (m)
  RealColumn get elevationGain =>
      real().withDefault(const Constant(0.0))(); // Total Gain (m)
  IntColumn get difficulty => integer().withDefault(const Constant(1))(); // 1-5
  IntColumn get summitIndex =>
      integer().withDefault(const Constant(0))(); // Index of Apex

  BoolColumn get isOfficial => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};

  // Index for fast lookup by mountain
  @override
  List<String> get customConstraints =>
      ['FOREIGN KEY (mountain_id) REFERENCES mountain_regions (id)'];
}

// Table C: PointsOfInterest
@DataClassName('PointOfInterest')
class PointsOfInterest extends Table {
  TextColumn get id => text()();
  TextColumn get mountainId => text().references(MountainRegions, #id)();
  TextColumn get name =>
      text().withDefault(const Constant('POI'))(); // Added Name
  IntColumn get type => integer().map(const PoiTypeConverter())();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get elevation => real().nullable()();
  TextColumn get metadataJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Table D: UserBreadcrumbs
class UserBreadcrumbs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get sessionId => text()();
  RealColumn get lat => real()();
  RealColumn get lng => real()();
  RealColumn get altitude => real().nullable()();
  RealColumn get accuracy => real()();
  RealColumn get speed => real().nullable()(); // Added Speed
  DateTimeColumn get timestamp => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  // Index on session_id and timestamp is auto-handled by Drift index API usually,
  // but we can define explicit indices if needed.
}

// Table E: OfflineMapPackages
class OfflineMapPackages extends Table {
  TextColumn get regionId => text()(); // e.g. 'java_island' or 'merbabu'
  TextColumn get filePath => text()(); // Local path to .mbtiles or .zip
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
  BoolColumn get isVector => boolean().withDefault(const Constant(false))();
  IntColumn get status => integer()
      .withDefault(const Constant(0))(); // 0=None, 1=Downloading, 2=Ready
  DateTimeColumn get lastUpdated => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {regionId};
}
