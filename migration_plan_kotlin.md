# Master Migration Plan: GNAV to Pure Kotlin

This is the execution roadmap to transform GNAV from a Hybrid Flutter app into a High-Performance Native Android app.

**Strategy:** "Strangler Fig" approach inside the `android` folder, eventually deleting the Flutter shell.

## 📅 Phases Overview
1.  **Phase 1: Foundation (The Setup)** - Configure Gradle, Dependencies, and Project Structure.
2.  **Phase 2: The Core Transplant** - Move Assets and Math Logic.
3.  **Phase 3: Data Layer Rebuild** - Port Database and Repositories.
4.  **Phase 4: Service Hardening** - Finalize the Background Service.
5.  **Phase 5: UI Rewrite (Jetpack Compose)** - Rebuild Screens.
6.  **Phase 6: Cleanup** - Delete Flutter.

---

## 📋 Phase 1: Foundation (Estimated Time: 2 Hours)
**Goal:** A compilable Kotlin Android project with modern architecture support.

- [ ] **Create New Project** (Recommended over modifying existing `android` folder to avoid Flutter build script pollution).
    - Name: `PanduNavigationNative`
    - Min SDK: 24, Target SDK: 34.
- [ ] **Gradle Dependencies (`build.gradle.kts`)**:
    - **Hilt**: `com.google.dagger:hilt-android`
    - **Room**: `androidx.room:room-ktx`
    - **Compose**: `androidx.compose.ui:ui`
    - **Coroutines**: `kotlinx-coroutines-android`
    - **MapLibre**: `org.maplibre.gl:android-sdk`
    - **Serialization**: `kotlinx-serialization-json`
- [ ] **Manifest Setup**:
    - Copy permissions (`ACCESS_FINE_LOCATION`, `FOREGROUND_SERVICE`, etc.) from old `AndroidManifest.xml`.

## 📦 Phase 2: The Core Transplant (Estimated Time: 3 Hours)
**Goal:** Verify raw assets and pure logic work in the new environment.

- [ ] **Asset Migration**:
    - Copy `assets/config/mountains.json` -> `app/src/main/assets/config/`
    - Copy `assets/tracks/*.gpx` -> `app/src/main/assets/tracks/`
    - Copy `assets/icons/` -> `app/src/main/res/drawable/` (Convert PNGs to XML Vectors if possible, or keep as Drawable resources).
- [ ] **Logic Porting**:
    - Copy `GeoMath.java` -> Convert to `GeoMath.kt` (Ctrl+Alt+Shift+K in IntelliJ).
    - Copy `KalmanFilter.java` -> Convert to `KalmanFilter.kt`.
    - Copy `DeviationEngine.java` -> Convert to `DeviationEngine.kt`.
    - **Verify:** Write a simple JUnit test for `GeoMath.distanceMeters()` to confirm it works.

## 💾 Phase 3: Data Layer Rebuild (Estimated Time: 4 Hours)
**Goal:** A working Room database seeded with your JSON/GPX data.

- [ ] **Entities**:
    - Copy `MountainEntity.java` -> `MountainEntity.kt` (Use `@Entity`).
    - Copy `TrailEntity.java` -> `TrailEntity.kt`.
- [ ] **DAO**:
    - Create `NavigationDao.kt` (Suspend functions).
- [ ] **Repository**:
    - Create `NavigationRepository` class backed by Hilt.
    - Implement `getMountains()` and `getTrail(id)`.
- [ ] **Seeding Logic**:
    - Port `AssetConfigLoader.java` to `AssetDataSource.kt`.
    - Use `Kotlin Serialization` to parse the JSON (Replace Gson).
    - **Milestone:** App launches and logs "Database Seeded with X Mountains".

## 📡 Phase 4: Service Hardening (Estimated Time: 5 Hours)
**Goal:** The "Unkillable" Service running without a Flutter Bridge.

- [ ] **Service Migration**:
    - Copy `PanduService.java` -> `TrackingService.kt`.
    - Remove all `MethodChannel` and `EventChannel` code.
    - Inject `NavigationRepository` using `@AndroidEntryPoint`.
- [ ] **Flow Integration**:
    - Instead of broadcasting Intents, update a `MutableStateFlow<NavigationState>` in the Repository/Service.
    - Implement the "Heartbeat" loop (GPS -> Math -> DB Write).

## 🎨 Phase 5: UI Rewrite with Compose (Estimated Time: 10 Hours)
**Goal:** Recreate the visual experience.

- [ ] **Theme Setup**:
    - Create `StitchTheme.kt` (Define your Neon Green/Dark Grey palette).
- [ ] **Home Screen**:
    - Create `MountainCard` composable.
    - `LazyColumn` to list mountains from `HomeViewModel`.
- [ ] **Map Screen**:
    - Use `AndroidView` to host `MapView` (MapLibre XML view).
    - Overlay Compose UI (`CockpitHud`, `Compass`) on top.
    - **State**: Observe `NavigationViewModel.uiState` to update the HUD markers.

## 🧹 Phase 6: Final Cleanup
**Goal:** Ship it.

- [ ] **release Build**: Configure ProGuard/R8.
- [ ] **Uninstall Flutter**: You no longer need the Flutter SDK or Dart plugins.

## 💡 Pro Tips for Success
1.  **Don't "Fix" Logic**: The math (`DeviationEngine`) works. Don't rewrite the algorithms, just the syntax.
2.  **Use Hilt Early**: Set up Dependency Injection on Day 1. It saves massive headaches later.
3.  **Test the Map First**: MapLibre integration in Native is slightly different than Flutter. Get a map rendering on screen before adding complex overlays.
