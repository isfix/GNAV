package com.example.gnav.core.math

import com.example.gnav.domain.model.Coord
import kotlin.math.min

object DeviationEngine {
    private const val WARNING_THRESHOLD = 50.0
    private const val DANGER_THRESHOLD = 150.0

    enum class SafetyStatus {
        SAFE, WARNING, DANGER
    }

    sealed class DeviationResult {
        object OnTrail : DeviationResult()
        data class OffTrail(val distance: Double, val status: SafetyStatus) : DeviationResult()
    }

    fun calculateDeviation(
        current: Coord,
        path: List<Coord>
    ): DeviationResult {
        if (path.isEmpty()) return DeviationResult.OffTrail(-1.0, SafetyStatus.DANGER)

        var minDistance = Double.MAX_VALUE

        // Find distance to the polyline (segments)
        for (i in 0 until path.size - 1) {
            val p1 = path[i]
            val p2 = path[i + 1]

            val dist = GeoMath.distanceToSegment(
                current.lat, current.lng,
                p1.lat, p1.lng,
                p2.lat, p2.lng
            )
            if (dist < minDistance) {
                minDistance = dist
            }
        }

        return if (minDistance <= WARNING_THRESHOLD) {
            DeviationResult.OnTrail
        } else {
            val status = if (minDistance <= DANGER_THRESHOLD) SafetyStatus.WARNING else SafetyStatus.DANGER
            DeviationResult.OffTrail(minDistance, status)
        }
    }
}
