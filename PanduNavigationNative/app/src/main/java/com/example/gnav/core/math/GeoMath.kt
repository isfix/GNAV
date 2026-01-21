package com.example.gnav.core.math

import kotlin.math.*

object GeoMath {
    private const val EARTH_RADIUS = 6371000.0 // meters

    /**
     * Calculates distance between two points in meters using Haversine formula.
     */
    fun distanceMeters(lat1: Double, lng1: Double, lat2: Double, lng2: Double): Double {
        val dLat = Math.toRadians(lat2 - lat1)
        val dLng = Math.toRadians(lng2 - lng1)
        val a = sin(dLat / 2) * sin(dLat / 2) +
                cos(Math.toRadians(lat1)) * cos(Math.toRadians(lat2)) *
                sin(dLng / 2) * sin(dLng / 2)
        val c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return EARTH_RADIUS * c
    }

    /**
     * Calculates the shortest distance from a point (pLat, pLng) to a line segment
     * defined by (startLat, startLng) and (endLat, endLng).
     */
    fun distanceToSegment(
        pLat: Double, pLng: Double,
        startLat: Double, startLng: Double,
        endLat: Double, endLng: Double
    ): Double {
        val x = pLng
        val y = pLat
        val x1 = startLng
        val y1 = startLat
        val x2 = endLng
        val y2 = endLat

        val A = x - x1
        val B = y - y1
        val C = x2 - x1
        val D = y2 - y1

        val dot = A * C + B * D
        val lenSq = C * C + D * D

        var param = -1.0
        if (lenSq != 0.0) {
            param = dot / lenSq
        }

        val xx: Double
        val yy: Double

        if (param < 0) {
            xx = x1
            yy = y1
        } else if (param > 1) {
            xx = x2
            yy = y2
        } else {
            xx = x1 + param * C
            yy = y1 + param * D
        }

        return distanceMeters(y, x, yy, xx)
    }
}
