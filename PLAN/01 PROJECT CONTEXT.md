# PROJECT CONTEXT: PANDU (Offline Navigation & Survival System)

## 1. PROJECT MISSION & PHILOSOPHY
**"Pandu" is not a fitness tracker. It is a survival instrument.**

The core problem in Indonesian hiking is not a lack of trails, but a lack of **situational awareness** when things go wrong. Existing apps rely on internet connectivity or assume the user stays on the path. Pandu assumes the worst-case scenario: **Total Network Failure + Disorientation.**

### The "Black Box" Doctrine
Once the user passes the "Pintu Rimba" (Jungle Gate), the app operates as a self-contained Black Box.
1.  **Zero Trust in Network:** The app functions 100% identical in Airplane Mode as it does with 5G.
2.  **Zero Trust in User Orientation:** We assume the user is tired, panicked, or hypothermic. The UI must be readable by a exhausted brain.
3.  **Battery is Life:** Every line of code must justify its energy consumption. Visuals are dark (OLED friendly), and sensors sleep when not needed.

---

## 2. THE "FULL MOUNTAIN" DATA STRATEGY (Unique Selling Point)
Standard navigation apps download a **Route** (Line A to Line B).
**Pandu downloads a Region (Polygon).**

### Why this matters:
When a hiker gets lost in places like *Gunung Merbabu* or *Bukit Raya*, they rarely stay near their intended route. They drift into drainages or follow "Jalur Tikus" (animal trails).
*   **Traditional App:** Shows a blank grey grid because the user is 500m off the downloaded route.
*   **Pandu:** Shows the user that they have drifted West, but if they continue North for 200m, they will intersect the *Wekas* trail (an alternative route they didn't plan to take, but is now their lifeline).

**The Data Package includes:**
*   **Topography:** Full DEM (Digital Elevation Model) for the mountain block.
*   **All Trails:** Primary, Secondary, and known "Dead/Closed" trails (marked as danger).
*   **POI Network:** Every known water source, shelter (Pos), and Ranger Post within the mountain's boundary.

---

## 3. CORE MECHANICS

### A. The Deviation Engine (The "Corridor")
We do not use "Turn-by-Turn" navigation. We use **Corridor Logic**.
*   **Concept:** The trail is a "Safe Tube" with a 25-meter radius.
*   **Green State:** User is inside the tube. UI is silent.
*   **Yellow State (Warning):** User is 25m-50m outside. UI shows a visual prompt: *"Check Bearing."*
*   **Red State (Critical):** User is >50m outside.
    *   **Action:** Haptic SOS vibration.
    *   **UI:** High-contrast "STOP" warning.
    *   **Guidance:** An arrow points to the *nearest safe trail point*, not the destination.

### B. The "Heartbeat" GPS System (Battery Logic)
Continuous GPS drains battery in <6 hours. We use an **Adaptive State Machine**:
1.  **Trekking Mode:** Accelerometer detects motion -> GPS polls every 10-20 seconds.
2.  **Static Mode:** Accelerometer detects 0 motion for >2 minutes -> GPS Hardware SLEEPS.
3.  **Emergency Mode:** User triggers "SOS" or enters "Red State" -> GPS locks to High Accuracy (1-second updates).

### C. The "Backtrack" Breadcrumbs
Since we cannot upload data to the cloud, we store a local history of the user's path.
*   **Function:** If a user gets disoriented, they hit **"Take Me Back."**
*   **Result:** The app draws a dotted line connecting their current position back to the last recorded "Green State" coordinate.

---

## 4. TARGET ENVIRONMENT & CONSTRAINTS

### Physical Environment
*   **Dense Canopy:** Indonesian rainforests block GPS signals. The app must handle "Multipath Errors" (GPS jumping around) by filtering out low-accuracy points.
*   **Wet/Rain:** Touchscreens fail in rain. Critical actions (like "I'm Lost") must be accessible via large buttons or physical volume key mapping (if possible).

### The User
*   **Mental State:** Likely panicked. Complex maps with tiny text are useless.
*   **Gear:** Mid-range Android phones (Samsung A-series, Xiaomi, Oppo) with 4000-5000mAh batteries. Performance optimization is mandatory.

---

## 5. SUCCESS METRICS
1.  **Availability:** The map loads in <2 seconds from cold start without internet.
2.  **Endurance:** The app consumes <5% battery per hour during active tracking.
3.  **Clarity:** A user can understand their position relative to the trail within 3 seconds of looking at the screen.