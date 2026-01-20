package com.example.pandu_navigation.data;

import androidx.room.Entity;
import androidx.room.PrimaryKey;
import androidx.room.ColumnInfo;

@Entity(tableName = "user_breadcrumbs")
public class BreadcrumbEntity {
    @PrimaryKey(autoGenerate = true)
    public long id;

    @ColumnInfo(name = "session_id")
    public String sessionId;

    public double lat;
    public double lng;
    public Double altitude;
    public double accuracy;
    public Double speed;

    public long timestamp;

    @ColumnInfo(name = "is_synced")
    public boolean isSynced;
}
