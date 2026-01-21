# GNAV Reborn: Pure Kotlin Architecture Specification

This is the definitive blueprint for rebuilding Pandu Navigation (GNAV) from zero, using 100% Modern Android technologies.

## 🏗️ Architectural Pattern
**MVVM (Model-View-ViewModel) + Clean Architecture**
- **UI Layer (Presentation):** Jetpack Compose + ViewModels.
- **Domain Layer (Business Logic):** Use Cases (Interactors) + Domain Models.
- **Data Layer (Repository):** Room Database + Data Sources + File I/O.

## 🛠️ Technology Stack
| Component | Technology | Reasoning |
| :--- | :--- | :--- |
| **Language** | **Kotlin** | Modern, null-safe, coroutine support. |
| **UI Toolkit** | **Jetpack Compose** | Declarative UI (like Flutter), reduced boilerplate. |
| **Asynchonous** | **Coroutines & Flow** | Native structured concurrency. Replaces RxJava/Streams. |
| **Dependency Injection** | **Hilt (Dagger)** | Standard Android DI for testing and decoupling. |
| **Database** | **Room** | Robust SQLite abstraction with Coroutines support. |
| **Maps** | **MapLibre Native Android SDK** | High performance vector maps (C++ backed). |
| **Background** | **Foreground Service** | "Unkillable" tracking with persistent notification. |
| **Serialization** | **Kotlin Serialization** | Faster and more type-safe than Gson. |

## 📐 System Diagram

```mermaid
graph TD
    subgraph "UI Layer (Jetpack Compose)"
        Screen[MapScreen.kt]
        Comp[CompassWidget.kt]
        VM[NavigationViewModel]
    end

    subgraph "Domain Layer"
        UC_Loc[GetLocationUseCase]
        UC_Dev[CalculateDeviationUseCase]
        Model[Trail & userLocation]
    end

    subgraph "Data Layer"
        Repo[NavigationRepository]
        Room[(AppDatabase)]
        Assets[AssetManager (JSON/GPX)]
        Service[TrackingService]
    end

    %% Data Flow
    Screen <-->|StateFlow| VM
    VM -->|Collect| UC_Loc
    UC_Loc -->|Flow| Repo
    Repo <-->|DAO| Room
    Repo <-->|Events| Service
    Service -->|GPS Updates| Repo

    %% Styling
    style Screen fill:#e0f7fa,stroke:#006064
    style VM fill:#b2ebf2,stroke:#006064
    style Service fill:#ffecb3,stroke:#ff6f00
    style Room fill:#dcedc8,stroke:#33691e
```

## 📂 Project Structure (Feature-First)

```text
com.example.gnav
├── core/
│   ├── di/              # Hilt Modules (DatabaseModule, LocationModule)
│   ├── math/            # GeoMath.kt, KalmanFilter.kt
│   └── util/            # Extensions, Permissions
├── data/
│   ├── db/              # Room (Entities, DAOs, AppDatabase)
│   ├── repository/      # Repository Implementations
│   └── source/          # AssetDataSource (JSON Parser)
├── domain/
│   ├── model/           # Pure Kotlin Data Classes (Trail, Mountain)
│   ├── repository/      # Repository Interfaces
│   └── usecase/         # TrackDeviationUseCase, GetNearbyTrailsUseCase
├── presentation/
│   ├── theme/           # StitchTheme (Color, Type, Shape)
│   ├── home/            # HomeScreen.kt, HomeViewModel.kt
│   ├── map/             # MapScreen.kt, MapViewModel.kt
│   └── components/      # Reusable Compoments (StitchCard, Compass)
└── service/
    └── TrackingService.kt  # The Heart: Foreground Service
```

## 🧠 The "Hard Parts" Solved

### 1. The Unkillable Service (`TrackingService.kt`)
This is a `Service` class, not a generic Java class.
- **Lifecycle:** Started via `startForeground()` with a persistent notification.
- **Responsibilities:**
    - Request Location Updates (`FusedLocationProvider`).
    - Run `KalmanFilter` on incoming points.
    - Run `DeviationEngine` against the loaded trail.
    - Write `BreadcrumbEntity` to Room via `NavigationRepository`.
    - Emit `Flow<NavigationState>` that the UI observes.

### 2. State Management (`NavigationViewModel.kt`)
No bridges. The ViewModel observes the Repository directly.
```kotlin
@HiltViewModel
class NavigationViewModel @Inject constructor(
    private val repository: NavigationRepository
) : ViewModel() {
    
    // The UI consumes this single stream of truth
    val uiState: StateFlow<NavUiState> = repository.observeNavigationState()
        .map { state -> state.toUiModel() }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), NavUiState.Loading)
}
```

### 3. The Database (`Room`)
Direct access. No path mapping issues.
```kotlin
@Database(entities = [MountainEntity::class, TrailEntity::class], version = 1)
abstract class AppDatabase : RoomDatabase() {
    abstract fun navigationDao(): NavigationDao
}
```

### 4. Seamless Data Loading
`AssetDataSource` reads `mountains.json` using **Kotlin Serialization** and inserts into Room on first launch using `Room.withTransaction`. This happens in a Coroutine (`Dispatchers.IO`), keeping the UI silky smooth.

## 🚀 Why This Rocks
- **No MethodChannels:** Passing data is just a function call.
- **Type Safety:** You can't accidentally send a String where a Double is expected (unlike JSON over Bridge).
- **Instant Debugging:** Breakpoints work everywhere. You don't step into a black hole when crossing languages.
- **Battery Life:** Native background processing is more efficient than spinning up a Flutter Engine for background tasks.
