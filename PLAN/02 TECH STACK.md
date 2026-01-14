Here is the robust, expanded version of **File 2 (`02_tech_stack.md`)**.

This file gives the AI strict boundaries on *how* to build the app, ensuring it uses high-performance, offline-capable libraries instead of random defaults.

Copy the content below and save it exactly as `ai_docs/02_tech_stack.md`.

***

```markdown
# TECH STACK & ARCHITECTURE SPECIFICATIONS

## 1. CORE FRAMEWORK
*   **Framework:** Flutter (Latest Stable Channel).
*   **Language:** Dart (Latest Stable).
*   **Platform Priority:** Android (Primary - dominant in ID market), iOS (Secondary).
*   **Min SDK:** Android 21 (Lollipop) / iOS 13.

## 2. CRITICAL DEPENDENCIES (pubspec.yaml)
*Do not use Google Maps SDK. It requires internet for tile loading and caching is unreliable for whole regions. We use OpenStreetMap via Vector Tiles.*

### A. State Management & Routing
*   **`flutter_riverpod`** & **`riverpod_annotation`**: For reactive state management and dependency injection.
*   **`freezed_annotation`** & **`json_annotation`**: For immutable data classes (essential for robust logic).
*   **`go_router`**: For type-safe navigation.

### B. The Map Engine (The Heart)
*   **`flutter_map`**: The core map renderer.
*   **`vector_map_tiles`**: **CRITICAL.** Enables rendering `.mbtiles` (offline vector packages) directly from local storage.
*   **`latlong2`**: For coordinate geometry.

### C. Local Persistence (The Brain)
*   **`drift`**: Reactive, type-safe SQLite database.
*   **`sqlite3_flutter_libs`**: Bundles native SQLite binaries to ensure consistency across fragmented Android devices.
*   **`path_provider`**: To access the file system for storing heavy map packs.

### D. Sensors & Location (The Senses)
*   **`geolocator`**: For standard foreground location updates.
*   **`flutter_background_service`**: **CRITICAL.** Allows us to spawn a separate Dart Isolate that keeps running when the app is killed/backgrounded. This is where the "Heartbeat" logic lives.
*   **`sensors_plus`**: Access to Accelerometer (for the "Stationary Mode" battery saver).
*   **`flutter_local_notifications`**: To alert the user of "Red State" deviation even if the phone is in their pocket.

### E. Utilities
*   **`geodesy`**: For high-precision Haversine distance calculations (calculating distance from trail segments).
*   **`permission_handler`**: To handle the complex Android 12+ background location permissions.
*   **`archive`**: To unzip the "Region Packages" (Map + JSONs) downloaded from the server.

---

## 3. ARCHITECTURAL PATTERN
We follow a **Feature-First, Riverpod-Clean Architecture**.

### Folder Structure
```text
lib/
├── main.dart                  # Entry point, ProviderScope, Background Service Init
├── core/                      # Shared Logic
│   ├── theme/                 # High Contrast Dark Mode
│   ├── constants/             # App-wide configs (e.g., Deviation Thresholds)
│   ├── utils/                 # Math helpers, Date formatters
│   └── errors/                # Failure classes
├── data/                      # Data Layer (The "Truth")
│   ├── local/
│   │   ├── db/                # Drift Database definition
│   │   ├── daos/              # Data Access Objects
│   │   └── file_manager.dart  # Handling .mbtiles storage
│   └── models/                # DTOs (Data Transfer Objects)
├── features/
│   ├── navigation/            # THE MAP UI
│   │   ├── presentation/      # MapScreen, DeviationAlertWidget
│   │   ├── logic/             # DeviationEngine (The Math), LocationNotifier
│   │   └── domain/            # Entities (SafeCorridor, UserPosition)
│   ├── region_manager/        # DOWNLOADING & MANAGING MAPS
│   │   ├── presentation/      # RegionListScreen (Download Merbabu, Rinjani...)
│   │   └── logic/             # DownloadManager (Unzip, verify hash)
│   └── tracking/              # HISTORY
│       └── logic/             # BreadcrumbRecorder
```

---

## 4. DATA FLOW RULES
1.  **Unidirectional Data Flow:**
    *   Sensors -> Background Service -> Drift Database -> StreamProvider -> UI.
2.  **The "Isolate" Rule:**
    *   The **Deviation Engine** (Math) runs in the Background Isolate. It writes status changes (Safe/Danger) to the Database.
    *   The **UI** simply listens to the Database stream. This ensures that if the UI crashes, the safety logic keeps running.
3.  **Offline First:**
    *   The app *never* tries to fetch tiles from the internet during navigation. It *only* reads from the local `.mbtiles` file.

---

## 5. REQUIRED ANDROID PERMISSIONS
*The AI must generate the `AndroidManifest.xml` with these specific tags to prevent the OS from killing the app.*

*   `ACCESS_FINE_LOCATION`
*   `ACCESS_COARSE_LOCATION`
*   `ACCESS_BACKGROUND_LOCATION` (Critical for Android 10+)
*   `FOREGROUND_SERVICE`
*   `FOREGROUND_SERVICE_LOCATION` (Android 14 requirement)
*   `WAKE_LOCK` (To keep CPU awake during "Red State" calculation)
```