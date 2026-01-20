package com.example.pandu_navigation.data;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;
import androidx.room.RawQuery;
import androidx.sqlite.db.SupportSQLiteQuery;

import java.util.List;

@Dao
public interface NavigationDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insertTrail(TrailEntity trail);

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insertBreadcrumb(BreadcrumbEntity breadcrumb);

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insertPoi(PoiEntity poi);

    @Query("SELECT * FROM pois WHERE mountainId = :mountainId")
    List<PoiEntity> getPoisByMountain(String mountainId);

    @Query("SELECT * FROM trails WHERE mountainId = :mountainId")
    List<TrailEntity> getTrailsByMountain(String mountainId);

    @Query("SELECT * FROM trails")
    List<TrailEntity> getAllTrails();

    // Spatial Query: Find trails within a bounding box centered on lat/lng
    @Query("SELECT * FROM trails WHERE minLat <= :lat + :padding AND maxLat >= :lat - :padding AND minLng <= :lng + :padding AND maxLng >= :lng - :padding")
    List<TrailEntity> getNearbyTrails(double lat, double lng, double padding);

    @Query("SELECT COUNT(*) FROM trails")
    int getTrailCount();
}
