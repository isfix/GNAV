package com.example.pandu_navigation.data;

import androidx.room.Entity;
import androidx.room.PrimaryKey;
import androidx.annotation.NonNull;

@Entity(tableName = "trails")
public class TrailEntity {
    @PrimaryKey
    @NonNull
    public String id;

    public String mountainId;
    public String name;

    // Geometry stored as JSON string or Blob.
    // For Native Logic, we might want raw bytes or stick to JSON if compatible with
    // the Dart logic.
    // The plan says "Mirror the Trails table".
    // Dart uses JSON. Let's store JSON for now to allow simple passing to Flutter.
    public String geometryJson;

    public int difficulty;
    public double distance;
    public double elevationGain;

    // Spatial Bounds for efficient querying
    public double minLat;
    public double maxLat;
    public double minLng;
    public double maxLng;

    public TrailEntity(@NonNull String id, String mountainId, String name, String geometryJson,
            int difficulty, double distance, double elevationGain,
            double minLat, double maxLat, double minLng, double maxLng) {
        this.id = id;
        this.mountainId = mountainId;
        this.name = name;
        this.geometryJson = geometryJson;
        this.difficulty = difficulty;
        this.distance = distance;
        this.elevationGain = elevationGain;
        this.minLat = minLat;
        this.maxLat = maxLat;
        this.minLng = minLng;
        this.maxLng = maxLng;
    }
}
