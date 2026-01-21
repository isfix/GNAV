package com.example.gnav.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class Coord(
    val lat: Double,
    val lng: Double,
    val ele: Double = 0.0
)

data class Trail(
    val id: String,
    val name: String,
    val geometry: List<Coord>
)

data class Mountain(
    val id: String,
    val name: String,
    val description: String,
    val lat: Double,
    val lng: Double,
    val altitude: Double,
    val region: String,
    val tracks: List<Trail> = emptyList()
)
