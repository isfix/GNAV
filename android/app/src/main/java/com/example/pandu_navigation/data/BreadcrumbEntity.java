package com.example.pandu_navigation.data;

import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "breadcrumbs")
public class BreadcrumbEntity {
    @PrimaryKey(autoGenerate = true)
    public long id;

    public double lat;
    public double lng;
    public double altitude;
    public double accuracy;
    public double bearing;
    public double speed;
    public long timestamp;
    public int isSynced; // 0 = false, 1 = true (for syncing back to Flutter/Cloud if needed)

    public BreadcrumbEntity(double lat, double lng, double altitude, double accuracy, double bearing, double speed,
            long timestamp) {
        this.lat = lat;
        this.lng = lng;
        this.altitude = altitude;
        this.accuracy = accuracy;
        this.bearing = bearing;
        this.speed = speed;
        this.timestamp = timestamp;
        this.isSynced = 0;
    }
}
