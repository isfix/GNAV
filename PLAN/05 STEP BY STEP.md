# EXECUTION RUNBOOK: STEP-BY-STEP PROMPTS

**INSTRUCTIONS FOR THE USER:**
1.  Open your AI Editor (Cursor/Windsurf).
2.  Ensure the `ai_docs` folder is in the context.
3.  Copy **PROMPT 1**, paste it into the chat, and wait for the code to generate.
4.  Resolve any errors, then move to **PROMPT 2**, and so on.

---

## PROMPT 1: Project Initialization & Architecture
**Goal:** Setup the skeleton, dependencies, and folder structure.

> "Context: Read `01_project_context.md` and `02_tech_stack.md`.
>
> **Task:** Initialize the Flutter project infrastructure.
>
> 1.  **Dependencies:** Update `pubspec.yaml` with the exact versions of `flutter_riverpod`, `go_router`, `drift`, `sqlite3_flutter_libs`, `flutter_map`, `vector_map_tiles`, `geolocator`, `flutter_background_service`, `permission_handler`, and `geodesy`.
> 2.  **Folder Structure:** Create the exact directory tree defined in `02_tech_stack.md` (Feature-first architecture).
> 3.  **Theme:** Create `lib/core/theme/app_theme.dart`. Define a 'High Contrast Dark Mode' theme (Black background, Neon Green accents) suitable for OLED screens and battery saving.
> 4.  **Routing:** Setup `lib/core/router.dart` using `GoRouter` with a basic Home route.
> 5.  **Main:** Update `main.dart` to initialize `ProviderScope` and the Router.
>
> **Constraint:** Do not write any business logic yet. Just the shell."

---

## PROMPT 2: The Local Database (Drift)
**Goal:** Create the storage layer for Maps, Trails, and Logs.

> "Context: Read `03_database_schema.md`.
>
> **Task:** Implement the Drift Database.
>
> 1.  **Tables:** Create `lib/data/local/db/tables.dart`. Implement the 4 tables: `MountainRegions`, `Trails`, `PointsOfInterest`, and `UserBreadcrumbs`.
> 2.  **Converters:** Implement `GeoJsonConverter` (String <-> List<GeoPoint>) and `PoiTypeConverter` (Int <-> Enum).
> 3.  **Database Class:** Create `lib/data/local/db/app_database.dart`. Annotate it with `@DriftDatabase`.
> 4.  **DAOs:** Create `MountainDao`, `NavigationDao`, and `TrackingDao` with the specific query methods listed in `03_database_schema.md`.
> 5.  **Build:** Run `flutter pub run build_runner build` to generate the boilerplate.
>
> **Constraint:** Ensure `sqlite3_flutter_libs` is configured correctly so it works on Android."

---

## PROMPT 3: Core Logic & Math (The "Brain")
**Goal:** Implement the Deviation Engine and Battery State Machine.

> "Context: Read `04_core_logic_math.md`.
>
> **Task:** Implement the Navigation Logic Layer.
>
> 1.  **Math Utils:** Create `lib/core/utils/geo_math.dart`. Implement `calculateDistanceToSegment(UserPoint, SegmentStart, SegmentEnd)` using the Haversine formula.
> 2.  **Deviation Engine:** Create `lib/features/navigation/logic/deviation_engine.dart`.
>     *   Implement `checkSafetyStatus(userLoc, allTrails)`.
>     *   Implement the hysteresis logic (Safe < 20m < Warning < 50m < Danger).
> 3.  **State Machine:** Create `lib/features/navigation/logic/gps_state_machine.dart`.
>     *   Define the states: `Trekking`, `Stationary`, `Emergency`.
>     *   Create a simple Notifier that accepts Accelerometer events and switches states.
> 4.  **Unit Tests:** Write a test file `test/deviation_logic_test.dart` verifying that a point 60m off-track returns `Status.DANGER`.
>
> **Constraint:** Pure Dart logic only. No UI dependencies here."

---

## PROMPT 4: The Offline Map Engine
**Goal:** Render .mbtiles from local storage.

> "Context: Read `02_tech_stack.md` and `01_project_context.md`.
>
> **Task:** Build the Map UI.
>
> 1.  **Widget:** Create `lib/features/navigation/presentation/offline_map_screen.dart`.
> 2.  **Vector Tiles:** Configure `flutter_map` with the `VectorTileLayer`.
>     *   It must accept a `style` path and a `source` path (the .mbtiles file).
>     *   *Mocking:* Since we don't have a real .mbtiles file yet, create a mock setup that tries to load from `ApplicationDocumentsDirectory`.
> 3.  **Overlays:** Add layers for:
>     *   **Trails:** A `PolylineLayer` consuming data from `NavigationDao`.
>     *   **User:** A `MarkerLayer` showing the current position (Blue Dot) and Heading (Arrow).
> 4.  **HUD:** Overlay a 'Dashboard' at the top showing Altitude and Status (Safe/Warning/Danger).
>
> **Constraint:** Ensure the map background is black if tiles fail to load (don't show white grid)."

---

## PROMPT 5: Background Service & Permissions
**Goal:** Keep the app alive when the screen is off.

> "Context: Read `02_tech_stack.md`.
>
> **Task:** Configure Background Execution.
>
> 1.  **Android Manifest:** Update `android/app/src/main/AndroidManifest.xml` with the required permissions (`FOREGROUND_SERVICE`, `ACCESS_BACKGROUND_LOCATION`, etc.).
> 2.  **Service Init:** Create `lib/core/services/background_service.dart`.
>     *   Implement `initializeService()`.
>     *   Define the `onStart` callback.
> 3.  **Logic Hook:** Inside `onStart`, set up a listener for `Geolocator` updates.
>     *   When a location comes in, save it to `TrackingDao`.
>     *   Run the `DeviationEngine` check.
>     *   If `Status == DANGER`, trigger a Local Notification.
>
> **Constraint:** This is complex. Ensure you handle the 'Isolate' communication correctly (UI and Background Service are separate memory spaces)."

---

## PROMPT 6: Integration & Polish
**Goal:** Connect the UI to the Logic.

> "Context: All previous files.
>
> **Task:** Connect the pieces.
>
> 1.  **Riverpod Providers:** Create `lib/features/navigation/logic/navigation_providers.dart`.
>     *   `currentLocationProvider`: Stream from the Database (or Service).
>     *   `safetyStatusProvider`: Derived from location + trails.
> 2.  **UI Wiring:** Update `OfflineMapScreen`:
>     *   Watch `currentLocationProvider` to update the Blue Dot.
>     *   Watch `safetyStatusProvider` to change the screen border color (Green/Yellow/Red).
> 3.  **Backtrack Button:** Add a Floating Action Button that triggers the 'Draw Breadcrumbs' logic.
>
> **Constraint:** Ensure the UI remains responsive. Heavy calculations should happen in the background."