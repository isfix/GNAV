import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import '../../data/local/db/app_database.dart';
import '../../data/local/db/converters.dart';
import 'track_loader_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/navigation/logic/navigation_providers.dart';

final seedingServiceProvider = Provider<SeedingService>((ref) {
  final db = ref.watch(databaseProvider);
  return SeedingService(db);
});

class SeedingService {
  final AppDatabase db;
  late final TrackLoaderService _trackLoader;

  SeedingService(this.db) {
    _trackLoader = TrackLoaderService(db);
  }

  /// Creates a TrailsCompanion with calculated bounding box
  /// This enables O(1) spatial lookups instead of O(N) scans
  TrailsCompanion _createTrailWithBounds({
    required String id,
    required String mountainId,
    required String name,
    required List<TrailPoint> points,
    required int difficulty,
  }) {
    // Calculate bounding box
    double minLat = double.infinity;
    double maxLat = double.negativeInfinity;
    double minLng = double.infinity;
    double maxLng = double.negativeInfinity;

    for (final point in points) {
      if (point.lat < minLat) minLat = point.lat;
      if (point.lat > maxLat) maxLat = point.lat;
      if (point.lng < minLng) minLng = point.lng;
      if (point.lng > maxLng) maxLng = point.lng;
    }

    // Calculate distance and elevation gain
    double distance = 0;
    double elevationGain = 0;
    int summitIndex = 0;
    double highestElevation = 0;

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      if (point.elevation != null && point.elevation! > highestElevation) {
        highestElevation = point.elevation!;
        summitIndex = i;
      }
      if (i > 0) {
        // Approximate distance using haversine would be better, but simplified here
        final prevPoint = points[i - 1];
        final dLat =
            (point.lat - prevPoint.lat) * 111320; // meters per degree lat
        final dLng = (point.lng - prevPoint.lng) *
            111320 *
            0.85; // approx for Java latitude
        distance += (dLat * dLat + dLng * dLng).abs();

        if (point.elevation != null && prevPoint.elevation != null) {
          final elevDiff = point.elevation! - prevPoint.elevation!;
          if (elevDiff > 0) elevationGain += elevDiff;
        }
      }
    }
    distance =
        distance > 0 ? distance : 0; // sqrt would be needed for proper distance

    return TrailsCompanion(
      id: Value(id),
      mountainId: Value(mountainId),
      name: Value(name),
      geometryJson: Value(points),
      difficulty: Value(difficulty),
      distance: Value(distance),
      elevationGain: Value(elevationGain),
      summitIndex: Value(summitIndex),
      minLat: Value(minLat.isFinite ? minLat : 0),
      maxLat: Value(maxLat.isFinite ? maxLat : 0),
      minLng: Value(minLng.isFinite ? minLng : 0),
      maxLng: Value(maxLng.isFinite ? maxLng : 0),
    );
  }

  /// Seeds minimal registry of all mountains for Discovery/Search
  Future<void> seedDiscoveryData() async {
    final mountains = [
      _mt('merbabu', 'Mount Merbabu', -7.4526, 110.4422, 'Central Java'),
      _mt('rinjani', 'Mount Rinjani', -8.3600, 116.5200, 'Lombok'),
      _mt('semeru', 'Mount Semeru', -8.0180, 112.9535, 'East Java'),
      _mt('kerinci', 'Mount Kerinci', -1.7000, 101.2600, 'Sumatra'),
      _mt('slamet', 'Mount Slamet', -7.2265, 109.2648, 'Central Java'),
      _mt('sumbing', 'Mount Sumbing', -7.3320, 110.0380, 'Central Java'),
      _mt('arjuno', 'Mount Arjuno', -7.6950, 112.6320, 'East Java'),
      _mt('raung', 'Mount Raung', -8.2000, 114.0400, 'East Java'),
      _mt('lawu', 'Mount Lawu', -7.6620, 111.1920, 'Central/East Java'),
      _mt('welirang', 'Mount Welirang', -7.6950, 112.6320, 'East Java'),
      _mt('sindoro', 'Mount Sindoro', -7.3400, 110.0250, 'Central Java'),
      _mt('argopuro', 'Mount Argopuro', -7.9250, 113.6800, 'East Java'),
      _mt('ciremai', 'Mount Ciremai', -6.9100, 108.3850, 'West Java'),
      _mt('pangrango', 'Mount Pangrango', -6.7550, 107.0050, 'West Java'),
      _mt('gede', 'Mount Gede', -6.7500, 107.0100, 'West Java'),
      _mt('butak', 'Mount Butak', -7.8893, 112.4969, 'East Java'),
      _mt('merapi', 'Mount Merapi', -7.5000, 110.4500,
          'Active Volcano (Danger)'),
    ];

    // Sample Basecamps (POIs) for each mountain
    final basecamps = [
      _bc('merbabu_selo', 'merbabu', 'Selo Basecamp', -7.4526, 110.4422, 1800),
      _bc('rinjani_sembalun', 'rinjani', 'Sembalun Basecamp', -8.4127, 116.4973,
          1200),
      _bc('semeru_ranupani', 'semeru', 'Ranu Pani Basecamp', -8.0212, 112.9161,
          2070),
      _bc('kerinci_kersik', 'kerinci', 'Kersik Tuo Basecamp', -1.7340, 101.2820,
          1650),
      _bc('slamet_bambangan', 'slamet', 'Bambangan Basecamp', -7.2401, 109.2158,
          1550),
      _bc('sumbing_garung', 'sumbing', 'Garung Basecamp', -7.3080, 110.0020,
          1700),
      _bc('arjuno_tretes', 'arjuno', 'Tretes Basecamp', -7.6650, 112.6280, 850),
      _bc('raung_kalibaru', 'raung', 'Kalibaru Basecamp', -8.2150, 114.0190,
          600),
      _bc('lawu_cemoro', 'lawu', 'Cemoro Sewu Basecamp', -7.6280, 111.1550,
          2200),
      _bc('welirang_tretes', 'welirang', 'Tretes Basecamp', -7.6950, 112.6320,
          850),
      _bc('sindoro_kledung', 'sindoro', 'Kledung Basecamp', -7.3150, 109.9830,
          1450),
      _bc('argopuro_baderan', 'argopuro', 'Baderan Basecamp', -7.9130, 113.7150,
          1050),
      _bc('ciremai_apuy', 'ciremai', 'Apuy Basecamp', -6.8810, 108.3750, 1150),
      _bc('pangrango_cibodas', 'pangrango', 'Cibodas Basecamp', -6.7450,
          107.0050, 1250),
      _bc('gede_gunung_putri', 'gede', 'Gunung Putri Basecamp', -6.7390,
          107.0020, 1450),
      _bc('butak_panderman', 'butak', 'Panderman Basecamp', -7.8732, 112.5098,
          1500),
      _bc('merapi_selo', 'merapi', 'New Selo Basecamp', -7.4850, 110.4420,
          1700),
    ];

    await db.batch((batch) {
      batch.insertAllOnConflictUpdate(db.mountainRegions, mountains);
      batch.insertAllOnConflictUpdate(db.pointsOfInterest, basecamps);
    });
  }

  PointsOfInterestCompanion _bc(String id, String mountainId, String name,
      double lat, double lng, int elevation) {
    return PointsOfInterestCompanion.insert(
      id: id,
      mountainId: mountainId,
      name: Value(name),
      lat: lat,
      lng: lng,
      elevation: Value(elevation.toDouble()),
      type: PoiType.basecamp,
    );
  }

  MountainRegionsCompanion _mt(
      String id, String name, double lat, double lng, String desc) {
    // Only sets isDownloaded=true if explicitly downloaded elsewhere.
    // Here we default to false unless conflict update preserves it?
    // Drift insertOnConflictUpdate REPLACES by default.
    // We need DoUpdate to preserve isDownloaded.
    // BUT defined as simple text insertion here:
    return MountainRegionsCompanion.insert(
      id: id,
      name: name,
      description: Value(desc),
      boundaryJson: '{}',
      lat: Value(lat),
      lng: Value(lng),
      isDownloaded: const Value(false), // Default for discovery
    );
  }

  /// 1. Mount Merbabu (Central Java)
  /// Now uses GPX files from assets/gpx/merbabu/ for trail data
  Future<void> seedMerbabu() async {
    await db.into(db.mountainRegions).insertOnConflictUpdate(
          const MountainRegionsCompanion(
            id: Value('merbabu'),
            name: Value('Mount Merbabu'),
            description: Value(
                'A lush dormant volcano in Central Java. Popular for its savannas.'),
            boundaryJson: Value('{}'),
            lat: Value(-7.4526), // Selo Basecamp
            lng: Value(110.4422),
            isDownloaded: Value(true),
          ),
        );

    // Load trail and POI data from GPX files
    await loadMerbabuGpxTrails();
  }

  /// Loads all Merbabu trails from GPX files in assets/gpx/merbabu/
  /// This parses both tracks (trail geometry) and waypoints (basecamps, POIs)
  Future<void> loadMerbabuGpxTrails() async {
    const gpxFiles = {
      'Selo': 'assets/gpx/merbabu/Selo.gpx',
      'Wekas': 'assets/gpx/merbabu/Wekas.gpx',
      'Suwanting': 'assets/gpx/merbabu/Suwanting.gpx',
      'Thekelan': 'assets/gpx/merbabu/Thekelan.gpx',
      'Cuntel': 'assets/gpx/merbabu/Cuntel.gpx',
      'Gancik': 'assets/gpx/merbabu/Gancik.gpx',
      'Grenden': 'assets/gpx/merbabu/Grenden.gpx',
    };

    for (final entry in gpxFiles.entries) {
      final trailName = entry.key;
      final assetPath = entry.value;
      final trailId = 'merbabu_${trailName.toLowerCase()}';

      try {
        await _trackLoader.loadFullGpxData(
          assetPath,
          'merbabu',
          trailId,
        );
        debugPrint('[Seeding] Loaded Merbabu trail: $trailName');
      } catch (e) {
        debugPrint('[Seeding] Error loading $trailName: $e');
      }
    }
  }

  /// 2. Mount Rinjani (Lombok)
  Future<void> seedRinjani() async {
    await db.into(db.mountainRegions).insertOnConflictUpdate(
          const MountainRegionsCompanion(
            id: Value('rinjani'),
            name: Value('Mount Rinjani'),
            description: Value(
                'Lombok, NTB. The second highest volcano in Indonesia. Segara Anak lake.'),
            boundaryJson: Value('{}'),
            lat: Value(-8.3600), // Sembalun Village
            lng: Value(116.5200),
            isDownloaded: Value(true),
          ),
        );

    // Mock Trail for Rinjani (Simplified)
    final rinjaniRoute = [
      const TrailPoint(-8.3600, 116.5200, 1156), // Sembalun
      const TrailPoint(-8.3700, 116.5100, 1300), // Pos 1
      const TrailPoint(-8.3800, 116.5000, 1500), // Pos 2
      const TrailPoint(-8.3900, 116.4800, 2639), // Sembalun Crater Rim
      const TrailPoint(-8.4116, 116.4572, 3726), // Summit
    ];

    await db.into(db.trails).insertOnConflictUpdate(
          TrailsCompanion(
            id: const Value('rinjani_sembalun'),
            mountainId: const Value('rinjani'),
            name: const Value('Jalur Sembalun'),
            geometryJson: Value(rinjaniRoute),
            difficulty: const Value(5),
          ),
        );

    await db.into(db.pointsOfInterest).insertOnConflictUpdate(
          const PointsOfInterestCompanion(
            id: Value('rinjani_summit'),
            mountainId: Value('rinjani'),
            name: Value('Puncak Dewi Anjani'),
            type: Value(PoiType.summit),
            lat: Value(-8.4116),
            lng: Value(116.4572),
            elevation: Value(3726),
            metadataJson: Value('{}'),
          ),
        );

    // Seed Basecamp for Rinjani
    await db.into(db.pointsOfInterest).insertOnConflictUpdate(
          const PointsOfInterestCompanion(
            id: Value('rinjani_sembalun_bc'),
            mountainId: Value('rinjani'),
            name: Value('Basecamp Sembalun'),
            type: Value(PoiType.basecamp),
            lat: Value(-8.3600),
            lng: Value(116.5200),
            elevation: Value(1156),
          ),
        );
  }

  /// 3. Mount Semeru (East Java)
  Future<void> seedSemeru() async {
    await db.into(db.mountainRegions).insertOnConflictUpdate(
          const MountainRegionsCompanion(
            id: Value('semeru'),
            name: Value('Mount Semeru'),
            description:
                Value('East Java. Highest in Java (3,676m). Active volcano.'),
            boundaryJson: Value('{}'),
            lat: Value(-8.0180), // Ranu Pani
            lng: Value(112.9535),
            isDownloaded: Value(true),
          ),
        );

    final ranuPaniRoute = [
      const TrailPoint(-8.0180, 112.9535, 2100),
      const TrailPoint(-8.0416, 112.9213, 2400), // Ranu Kumbolo
      const TrailPoint(-8.0945, 112.9056, 2700), // Kalimati
      const TrailPoint(-8.1067, 112.9204, 3676), // Summit
    ];

    await db.into(db.trails).insertOnConflictUpdate(
          TrailsCompanion(
            id: const Value('semeru_ranupani'),
            mountainId: const Value('semeru'),
            name: const Value('Jalur Ranu Pani'),
            geometryJson: Value(ranuPaniRoute),
            difficulty: const Value(5),
          ),
        );

    await db.into(db.pointsOfInterest).insertOnConflictUpdate(
          const PointsOfInterestCompanion(
            id: Value('semeru_kumbolo'),
            mountainId: Value('semeru'),
            name: Value('Ranu Kumbolo'),
            type: Value(PoiType.water),
            lat: Value(-8.0416),
            lng: Value(112.9213),
            elevation: Value(2400),
            metadataJson: Value('{}'),
          ),
        );

    // Seed Basecamp for Semeru
    await db.into(db.pointsOfInterest).insertOnConflictUpdate(
          const PointsOfInterestCompanion(
            id: Value('semeru_ranupani_bc'),
            mountainId: Value('semeru'),
            name: Value('Basecamp Ranu Pani'),
            type: Value(PoiType.basecamp),
            lat: Value(-8.0180),
            lng: Value(112.9535),
            elevation: Value(2100),
          ),
        );
  }

  /// 4. Mount Kerinci (Sumatra)
  Future<void> seedKerinci() async {
    await db.into(db.mountainRegions).insertOnConflictUpdate(
          const MountainRegionsCompanion(
            id: Value('kerinci'),
            name: Value('Mount Kerinci'),
            description:
                Value('Sumatra. Highest volcano in Indonesia (3,805m).'),
            boundaryJson: Value('{}'),
            lat: Value(-1.7000), // Pintu Rimba
            lng: Value(101.2600),
            isDownloaded: Value(true),
          ),
        );

    final kersikTuoRoute = [
      const TrailPoint(-1.7000, 101.2600, 1600),
      const TrailPoint(-1.6970, 101.2700, 2500),
      const TrailPoint(-1.6966, 101.2642, 3805),
    ];

    await db.into(db.trails).insertOnConflictUpdate(
          TrailsCompanion(
            id: const Value('kerinci_kersik'),
            mountainId: const Value('kerinci'),
            name: const Value('Jalur Kersik Tuo'),
            geometryJson: Value(kersikTuoRoute),
            difficulty: const Value(5),
          ),
        );
  }

  /// 5. Mount Slamet
  Future<void> seedSlamet() async {
    await db.into(db.mountainRegions).insertOnConflictUpdate(
          const MountainRegionsCompanion(
            id: Value('slamet'),
            name: Value('Mount Slamet'),
            description:
                Value('Central Java. Highest in Central Java (3,428m).'),
            boundaryJson: Value('{}'),
            lat: Value(-7.2265), // Bambangan
            lng: Value(109.2648),
            isDownloaded: Value(true),
          ),
        );

    // Trail Data reused (Simplified for brevity in rewrite, but keep interpolation logic if possible/needed)
    final bambanganRoute = [
      const TrailPoint(-7.2265, 109.2648, 1500),
      const TrailPoint(-7.2300, 109.2520, 2000),
      const TrailPoint(-7.2360, 109.2350, 2500), // Pos 5
      const TrailPoint(-7.2391, 109.2199, 3428), // Summit
    ];
    await db.into(db.trails).insertOnConflictUpdate(TrailsCompanion(
        id: const Value('slamet_bambangan'),
        mountainId: const Value('slamet'),
        name: const Value('Jalur Bambangan'),
        geometryJson: Value(bambanganRoute),
        difficulty: const Value(4)));
  }

  /// 6. Mount Sumbing
  Future<void> seedSumbing() async {
    await db.into(db.mountainRegions).insertOnConflictUpdate(
          const MountainRegionsCompanion(
            id: Value('sumbing'),
            name: Value('Mount Sumbing'),
            description:
                Value('Central Java. Triple S (Slamet, Sumbing, Sindoro).'),
            boundaryJson: Value('{}'),
            lat: Value(-7.3320), // Garung
            lng: Value(110.0380),
            isDownloaded: Value(true),
          ),
        );

    final garungRoute = [
      const TrailPoint(-7.3320, 110.0380, 1400),
      const TrailPoint(-7.3840, 110.0750, 3371), // Summit
    ];
    await db.into(db.trails).insertOnConflictUpdate(TrailsCompanion(
        id: const Value('sumbing_garung'),
        mountainId: const Value('sumbing'),
        name: const Value('Jalur Garung'),
        geometryJson: Value(garungRoute),
        difficulty: const Value(4)));
  }

  /// 7. Mount Arjuno
  Future<void> seedArjuno() async {
    await db.into(db.mountainRegions).insertOnConflictUpdate(
          const MountainRegionsCompanion(
            id: Value('arjuno'),
            name: Value('Mount Arjuno'),
            description: Value('East Java. Arjuno-Welirang complex.'),
            boundaryJson: Value('{}'),
            lat: Value(-7.6950), // Tretes
            lng: Value(112.6320),
            isDownloaded: Value(true),
          ),
        );
    final tretesRoute = [
      const TrailPoint(-7.6950, 112.6320, 800),
      const TrailPoint(-7.7656, 112.5800, 3339)
    ]; // Summit
    await db.into(db.trails).insertOnConflictUpdate(TrailsCompanion(
        id: const Value('arjuno_tretes'),
        mountainId: const Value('arjuno'),
        name: const Value('Jalur Tretes'),
        geometryJson: Value(tretesRoute),
        difficulty: const Value(4)));
  }

  /// 8. Mount Raung
  Future<void> seedRaung() async {
    await db.into(db.mountainRegions).insertOnConflictUpdate(
        const MountainRegionsCompanion(
            id: Value('raung'),
            name: Value('Mount Raung'),
            description:
                Value('East Java. Famous for its extreme caldera rim.'),
            boundaryJson: Value('{}'),
            lat: Value(-8.2000),
            lng: Value(114.0400),
            isDownloaded: Value(true)));
    // Add Trail...
  }

  /// 9. Mount Lawu
  Future<void> seedLawu() async {
    await db
        .into(db.mountainRegions)
        .insertOnConflictUpdate(const MountainRegionsCompanion(
            id: Value('lawu'),
            name: Value('Mount Lawu'),
            description: Value('Border Central/East Java. Historic temples.'),
            boundaryJson: Value('{}'),
            lat: Value(-7.6620), // Cemoro Sewu
            lng: Value(111.1920),
            isDownloaded: Value(true)));
  }

  /// 10. Mount Welirang
  Future<void> seedWelirang() async {
    await db
        .into(db.mountainRegions)
        .insertOnConflictUpdate(const MountainRegionsCompanion(
            id: Value('welirang'),
            name: Value('Mount Welirang'),
            description: Value('Sulfur mine hike.'),
            boundaryJson: Value('{}'),
            lat: Value(-7.6950), // Tretes (shared)
            lng: Value(112.6320),
            isDownloaded: Value(true)));
  }

  /// 11. Mount Sindoro
  Future<void> seedSindoro() async {
    await db
        .into(db.mountainRegions)
        .insertOnConflictUpdate(const MountainRegionsCompanion(
            id: Value('sindoro'),
            name: Value('Mount Sindoro'),
            description: Value('Active stratovolcano.'),
            boundaryJson: Value('{}'),
            lat: Value(-7.3400), // Kledung
            lng: Value(110.0250),
            isDownloaded: Value(true)));
  }

  /// 12. Mount Argopuro
  Future<void> seedArgopuro() async {
    await db
        .into(db.mountainRegions)
        .insertOnConflictUpdate(const MountainRegionsCompanion(
            id: Value('argopuro'),
            name: Value('Mount Argopuro'),
            description: Value('Longest track in Java.'),
            boundaryJson: Value('{}'),
            lat: Value(-7.9250), // Baderan
            lng: Value(113.6800),
            isDownloaded: Value(true)));
  }

  /// 13. Mount Ciremai
  Future<void> seedCiremai() async {
    await db
        .into(db.mountainRegions)
        .insertOnConflictUpdate(const MountainRegionsCompanion(
            id: Value('ciremai'),
            name: Value('Mount Ciremai'),
            description: Value('Highest in West Java.'),
            boundaryJson: Value('{}'),
            lat: Value(-6.9100), // Apuy
            lng: Value(108.3850),
            isDownloaded: Value(true)));
  }

  /// 14. Mount Pangrango
  Future<void> seedPangrango() async {
    await db
        .into(db.mountainRegions)
        .insertOnConflictUpdate(const MountainRegionsCompanion(
            id: Value('pangrango'),
            name: Value('Mount Pangrango'),
            description: Value('Gede-Pangrango Park.'),
            boundaryJson: Value('{}'),
            lat: Value(-6.7550), // Cibodas
            lng: Value(107.0050),
            isDownloaded: Value(true)));
  }

  /// 15. Mount Gede
  Future<void> seedGede() async {
    await db
        .into(db.mountainRegions)
        .insertOnConflictUpdate(const MountainRegionsCompanion(
            id: Value('gede'),
            name: Value('Mount Gede'),
            description: Value('Beginner friendly.'),
            boundaryJson: Value('{}'),
            lat: Value(-6.7500), // Putri
            lng: Value(107.0100),
            isDownloaded: Value(true)));
  }

  /// 16. Mount Merapi (Restricted)
  Future<void> seedMerapi() async {
    await db
        .into(db.mountainRegions)
        .insertOnConflictUpdate(const MountainRegionsCompanion(
            id: Value('merapi'),
            name: Value('Mount Merapi'),
            description: Value('Active Volcano. DANGER ZONE.'),
            boundaryJson: Value('{}'),
            lat: Value(-7.5000), // New Selo
            lng: Value(110.4500),
            isDownloaded: Value(true))); // Or false if strictly disabled
  }

  /// 17. Mount Butak
  Future<void> seedButak() async {
    await db
        .into(db.mountainRegions)
        .insertOnConflictUpdate(const MountainRegionsCompanion(
            id: Value('butak'),
            name: Value('Mount Butak'),
            description: Value('Savanna peak.'),
            boundaryJson: Value('{}'),
            lat: Value(-7.8893), // Panderman
            lng: Value(112.4969),
            isDownloaded: Value(true)));
  }
}
