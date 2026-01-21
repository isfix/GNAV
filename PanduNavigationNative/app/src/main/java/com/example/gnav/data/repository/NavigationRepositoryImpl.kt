package com.example.gnav.data.repository

import com.example.gnav.data.db.BreadcrumbEntity
import com.example.gnav.data.db.MountainEntity
import com.example.gnav.data.db.NavigationDao
import com.example.gnav.data.db.TrailEntity
import com.example.gnav.data.source.AssetDataSource
import com.example.gnav.domain.model.Trail
import com.example.gnav.domain.repository.NavigationRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import java.util.UUID
import javax.inject.Inject

class NavigationRepositoryImpl @Inject constructor(
    private val dao: NavigationDao,
    private val assetDataSource: AssetDataSource
) : NavigationRepository {

    override suspend fun initializeData() = withContext(Dispatchers.IO) {
        if (dao.getMountainCount() == 0) {
            val config = assetDataSource.loadMountainsConfig()
            val mountainEntities = mutableListOf<MountainEntity>()
            val trailEntities = mutableListOf<TrailEntity>()

            for (mDto in config.mountains) {
                mountainEntities.add(
                    MountainEntity(
                        id = mDto.id,
                        name = mDto.name,
                        description = mDto.description,
                        region = mDto.region,
                        lat = mDto.lat,
                        lng = mDto.lng,
                        altitude = mDto.altitude
                    )
                )

                for (trackDto in mDto.tracks) {
                    val coords = assetDataSource.parseGpx(trackDto.file)
                    // Create a deterministic ID or use filename
                    val trailId = "${mDto.id}_${trackDto.name.filter { it.isLetterOrDigit() }}"
                    trailEntities.add(
                        TrailEntity(
                            id = trailId,
                            mountainId = mDto.id,
                            name = trackDto.name,
                            geometry = coords
                        )
                    )
                }
            }
            dao.insertMountains(mountainEntities)
            dao.insertTrails(trailEntities)
        }
    }

    override fun getMountains(): Flow<List<MountainEntity>> = dao.getMountains()

    override suspend fun getTrail(trailId: String): Trail? {
        val entity = dao.getTrail(trailId) ?: return null
        return Trail(
            id = entity.id,
            name = entity.name,
            geometry = entity.geometry
        )
    }

    override suspend fun insertBreadcrumb(lat: Double, lng: Double, accuracy: Float, isOffTrail: Boolean) {
        val entity = BreadcrumbEntity(
            timestamp = System.currentTimeMillis(),
            lat = lat,
            lng = lng,
            accuracy = accuracy,
            sessionId = "current_session", // Logic for sessions can generally be expanded
            isOffTrail = isOffTrail
        )
        dao.insertBreadcrumb(entity)
    }

    override fun observeLastBreadcrumb(): Flow<BreadcrumbEntity?> = dao.getLastBreadcrumb()
}
