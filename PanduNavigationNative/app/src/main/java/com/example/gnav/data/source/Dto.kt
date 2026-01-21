package com.example.gnav.data.source

import kotlinx.serialization.Serializable

@Serializable
data class MountainDto(
    val id: String,
    val name: String,
    val description: String,
    val region: String,
    val lat: Double,
    val lng: Double,
    val altitude: Double,
    val tracks: List<TrackDto>
)

@Serializable
data class TrackDto(
    val file: String,
    val name: String
)

@Serializable
data class MountainsConfigDto(
    val mountains: List<MountainDto>
)
