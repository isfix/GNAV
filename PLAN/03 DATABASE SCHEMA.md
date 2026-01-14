Here is the robust, expanded version of **File 3 (`03_database_schema.md`)**.

This file tells the AI exactly how to structure the local SQLite database using **Drift**. It solves the specific problem of linking "Static Data" (Maps/Trails) with "Dynamic Data" (User Movement).

Copy the content below and save it exactly as `ai_docs/03_database_schema.md`.

***

```markdown
# DATABASE SCHEMA & DATA MODEL (Drift/SQLite)

## 1. OVERVIEW
We use **Drift** (formerly Moor) for the local database.
*   **Role:** The single source of truth for the app.
*   **Persistence:** All data (Maps, Trails, User Logs) must persist if the app is killed or the phone reboots.
*   **Concurrency:** The Background Service (GPS) writes to this DB, while the UI reads from it. Drift's stream watchers handle this synchronization.

---

## 2. TABLES DEFINITION

### Table A: `MountainRegions` (The "Offline Pack")
*Represents a physical mountain block (e.g., "Mount Merbabu") that the user has downloaded.*

| Column Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | String | PK | Unique ID (e.g., `merbabu_central_java`) |
| `name` | String | Not Null | Display name (e.g., "Gunung Merbabu") |
| `description` | String | Nullable | Brief summary |
| `local_map_path` | String | Nullable | Absolute path to the `.mbtiles` file on device storage |
| `boundary_json` | String | Not Null | GeoJSON Polygon defining the map bounds (for camera fitting) |
| `version` | Int | Default(1) | To trigger updates if trail data changes |
| `is_downloaded` | Bool | Default(false) | UI flag |

### Table B: `Trails` (The "Safe Corridors")
*Represents the hiking paths within a Mountain Region. One mountain has multiple trails.*

| Column Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | String | PK | Unique ID (e.g., `merbabu_selo`) |
| `mountain_id` | String | FK -> Regions.id | Links trail to the mountain |
| `name` | String | Not Null | e.g., "Jalur Selo" |
| `geometry_json` | String | Not Null | **CRITICAL:** GeoJSON `LineString` of the path coordinates |
| `difficulty` | Int | Not Null | 1 (Easy) to 5 (Extreme) |
| `is_official` | Bool | Default(true) | False = "Jalur Tikus" (Unofficial/Animal trail) |

### Table C: `PointsOfInterest` (The "Anchors")
*Critical survival features: Water, Camps, Danger Zones.*

| Column Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | String | PK | Unique ID |
| `mountain_id` | String | FK -> Regions.id | |
| `type` | Int | Not Null | Enum: 0=Basecamp, 1=Water, 2=Shelter, 3=DangerZone, 4=Summit |
| `lat` | Double | Not Null | |
| `lng` | Double | Not Null | |
| `elevation` | Double | Nullable | Altitude in MDPL (Meters Above Sea Level) |
| `metadata_json` | String | Nullable | Extra info (e.g., "Water dries up in August") |

### Table D: `UserBreadcrumbs` (The "Black Box" Recorder)
*Stores the user's movement history. High write frequency.*

| Column Name | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | Int | PK, AutoInc | |
| `session_id` | String | Not Null | Grouping ID for a specific hike |
| `lat` | Double | Not Null | |
| `lng` | Double | Not Null | |
| `altitude` | Double | Nullable | |
| `accuracy` | Double | Not Null | GPS Accuracy in meters (Important for filtering) |
| `timestamp` | DateTime | Not Null | |
| `is_synced` | Bool | Default(false) | For future cloud sync |

---

## 3. DATA ACCESS OBJECTS (DAOs)

### `MountainDao`
*   `getAllRegions()`: Returns list of available mountains.
*   `getDownloadedRegions()`: Returns only mountains where `is_downloaded` = true.
*   `updateRegionPath(id, path)`: Called after download completes.

### `NavigationDao` (The "Read-Heavy" DAO)
*   `getTrailsForMountain(mountainId)`: Returns all trails to draw on the map.
*   `getPoisForMountain(mountainId)`: Returns all POIs.
*   `getNearestWaterSource(currentLat, currentLng)`: Spatial query (Euclidean approximation) to find nearest water.

### `TrackingDao` (The "Write-Heavy" DAO)
*   `insertBreadcrumb(entry)`: Called by Background Service every 10-30s.
*   `getSessionHistory(sessionId)`: Used to draw the "Where I've been" line.
*   `cleanOldData()`: Deletes logs older than 30 days to save space.

---

## 4. TYPE CONVERTERS & JSON HANDLING
Since SQLite doesn't natively support JSON or Enums, we use Drift's `TypeConverter`:

1.  **`GeoJsonConverter`**: Converts `List<GeoPoint>` <-> `String` (JSON).
    *   *Why:* We store trail geometry as a JSON string string like `[[110.4, -7.5], [110.5, -7.6]]` and parse it back to Dart objects at runtime.
2.  **`PoiTypeConverter`**: Converts `Enum` <-> `Int`.

---

## 5. INDEXING STRATEGY
*   **Index on `Trails(mountain_id)`**: Essential for fast map loading.
*   **Index on `UserBreadcrumbs(session_id, timestamp)`**: Essential for quickly rendering the user's path history without freezing the UI.
```