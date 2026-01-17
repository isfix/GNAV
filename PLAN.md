CONTEXT: The user is now using gpx.studio to manage map data. They will provide a single GPX file that contains:

Tracks (<trk>): The hiking route (Polyline).

Waypoints (<wpt>): Important locations like "Basecamp Selo", "Pos 1", "Summit", etc.

YOUR OBJECTIVE: Upgrade TrackLoaderService to parse both Tracks and Waypoints from the same GPX file and insert them into the Trails and PointsOfInterest tables respectively. You must also apply "Smart Tagging" to categorize waypoints based on their names.

TASK 1: Upgrade TrackLoaderService (The Universal Loader)

File: lib/core/services/track_loader_service.dart

Instructions:

Refactor loadGpxTrack (or create loadFullGpxData) to accept String assetPath, String mountainId, String trailId.

Step A: Process Tracks (gpx.trks)

(Keep existing logic) Parse points, calculate distance/elevation.

(New) Calculate minLat, maxLat, minLng, maxLng for the spatial index.

Insert into Trails table.

Step B: Process Waypoints (gpx.wpts)

Iterate through gpx.wpts.

Smart Tagging Heuristic: Check the wpt.name:

If name contains "Basecamp" or "Pos Pendakian" -> Set type = PoiType.basecamp.

If name contains "Summit", "Puncak", "Top" -> Set type = PoiType.summit.

If name contains "Water", "Sumber Air" -> Set type = PoiType.water.

Default -> Set type = PoiType.shelter (covers Viewpoints/Pos).

Create PointsOfInterestCompanion using the waypoint's lat, lon, ele, and name.

Insert into PointsOfInterest table.

TASK 2: Update SeedingService

File: lib/core/services/seeding_service.dart

Instructions:

Update seedMerbabu (and others) to remove the manually coded POIs (_bc(...), _poi(...)).

Instead, just call the loader:

Dart

await _trackLoader.loadFullGpxData(
  'assets/tracks/merbabu/selo.gpx', 
  'merbabu', 
  'merbabu_selo'
);
Note: This assumes selo.gpx now contains the Basecamp and Summit points inside it.

TASK 3: Constraints & Edge Cases

Ensure the PointsOfInterest ID is generated uniquely (e.g., "${mountainId}_${wpt.name.replaceAll(' ', '_')}").

Handle case-insensitive string matching for the Smart Tagging (e.g., "basecamp" vs "Basecamp").