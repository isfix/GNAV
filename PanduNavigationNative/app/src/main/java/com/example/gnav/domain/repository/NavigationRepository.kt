package com.example.gnav.domain.repository

import com.example.gnav.data.db.BreadcrumbEntity
import com.example.gnav.data.db.MountainEntity
import com.example.gnav.domain.model.Coord
import com.example.gnav.domain.model.Trail
import kotlinx.coroutines.flow.Flow

interface NavigationRepository {
    suspend fun initializeData()
    fun getMountains(): Flow<List<MountainEntity>>
    suspend fun getTrail(trailId: String): Trail?
    
    suspend fun insertBreadcrumb(lat: Double, lng: Double, accuracy: Float, isOffTrail: Boolean)
    fun observeLastBreadcrumb(): Flow<BreadcrumbEntity?>
}
