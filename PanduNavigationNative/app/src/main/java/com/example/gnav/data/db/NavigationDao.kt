package com.example.gnav.data.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface NavigationDao {
    // Seeding
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMountains(mountains: List<MountainEntity>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTrails(trails: List<TrailEntity>)

    @Query("SELECT COUNT(*) FROM mountains")
    suspend fun getMountainCount(): Int

    // Queries
    @Query("SELECT * FROM mountains")
    fun getMountains(): Flow<List<MountainEntity>>

    @Query("SELECT * FROM trails WHERE mountainId = :mountainId")
    suspend fun getTrailsByMountain(mountainId: String): List<TrailEntity>

    @Query("SELECT * FROM trails WHERE id = :trailId LIMIT 1")
    suspend fun getTrail(trailId: String): TrailEntity?

    // Tracking
    @Insert
    suspend fun insertBreadcrumb(breadcrumb: BreadcrumbEntity)

    @Query("SELECT * FROM breadcrumbs ORDER BY timestamp DESC LIMIT 1")
    fun getLastBreadcrumb(): Flow<BreadcrumbEntity?>
}
