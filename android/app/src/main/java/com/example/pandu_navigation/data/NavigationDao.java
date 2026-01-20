package com.example.pandu_navigation.data;

import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.Query;
import androidx.room.OnConflictStrategy;
import java.util.List;

@Dao
public interface NavigationDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insertBreadcrumb(BreadcrumbEntity breadcrumb);

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insertTrails(List<TrailEntity> trails);

    // Bounding Box Query: Find trails that physically overlap with a buffer around
    // the user
    // The trail's bounds must intersect the user's buffer.
    // Simplification: Select trails where (trail.minLat <= userLat+buffer) AND
    // (trail.maxLat >= userLat-buffer) ...
    // Actually, prompt asked for "minLat >= :lat - :buffer" etc.
    // The user wants trails STRICTLY RELEVANT.
    // A trail is relevant if its bounding box OVERLAPS the search window.

    @Query("SELECT * FROM trails WHERE " +
            "max_lat >= (:lat - :buffer) AND " +
            "min_lat <= (:lat + :buffer) AND " +
            "max_lng >= (:lng - :buffer) AND " +
            "min_lng <= (:lng + :buffer)")
    List<TrailEntity> getNearbyTrails(double lat, double lng, double buffer);

    @Query("SELECT * FROM trails")
    List<TrailEntity> getAllTrails();

    @Query("DELETE FROM trails")
    void clearTrails();

    @Query("DELETE FROM user_breadcrumbs")
    void clearBreadcrumbs();
}
