package com.example.pandu_navigation.data;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.PrimaryKey;
import androidx.room.ColumnInfo;

@Entity(tableName = "trails")
public class TrailEntity {
    @PrimaryKey
    @NonNull
    public String id;

    @ColumnInfo(name = "mountain_id")
    public String mountainId;

    public String name;

    @ColumnInfo(name = "geometry_json")
    public String geometryJson;

    // Metadata
    public double distance;

    @ColumnInfo(name = "elevation_gain")
    public double elevationGain;

    public int difficulty;

    @ColumnInfo(name = "summit_index")
    public int summitIndex;

    // Spatial Bounding Box
    @ColumnInfo(name = "min_lat")
    public double minLat;
    @ColumnInfo(name = "max_lat")
    public double maxLat;
    @ColumnInfo(name = "min_lng")
    public double minLng;
    @ColumnInfo(name = "max_lng")
    public double maxLng;

    // Nearest Trail Optimization
    @ColumnInfo(name = "start_lat")
    public Double startLat;
    @ColumnInfo(name = "start_lng")
    public Double startLng;

    @ColumnInfo(name = "is_official")
    public boolean isOfficial;
}
