package com.example.gnav.data.db

import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.TypeConverter
import com.example.gnav.domain.model.Coord
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

@Entity(tableName = "mountains")
data class MountainEntity(
    @PrimaryKey val id: String,
    val name: String,
    val description: String,
    val region: String,
    val lat: Double,
    val lng: Double,
    val altitude: Double,
    val isOfflineAvailable: Boolean = false
)

@Entity(tableName = "trails")
data class TrailEntity(
    @PrimaryKey val id: String,
    val mountainId: String,
    val name: String,
    val geometry: List<Coord> // Requires TypeConverter
)

@Entity(tableName = "breadcrumbs")
data class BreadcrumbEntity(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val timestamp: Long,
    val lat: Double,
    val lng: Double,
    val accuracy: Float,
    val sessionId: String, // For grouping sessions
    val isOffTrail: Boolean
)

class Converters {
    @TypeConverter
    fun fromCoordList(value: List<Coord>?): String {
        return if (value == null) "[]" else Json.encodeToString(value)
    }

    @TypeConverter
    fun toCoordList(value: String?): List<Coord> {
        return if (value.isNullOrEmpty()) emptyList() else Json.decodeFromString(value)
    }
}
