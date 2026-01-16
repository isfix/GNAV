

### **Agent Context**

> **Role:** Senior Flutter/Native Architect
> **Objective:** Refactor "PANDU Navigation" to fix critical architectural flaws (UI-coupled logic, O(N) loops, OOM risks) and implement corporate-grade signal processing.
> **Constraint:** Maintain offline-first capability. Use existing libraries (Drift, Riverpod, MapLibre) but change *how* they are used.

---

### **Phase 1: Decouple Safety Logic from UI (Critical)**

**Goal:** Ensure safety checks and haptics run even when the screen is off or the app is minimized.

**Files to Modify:**

1. `lib/core/services/background_service.dart`
2. `lib/features/navigation/logic/deviation_engine.dart`
3. `lib/features/navigation/presentation/offline_map_screen.dart` (Cleanup)

**Instructions for Agent:**

1. **Refactor `DeviationEngine`:**
* Make `DeviationEngine` a pure Dart class (no Flutter UI dependencies).
* Add a `checkSafety(Position userPos)` method that returns a `SafetyStatus` enum.
* Inject the `Database` instance directly into it, not via a Riverpod `ref`.


2. **Update `BackgroundService`:**
* Instantiate `DeviationEngine` inside the `onStart` method of the background service.
* **The Loop:** Inside the `Timer.periodic` (GPS loop):
1. Get raw GPS position.
2. *(Placeholder for Phase 4: Apply Kalman Filter).*
3. Pass position to `DeviationEngine.checkSafety()`.
4. If status is `DANGER`, trigger `Vibration.vibrate()` (ensure `vibration` package is configured for background).
5. `service.invoke('safety_status', status.name)` to send updates to the UI.




3. **Cleanup UI:**
* Remove `DeviationEngine` calls from `OfflineMapScreen`.
* Update `NavigationSheet` to listen to the `safety_status` stream from the background service instead of calculating it locally.



---

### **Phase 2: Fix the O(N) Loop with Spatial Indexing**

**Goal:** Prevent the "5-second freeze" by optimizing how we find relevant trails.

**Files to Modify:**

1. `lib/data/local/db/tables.dart`
2. `lib/core/services/seeding_service.dart`
3. `lib/features/navigation/logic/deviation_engine.dart`

**Instructions for Agent:**

1. **Modify Schema (`tables.dart`):**
* Add four `RealColumn` fields to the `Trail` table: `minLat`, `maxLat`, `minLng`, `maxLng`.
* Run `flutter pub run build_runner build` to regenerate Drift code.


2. **Update Seeding Logic (`seeding_service.dart`):**
* When parsing the GeoJSON/JSON for a trail, calculate the bounding box (min/max coordinates) of that trail's geometry.
* Insert these bounds into the new columns.


3. **Optimize Query (`deviation_engine.dart`):**
* Current Logic: `SELECT * FROM trails` (Fetch all).
* **New Logic:**
```dart
// Pseudo-code for Drift Query
final userLat = position.latitude;
final userLng = position.longitude;
final buffer = 0.005; // approx 500m buffer

final nearbyTrails = await (select(trails)
  ..where((t) =>
    t.minLat.isSmallerThanValue(userLat + buffer) &
    t.maxLat.isBiggerThanValue(userLat - buffer) &
    t.minLng.isSmallerThanValue(userLng + buffer) &
    t.maxLng.isBiggerThanValue(userLng - buffer)
  )).get();

```


* Only run the heavy geometry math on this filtered list (`nearbyTrails`).



---

### **Phase 3: Prevent OOM (The "PBF Timebomb")**

**Goal:** Stop the app from crashing on startup by removing heavy graph processing from the mobile device.

**Files to Modify:**

1. `lib/core/services/routing_initialization_service.dart`
2. `android/app/src/main/kotlin/.../GraphHopperService.kt`
3. `assets/` (Folder structure)

**Instructions for Agent:**

1. **Asset Restructuring:**
* **Action:** Create a strict rule: "We do not ship `.osm.pbf` files."
* **New Asset:** `assets/graph_cache/central_java_gh.zip` (containing the `nodes`, `edges`, `geometry` files generated on a PC).


2. **Update Initialization Service:**
* Modify `RoutingInitializationService` to copy the `.zip` from assets to `ApplicationDocumentsDirectory`.
* Unzip the folder.
* Point `GraphHopper` to this unzipped folder.


3. **Native Code Cleanup (`GraphHopperService.kt`):**
* Remove the `importOrLoad()` logic that parses PBFs.
* Change it to `load()` only. If the graph folder is corrupt or missing, return an error (don't try to rebuild it on the phone).



---

### **Phase 4: "Corporate Grade" Signal Processing**

**Goal:** Smooth out GPS noise so the safety engine doesn't panic when the GPS jumps 20 meters instantly.

**Files to Modify:**

1. `lib/core/utils/kalman_filter.dart` (New File)
2. `lib/core/services/background_service.dart`

**Instructions for Agent:**

1. **Create `KalmanFilter` Class:**
* Implement a simple 2D Kalman Filter (Lat/Lng).
* **State:** `x` (position), `p` (covariance), `q` (process noise), `r` (measurement noise).
* **Tuning:** Set `Q` (process noise) low (hiker moves slowly) and `R` (measurement noise) high (forest GPS is noisy).


2. **Integrate in Background Service:**
* Initialize `KalmanFilter` in `onStart`.
* Inside the GPS loop:
```dart
// Raw
final rawLat = position.latitude;
final rawLng = position.longitude;

// Smooth
final smoothed = _kalmanFilter.process(rawLat, rawLng);

// Use Smoothed for everything else
_db.insertBreadcrumb(smoothed);
_deviationEngine.checkSafety(smoothed);

```





---

### **Execution Priority**

Tell your agent to execute in this order:

1. **Phase 3** (Fixes the crash risk on startup).
2. **Phase 2** (Fixes the battery drain/lag).
3. **Phase 1** (Fixes the critical safety architecture).
4. **Phase 4** (Polish).