ROLE: You are a Senior Flutter/Native Architect refactoring a hiking app to be Offline-First and GPX-Centric.

OBJECTIVE: Refactor the app to remove the unstable Native Routing engine (GraphHopper) and replace it with a robust "Strict Track Following" architecture.

Visuals: Use offline Vector .mbtiles files (OpenMapTiles schema) for the background map.

Logic: Use GPX files for the "Blue Line", "Off-Trail" detection, and "Distance to Summit" math.

Data: Use GPX Waypoints (<wpt>) to automatically populate Basecamps and Summits.

TASK 1: The Great Purge (Delete Unused Complexity)

Action: Delete the following files/folders:

android/app/src/main/kotlin/com/example/pandu_navigation/GraphHopperService.kt

lib/core/services/routing_initialization_service.dart

lib/core/services/native_routing_service.dart

Cleanup: Remove all references to these services in lib/main.dart and lib/core/services/background_service.dart.

TASK 2: Implement Vector Map Support (Visuals)

New File: Create lib/core/utils/offline_map_style_helper.dart.

Logic: Implement a static method getOfflineStyle that loads your existing JSON style and injects the local MBTiles path.

Dart
import 'dart:convert';
import 'package:flutter/services.dart';

class OfflineMapStyleHelper {
  static Future<String> getOfflineStyle(String mbtilesPath) async {
    // 1. Load the existing vector style
    final styleString = await rootBundle.loadString('assets/map_styles/dark_mountain.json');
    final Map<String, dynamic> style = json.decode(styleString);

    // 2. Inject the local file path into the 'openmaptiles' source
    // MapLibre requires the 'mbtiles://' scheme for local files
    if (style.containsKey('sources') && style['sources'].containsKey('openmaptiles')) {
       style['sources']['openmaptiles']['url'] = 'mbtiles://$mbtilesPath';
       // Ensure type is vector
       style['sources']['openmaptiles']['type'] = 'vector';
    }

    return json.encode(style);
  }
}
Integration: In lib/features/navigation/presentation/offline_map_screen.dart, update the _loadMapStyle logic to use this helper when mountain.localMapPath is present.

TASK 3: Upgrade TrackLoaderService (The New Brain)

File: lib/core/services/track_loader_service.dart

Requirement: Refactor loadGpxTrack to loadFullGpxData(String assetPath, String mountainId).

Logic:

Parse Tracks (<trk>): Extract points. Calculate distanceFromStart for each point (cumulative). Compute minLat/maxLat/minLng/maxLng bounds. Save this as a Trail in the database.

Parse Waypoints (<wpt>): Iterate through all waypoints.

Auto-Tagging:

If name contains "Basecamp", "Pos", "BC" -> PoiType.basecamp

If name contains "Summit", "Puncak", "Top" -> PoiType.summit

Else -> PoiType.shelter

Insert: Save these as PointsOfInterest in the database, linked to mountainId.

TASK 4: Refactor DeviationEngine (Point-to-Line Logic)

File: lib/features/navigation/logic/deviation_engine.dart

Logic: Simplify the engine to work without a Graph.

Input: User LatLng and Active Trail (List of points).

Calculation: Use GeoMath.distanceToSegment to find the closest point on the trail.

Rule:

If distance > 50 meters -> Return DeviationStatus.offTrack.

Else -> Return DeviationStatus.onTrack.

Progress: Calculate the user's progress (%) based on the index of the closest point relative to the total points.

TASK 5: Update Data Seeding

File: lib/core/services/seeding_service.dart

Action:

Remove all hardcoded lists of coordinates (e.g., _merbabuRoute).

Update seedMerbabu() to use the new loader:

Dart
await _trackLoader.loadFullGpxData(
  'assets/tracks/merbabu/selo.gpx',
  'merbabu'
);
CONSTRAINTS:

Ensure pubspec.yaml includes the assets/maps/ folder.

Do NOT use any external routing APIs.

The system must work 100% offline using only the .mbtiles and .gpx assets.