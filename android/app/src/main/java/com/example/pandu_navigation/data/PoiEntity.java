package com.example.pandu_navigation.data;

import androidx.annotation.NonNull;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "pois")
public class PoiEntity {
    @PrimaryKey
    @NonNull
    public String id;
    public String mountainId;
    public String name;
    public String type; // e.g. "camp", "water", "pos"
    public double lat;
    public double lng;
    public double elevation;

    public PoiEntity(@NonNull String id, String mountainId, String name, String type, double lat, double lng,
            double elevation) {
        this.id = id;
        this.mountainId = mountainId;
        this.name = name;
        this.type = type;
        this.lat = lat;
        this.lng = lng;
        this.elevation = elevation;
    }
}
