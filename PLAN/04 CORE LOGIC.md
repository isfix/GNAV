# CORE LOGIC & ALGORITHMS

## 1. THE DEVIATION ENGINE (The "Safety Tube")
*The core safety feature. It determines if the user has strayed too far from the trail.*

### A. The Math: Cross-Track Error (XTE)
We do not calculate the distance to the *nearest vertex* (point). We calculate the distance to the *nearest line segment*.
*   *Why:* Trails are lines. A user might be safely on the trail but halfway between two recorded GPS points. Point-to-point distance would falsely trigger an alarm.

**Algorithm: Point-to-Segment Distance**
Given User Point $P$ and Trail Segment $AB$:
1.  Project point $P$ onto the line defined by $A$ and $B$.
2.  If the projection falls *between* $A$ and $B$, calculate the perpendicular distance.
3.  If the projection falls *outside*, calculate the distance to the nearest endpoint ($A$ or $B$).

### B. The Logic Flow
**Function:** `calculateSafetyStatus(UserLocation user, List<Trail> trails)`

1.  **Filter:** Select only trails belonging to the current `mountain_id`.
2.  **Iterate:** For every segment of every trail, calculate `distanceToSegment(user, segment)`.
3.  **Find Min:** `minDistance = minimum of all calculated distances`.
4.  **Apply Hysteresis (Debouncing):**
    *   *To prevent flickering between states, we use a buffer.*
    *   **IF** `minDistance` < 20m: Status = **SAFE (Green)**.
    *   **IF** `minDistance` > 20m AND < 50m: Status = **WARNING (Yellow)**.
    *   **IF** `minDistance` > 50m: Status = **DANGER (Red)**.
    *   *Debounce Rule:* Status must persist for 3 consecutive GPS updates before triggering an Audio Alarm (prevents GPS drift false alarms).

---

## 2. THE "HEARTBEAT" STATE MACHINE (Battery Optimization)
*We treat GPS as a scarce resource. The app switches modes based on user activity.*

### State Definitions

| State | Trigger Condition | GPS Behavior | Battery Impact |
| :--- | :--- | :--- | :--- |
| **TREKKING** | Default active state. | Update every **10s** or **10m**. | Moderate |
| **STATIONARY** | Accelerometer detects **0 motion** for > 5 mins. | **PAUSED**. (Wake on accelerometer). | Negligible |
| **EMERGENCY** | Status == DANGER OR User taps "SOS". | Update every **3s** (Max Accuracy). | High |

### Implementation Details
*   Use `flutter_background_service` to host this logic.
*   Use `sensors_plus` to listen to the Accelerometer stream.
    *   *Logic:* Calculate `magnitude = sqrt(x*x + y*y + z*z)`. If `magnitude` variance is < 0.5 for 5 minutes -> Enter STATIONARY.

---

## 3. GEODESY & COORDINATE MATH
*Standard Pythagorean theorem fails at the equator. We must use spherical geometry.*

### Library
Use **`geodesy`** or **`latlong2`** package.

### Required Formulas
1.  **Haversine Formula:** Used for all distance calculations > 10 meters.
2.  **Bearing Calculation:** Used to point the compass arrow back to the trail.
    *   *Formula:* Calculate initial bearing from `UserLocation` to `NearestSafePoint`.
3.  **Projection:** Used to render the "Blue Dot" on the map.
    *   The Map Engine (`flutter_map`) handles the Web Mercator projection (EPSG:3857). Do not manually project coordinates for rendering; pass LatLng directly to the widget.

---

## 4. THE "BACKTRACK" VECTOR
*When the user is lost, we don't just say "Go West." We draw a line.*

**Logic:**
1.  Query `UserBreadcrumbs` table.
2.  Find the last entry where `status == SAFE`. Let's call this **Point S**.
3.  Get current **Point C**.
4.  Draw a **Dotted Polyline** from **C** to **S**.
5.  Calculate Bearing from **C** to **S** and display it on the Compass HUD.

---

## 5. UNIT TEST REQUIREMENTS
*The AI must generate tests for this logic to ensure safety.*

1.  **Test Case 1 (Safe):** User is on the line. Distance should be ~0m. Status: SAFE.
2.  **Test Case 2 (Drift):** User is 30m perpendicular to the line. Status: WARNING.
3.  **Test Case 3 (Lost):** User is 100m away. Status: DANGER.
4.  **Test Case 4 (Curve):** User is inside the "elbow" of a switchback. The logic must correctly identify the nearest segment, not just the nearest point.