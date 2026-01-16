CONTEXT: We are upgrading the "PANDU" map experience. Currently, the map shows trails, but users cannot click on "Mountain" or "Basecamp" icons to get info. I need you to implement clickable markers and the logic to auto-select trails.

YOUR OBJECTIVE:

Render Mountains and Basecamps as clickable icons on the MapLibre map.

Implement the interaction flow:

Tap Mountain: Show MountainDetailSheet (Stats, Info, List of Basecamps).

Tap Basecamp: Show BasecampPreviewSheet with a "Start Hike" button.

Implement "Auto-Trail Selection": When "Start Hike" is tapped, find the trail starting at that basecamp and draw it.

TASK 1: Update MapLayerService (Visualization)

File: lib/core/services/map_layer_service.dart

Instructions:

Add drawMountainMarkers(): Fetch all MountainRegions. Create a GeoJSON Source + SymbolLayer (ID: layer_mountain_markers). Use a mountain icon. Put the id in properties.

Add drawBasecampMarkers(): Fetch all PointsOfInterest where type == PoiType.basecamp. Create a Source + SymbolLayer (ID: layer_basecamp_markers). Use a tent/house icon. Put the id in properties.

Ensure these are called in the drawMapLayers sequence.

TASK 2: Implement "Smart Trail Finder" (Logic)

File: lib/data/local/daos/daos.dart (NavigationDao)

Instructions:

Add a method: Future<Trail?> getTrailForBasecamp(PointOfInterest basecamp).

Logic:

Fetch all trails for basecamp.mountainId.

Iterate through trails. Decode the first point of the geometryJson.

Calculate distance between basecamp location and trail start point.

Return the trail if distance < 500m (nearest match).

TASK 3: Create UI Sheets (Presentation)

New File: lib/features/navigation/presentation/widgets/sheets/mountain_detail_sheet.dart

Show Mountain Name, Height (if available), Status.

List available Basecamps (clickable -> closes sheet, zooms to basecamp).

New File: lib/features/navigation/presentation/widgets/sheets/basecamp_preview_sheet.dart

Show Basecamp Name.

Primary Button: "Start Hike Here".

Action: On press, call the "Smart Trail Finder" from Task 2. If a trail is found, set it as the active trail in the provider and close the sheet.

TASK 4: Handle Map Interactions (Wiring)

File: lib/features/navigation/presentation/offline_map_screen.dart

Instructions:

In onMapCreated (or style loaded), setup onFeatureClick listener.

Check feature.id or layer ID.

If layer is layer_mountain_markers -> Fetch ID -> Show MountainDetailSheet.

If layer is layer_basecamp_markers -> Fetch ID -> Show BasecampPreviewSheet.

CONSTRAINTS:

Use showModalBottomSheet for the sheets.

Ensure the "Start Hike" action immediately draws the polyline for the found trail (use the existing mapLayerService.drawTrail or similar logic).

Handle the case where no trail matches the basecamp (show a SnackBar: "No mapped trail found for this basecamp").