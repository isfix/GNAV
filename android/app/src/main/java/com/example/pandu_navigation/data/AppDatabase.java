package com.example.pandu_navigation.data;

import androidx.room.Database;
import androidx.room.RoomDatabase;

@Database(entities = { TrailEntity.class, BreadcrumbEntity.class }, version = 1, exportSchema = false)
public abstract class AppDatabase extends RoomDatabase {
    public abstract NavigationDao navigationDao();
}
