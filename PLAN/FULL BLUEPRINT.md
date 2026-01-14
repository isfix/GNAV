This is a sophisticated pivot. You have moved from a **high-dependency/high-failure model** (continuous internet + sensor dead-reckoning) to a **zero-dependency/high-reliability model** (Native GNSS + Local Vector Data).

This is the correct engineering choice. In survival scenarios, **simplicity is safety.**

Here is the **Neural Architecture Blueprint** for your project, structured for maximum robustness and clarity.

---

# PROJECT CODENAME: "PANDU" (Guidance)
### **Core Objective:** Zero-Dependency Navigation for Indonesian Alpine Environments.

## 1. SYSTEM PHILOSOPHY: The "Black Box" Concept
The app functions as a self-contained "Black Box." Once the user leaves the basecamp, the app assumes **Total Network Failure**.

*   **Old Logic (Deprecated):** Cloud-dependent, sensor extrapolation (Drift-prone, battery-heavy).
*   **New Logic (Active):** Native Hardware GNSS, Local Persistence, Region-Wide Data Availability.

---

## 2. DATA ARCHITECTURE: The "Region-First" Protocol
This is your killer feature. Most apps download a *Route* (Line A to Line B). Your app downloads a *Region* (Polygon).

### **The "Merbabu" Example:**
When a user selects **"Hike Merbabu via Suwanting,"** the system performs a **Tiered Download**:

1.  **Primary Asset (The Route):** High-resolution GPX track for Suwanting.
2.  **Secondary Assets (The Safety Net):**
    *   **All Alternative Tracks:** Selo, Wekas, Thekelan, Cuntel.
    *   **Topography:** DEM (Digital Elevation Model) for the entire mountain block.
    *   **POI Database:** All water sources, shelters (Pos), and emergency extraction points across the *entire* mountain.
3.  **Geofenced Danger Zones:** Pre-mapped coordinates for "Blank Zones" (areas with high drop-off risk or confusing vegetation).

**Why this matters:** If a hiker gets lost on the Suwanting track and drifts West, they might intercept the Wekas track. A standard app would show a blank screen. Your app shows them they have intersected a new valid route.

---

## 3. NAVIGATION ENGINE: "Corridor" vs. "Turn-by-Turn"
Hiking navigation is distinct from urban driving. We do not use "Turn Left." We use **Deviation Logic.**

### **The Algorithm:**
1.  **The Safe Corridor:** The app defines a virtual "tube" around the trail (e.g., 20 meters radius).
2.  **State Detection:**
    *   **Green State:** User is inside the 20m radius.
    *   **Yellow State:** User is 20-50m outside. (UI: Silent visual warning).
    *   **Red State:** User is >50m outside. (UI: Haptic vibration + Audio Alarm).
3.  **Heading Correction:** If in Red State, the app calculates the **Azimuth** (compass bearing) required to return to the *nearest point* of the Safe Corridor, not the destination.

---

## 4. POWER MANAGEMENT: The "Heartbeat" System
To solve the battery drain issue, we treat the GPS hardware like a heartbeat, not a continuous stream.

*   **Active Mode (Moving):** GPS polls every 10–30 seconds.
*   **Static Mode (Resting):** If the device accelerometer detects zero motion for >2 minutes, GPS polling suspends until motion resumes.
*   **Emergency Mode:** If "Red State" (Lost) is triggered, GPS locks to High Accuracy (1-second updates) to ensure precise recovery.

---

## 5. UI/UX: The "Survival HUD"
The interface must be readable in direct sunlight and under extreme stress (panic).

*   **High Contrast Mode:** Black background, Neon Green path (OLED battery saving).
*   **The "Backtrack" Button:** One-tap feature that draws a dotted line to the last known "Green State" coordinate.
*   **Contextual Survival Tips:**
    *   *Not generic:* "Drink water."
    *   *Context-aware:* If Elevation > 2500mdpl AND Time > 17:00 -> "Hypothermia Risk. Put on layers now."
    *   *Terrain-aware:* If approaching a "Danger Zone" polygon -> "Steep Drop-off ahead. Stay left."

---

## 6. TECHNICAL STACK (Recommended)

*   **Framework:** **Flutter** (Google).
    *   *Reason:* Single codebase for Android/iOS, high-performance rendering engine (Skia) for maps.
*   **Map Engine:** **MapLibre GL Native** or **Flutter Map**.
    *   *Reason:* Uses **Vector Tiles** (.mbtiles). This allows you to store the *entire* map of Merbabu in a file size smaller than a few photos (approx 10-20MB).
*   **Database:** **SQLite** (via Drift package).
    *   *Reason:* Robust local storage for tracks and POIs.
*   **Location Service:** **Flutter Background Geolocation** (TransistorSoft).
    *   *Reason:* The industry standard for keeping GPS alive when the phone screen is off (preventing the OS from killing your app).

---

## 7. EXECUTION ROADMAP

### **Phase 1: Data Acquisition (The Hard Part)**
*   Don't draw maps yourself. Scrape **OpenStreetMap (OSM)** data for Indonesian mountains.
*   Filter data: Extract `highway=path`, `natural=peak`, `waterway=stream`.
*   Validate: Use community inputs to flag "Jalur Mati" (Dead/Closed Tracks).

### **Phase 2: The Offline Core**
*   Build the downloader. User selects "Merbabu" -> App downloads `.mbtiles` package.
*   Implement the "Blue Dot" on the offline map.

### **Phase 3: The Safety Logic**
*   Implement the **Deviation Algorithm** (Distance from Line).
*   Add the "Panic Button" (sends SMS with last known coordinates if a faint signal is found).

### **Phase 4: Beta Testing**
*   Test on *one* mountain (e.g., Merbabu or Gede).
*   Simulate "getting lost" to test battery drain and alarm triggers.

This plan moves you from a "Tech Gimmick" to a **"Life-Saving Tool."** It respects the reality of the Indonesian wilderness: no signal, rough terrain, and the need for absolute reliability.
# PART 1: THE FOUNDATION & ARCHITECTURE

## 1. The "Vibe" & Philosophy
This is not a social hiking app like Strava. This is a **Digital Cockpit for Survival**.
*   **Vibe:** Industrial, high-contrast, minimal distractions. Think "Garmin meets Iron Man HUD."
*   **Core Rule:** "If the server burns down, the app still works on the mountain."
*   **The "Full Mountain" Concept:** As you noted, we don't just download the *route*; we download the *region*. If a hiker gets lost, they are likely no longer on the route they planned. They need to know where the *other* escape routes are.

## 2. The Tech Stack (Recommended)
To build this realistically on mobile, you need performance and direct hardware access.

*   **Framework:** **Flutter** (Google).
    *   *Why:* Single codebase for Android/iOS, incredible performance for rendering maps (Skia engine), and best-in-class offline plugins.
*   **Map Engine:** **MapLibre GL Native** (or Mapbox GL).
    *   *Why:* You need **Vector Tiles** (.mbtiles). Raster images (JPEGs) are too big to download for a whole mountain. Vector tiles allow you to style the map (danger zones red, water blue) dynamically and are tiny in file size.
*   **Local Database:** **Drift (SQLite abstraction)** or **Realm**.
    *   *Why:* You need to query spatial data ("Find nearest water source within 5km") instantly without internet. SQLite supports R-Tree indexing for fast spatial queries.
*   **Location Service:** **Geolocator** + **Flutter Background Geolocation** (TransistorSoft).
    *   *Why:* You need a plugin that handles "Doze mode" on Android so the OS doesn't kill your GPS when the screen is off.
*   **State Management:** **Riverpod** or **Bloc**.
    *   *Why:* You need strict logic separation. If the UI crashes, the background GPS service must stay alive.

## 3. The "Full Mountain" Data Schema
This is the most critical part. We need a data structure that handles the "entire mountain" concept.

**The Database Entity: `MountainRegion`**
Instead of downloading a "Track," the user downloads a `MountainRegion`.

```dart
// Conceptual Data Model (Dart/Flutter style)

class MountainRegion {
  final String id; // e.g., "mt_merbabu_central_java"
  final String name; // "Gunung Merbabu"
  final BoundingBox bounds; // The square coordinates covering the whole mountain
  final int version; // For checking updates
  
  // The offline map pack file path
  final String localMapStylePath; 
  final String localVectorTilePath; // .mbtiles file
}

class Waypoint {
  final String id;
  final String type; // "basecamp", "water_source", "danger_cliff", "shelter"
  final double lat;
  final double lng;
  final double elevation;
  final String description; // "Suwanting Basecamp - Water Available"
}

class TrackSegment {
  final String id;
  final String mountainId;
  final String name; // "Via Suwanting", "Via Selo", "Via Wekas"
  final List<GeoPoint> coordinates; // The actual line
  final String difficulty; // "Hard", "Moderate"
  final bool isOfficial; // True = Official, False = "Rat road" (Jalur tikus)
}
```

## 4. The Offline Strategy (The "Download" Flow)

When the user is at home (Online):
1.  **Select Mountain:** User taps "Merbabu".
2.  **The Package:** The server bundles a ZIP file containing:
    *   `merbabu.mbtiles`: The vector map of the *entire* mountain range (contours, rivers, cliffs).
    *   `metadata.json`: A list of *all* tracks (Selo, Suwanting, Wekas, Thekelan), not just one.
    *   `danger_zones.json`: Polygons marking areas to avoid.
3.  **Extraction:** App unzips this into the device's local storage.
4.  **Verification:** App checks MD5 hash to ensure the map isn't corrupted.

**Result:** The user now has a "God Mode" map of Merbabu. Even if they planned to go via Suwanting but end up near Wekas, the map still works.

## 5. The "Danger Zone" Logic
We don't just show a map; we actively classify terrain.

*   **Red Zones (Danger):** Slopes > 45 degrees or known cliff areas.
*   **Blue Zones (Water):** 50m radius around known springs.
*   **Green Zones (Safe):** Designated camp areas.

In the code, we treat these as **Geofences**. Even if the screen is off, if the GPS coordinate enters a "Red Zone," the phone vibrates violently.

***

**End of Part 1.**

**Part 2** will cover the **Navigation Engine**, specifically:
1.  The "Deviation Algorithm" (How to tell if they are lost without draining battery).
2.  The "Smart GPS" Logic (Switching between high accuracy and battery saver).
3.  The "Survival Mode" UI logic.

Here is **Part 2: The Navigation Engine & Survival Logic**.

This is the "brain" of the app. This is where we write the logic that decides if a user is safe or in trouble, while fighting to keep the battery alive.

***

# PART 2: THE NAVIGATION ENGINE & SURVIVAL LOGIC

## 1. The "Heartbeat" (Smart GPS Strategy)
We cannot just leave the GPS running at `High Accuracy` 100% of the time, or the phone will die in 4 hours. We need an **Adaptive State Machine**.

**The Logic:**
We define three states for the GPS engine:

1.  **Trekking Mode (Active):** High accuracy, updates every 10-20 meters.
2.  **Rest Mode (Stationary):** If accelerometer detects 0 movement for 5 minutes, pause GPS.
3.  **Emergency Mode:** Max accuracy, ignore battery cost (user needs precise coordinates).

**Code Concept (Flutter/Dart):**

```dart
enum TrackingState { trekking, resting, emergency }

void configureLocationService(TrackingState state) {
  LocationSettings settings;

  switch (state) {
    case TrackingState.trekking:
      // Standard hiking: Update only when we move 15 meters
      settings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15, 
        forceLocationManager: true, // Uses native GPS hardware
        intervalDuration: Duration(seconds: 5), // Don't update faster than 5s
      );
      break;

    case TrackingState.resting:
      // Battery saver: Check every 5 minutes just to be safe
      settings = AndroidSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 50,
        intervalDuration: Duration(minutes: 5),
      );
      break;
      
    case TrackingState.emergency:
      // SURVIVAL: Give me everything you have
      settings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0, 
        intervalDuration: Duration(seconds: 1),
      );
      break;
  }
  
  Geolocator.getPositionStream(locationSettings: settings).listen((position) {
    _processLocation(position);
  });
}
```

## 2. The Deviation Algorithm (The "Anti-Lost" Math)
This is the core safety feature. We don't use "Turn-by-Turn" (useless in the jungle). We use **Corridor Logic**.

**The Math:**
We treat the trail not as a line, but as a "pipe" with a radius (e.g., 25 meters).

1.  **Snap to Track:** Calculate the nearest point on the downloaded track segments to the user's current GPS point.
2.  **Calculate Distance:** `distance = distanceBetween(userLocation, nearestTrackPoint)`
3.  **Threshold Check:**
    *   **< 25m:** SAFE (Green UI)
    *   **25m - 50m:** WARNING (Yellow UI - "Check your bearing")
    *   **> 50m:** DANGER (Red UI - Vibrate + Sound Alarm)

**Critical Indonesian Context:**
In dense Indonesian jungles (like Latimojong or Bukit Raya), GPS signals bounce (multipath error). The app must **ignore single bad points**.
*   *Rule:* The "Danger" alarm only triggers if **3 consecutive GPS points** are > 50m off-track. This prevents panic from one GPS glitch.

## 3. The "Breadcrumb" System (Local History)
Since we don't have internet to upload data, we save the user's path locally. This is crucial for the **"Backtrack"** feature.

*   **Database Table:** `UserPath`
*   **Columns:** `lat`, `lng`, `timestamp`, `elevation`, `accuracy`.
*   **Trigger:** Save a point every 50 meters.

**Feature: "Take Me Back"**
If the user panics, they hit "I'm Lost." The app draws a dotted line connecting their *current* location back to their *last known safe point* (the last time they were inside the 25m corridor).

## 4. The UI/UX: "Vibe" Coding for Survival
The interface changes based on the user's status.

**A. The "Cockpit" (Normal Mode)**
*   **Background:** Dark Map (OLED Black to save battery).
*   **Center:** Large Arrow (Current Heading).
*   **Top Bar:** Elevation (Critical in mountains) + Distance to Next Post.
*   **Bottom Bar:** "Mark Waypoint" (Big Button).

**B. The "Panic" Interface (Deviation Detected)**
*   **Visual:** The entire screen border pulses Red.
*   **Haptic:** Distinct vibration pattern (SOS pattern: ... --- ...).
*   **Audio:** Voice prompt: *"You are leaving the track. Stop and check orientation."* (Voice is better than reading when panicked).
*   **Action:** A button appears: **"Show Compass to Trail"**. This draws a straight line from User -> Nearest Trail Point.

## 5. The "Calibration" Check
You mentioned "calibrating with latest known location." We automate this.

When the user starts the hike at the Basecamp (e.g., Basecamp Suwanting), the app knows the *exact* coordinates of the Basecamp gate from the database.
*   **Logic:** When the user hits "Start Hike," we compare their GPS to the Basecamp coordinates.
*   **Correction:** If the GPS says they are 200m away but they are standing at the gate, we know the GPS is cold. We force a "Warm Up" state (show a loading spinner) until accuracy drops below 10m.

***

**End of Part 2.**

**Part 3** will cover the **Launch & Distribution Strategy**:
1.  **The "Beta" List:** Which mountains to map first (The "Big 5" of Indonesia).
2.  **Community Data:** How to let users report "Jalur Putus" (Broken tracks) or landslides without internet (sync later).
3.  **Monetization/Sustainability:** How to keep the servers running without ruining the app with ads.

Here is **Part 3: Launch Strategy, Data Sync & Sustainability**.

This is where the code meets the real world. You have a solid tech stack; now you need a plan to deploy it without getting sued or going broke, while actually saving lives in the Indonesian mountains.

***

# PART 3: LAUNCH, DATA OPS & SUSTAINABILITY

## 1. The "Big 5" Beta List (Target Mountains)
Don't try to map all 100+ Indonesian mountains at once. Start with the ones that have the highest traffic and the highest "Lost Hiker" statistics.

**The "MVP" List:**
1.  **Gunung Gede-Pangrango (West Java):**
    *   *Why:* The "Hello World" of Indonesian hiking. Massive traffic, clear trails but confusing junctions (Suryakencana vs Kandang Badak). Good for stress-testing server load.
2.  **Gunung Merbabu (Central Java):**
    *   *Why:* Your specific example. It has 5+ basecamps (Selo, Suwanting, Wekas, Thekelan, Cuntel). Perfect for testing the "Full Mountain" architecture.
3.  **Gunung Rinjani (Lombok):**
    *   *Why:* High international tourist volume. Long duration (3-4 days). Good for testing battery optimization over multi-day treks.
4.  **Gunung Kerinci (Sumatra):**
    *   *Why:* The "Pintu Rimba" (Jungle Gate) area is notorious for people disappearing. Dense vegetation makes GPS signal testing critical.
5.  **Gunung Lawu (Central/East Java):**
    *   *Why:* Famous for "mist" and hypothermia cases. Good for testing "Weather Warning" features (if you add them later).

## 2. The "Sync Later" Community Engine
Users are your best sensors. Trails in Indonesia change fast (landslides, fallen trees, dried-up springs).

**The Problem:** Users see the danger *offline*, but the server is *online*.
**The Solution:** A "Store & Forward" Queue.

**The Workflow:**
1.  **User Action:** Hiker taps a location on the map -> Selects "Report Issue" -> "Landslide/Longsor".
2.  **Local Storage:** App saves this report to a local SQLite table: `pending_reports`.
3.  **Background Job:** When the user returns to the city (WiFi/4G detected), a background worker (`WorkManager` in Android/Flutter) wakes up.
4.  **Upload:** The app silently pushes the JSON payload to your server.

**The Verification Logic (Server-Side):**
*   *Do not* auto-publish reports. One troll can ruin a map.
*   **Rule of 3:** If 3 distinct users report "Water Source Dry" at Pos 2, the system automatically flags it as "Unverified Warning" on the global map.
*   **Admin Override:** You (or trusted "Rangers") can manually confirm reports to turn them into "Verified Danger Zones."

## 3. Monetization & Sustainability (Don't Be Evil)
You cannot put pop-up ads in a survival app. If a user is panicking and an ad for "Shopee" pops up, you have failed.

**The Business Model: "Digital Insurance" (Freemium)**

*   **Free Tier (Safety is a Human Right):**
    *   Online Map Viewing.
    *   GPS Positioning.
    *   Compass.
    *   *Reason:* You want everyone to have the basic safety tools.

*   **Pro Tier (The "Serious Hiker" Subscription - e.g., Rp 25.000/month or Rp 200.000/year):**
    *   **Unlimited Offline Downloads:** Download 10 mountains at once.
    *   **3D Terrain View:** Visualize the steepness before hiking.
    *   **Family Safety Link:** Auto-send an SMS with coordinates to a registered contact if the user doesn't "Check In" by a certain time (requires signal eventually, but automates the panic).
    *   **GPX Export/Import:** For power users who want to analyze their data.

## 4. Legal & Liability (The "Cover Your Ass" Section)
This is critical. You are providing navigation advice. If someone gets lost using your app, they might blame you.

**The "Ironclad" Disclaimer (Onboarding Screen):**
> "This app is a navigational **aid**, not a replacement for experience, guides, or physical maps. GPS signals in Indonesian mountains can be unreliable due to dense canopy and weather. The developer accepts **no liability** for accidents, injuries, or lost hikers. **By clicking 'I Agree', you accept full responsibility for your own safety.**"

**User Acceptance:**
*   Make them scroll to the bottom.
*   Make them type "SAYA PAHAM" (I Understand) to proceed. This proves they didn't just blindly tap "Next."

## 5. The "Vibe" Marketing Plan
How do you get this on phones?

1.  **The "Mapala" Strategy:** Reach out to University Nature Lover groups (Mapala UI, Wanadri, etc.). Give them free Pro codes. They are the influencers of the mountain. If they use it, everyone else will.
2.  **Basecamp QR Codes:** Print waterproof stickers with "Download Offline Map for Merbabu" and a QR code. Stick them at the Basecamp registration desk. Hikers *will* download it while they still have signal at the gate.
3.  **The "Survivor" Narrative:** Market the app not as "fun," but as "essential gear."
    *   *Slogan:* "Don't be a statistic. Come home safe."

***

# FINAL EXECUTION CHECKLIST

1.  **Setup Flutter Project:** Initialize with `flutter_map` or `maplibre_gl`.
2.  **Acquire Data:** Scrape OpenStreetMap (OSM) data for Merbabu as a test case. Convert to `.mbtiles`.
3.  **Build the "Deviation Engine":** Write the Dart logic to check `distanceTo(trail) > 50m`.
4.  **Battery Test:** Run the app on a cheap Android phone, put it in a backpack, and hike a local hill. If battery drops >10% per hour, optimize the GPS interval.
5.  **Beta Launch:** Release "Gunung Merbabu Offline" as a standalone test on Play Store.

