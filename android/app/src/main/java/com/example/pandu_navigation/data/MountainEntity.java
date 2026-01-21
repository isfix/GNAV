package com.example.pandu_navigation.data;

import androidx.annotation.NonNull;
import androidx.room.ColumnInfo;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "mountain_regions")
public class MountainEntity {
    @PrimaryKey
    @NonNull
    public String id;

    public String name;
    public String description;
    public String region;

    @ColumnInfo(name = "lat")
    public double lat;

    @ColumnInfo(name = "lng")
    public double lng;

    @ColumnInfo(name = "altitude")
    public double altitude;

    @ColumnInfo(name = "is_downloaded")
    public boolean isDownloaded;

    @ColumnInfo(name = "is_offline_available")
    public boolean isOfflineAvailable;

    @ColumnInfo(name = "local_map_path")
    public String localMapPath;

    @ColumnInfo(name = "boundary_json")
    public String boundaryJson;

    public MountainEntity(@NonNull String id, String name, String description, String region, double lat, double lng,
            double altitude, boolean isDownloaded, boolean isOfflineAvailable, String localMapPath,
            String boundaryJson) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.region = region;
        this.lat = lat;
        this.lng = lng;
        this.altitude = altitude;
        this.isDownloaded = isDownloaded;
        this.isOfflineAvailable = isOfflineAvailable;
        this.localMapPath = localMapPath;
        this.boundaryJson = boundaryJson;
    }
}
