package com.example.pandu_navigation.data;

import android.content.Context;

import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;

@Database(entities = { TrailEntity.class, BreadcrumbEntity.class, PoiEntity.class,
        MountainEntity.class }, version = 3, exportSchema = false)
public abstract class AppDatabase extends RoomDatabase {

    private static volatile AppDatabase INSTANCE;

    public abstract NavigationDao navigationDao();

    public static AppDatabase getDatabase(final Context context) {
        if (INSTANCE == null) {
            synchronized (AppDatabase.class) {
                if (INSTANCE == null) {
                    INSTANCE = Room.databaseBuilder(context.getApplicationContext(),
                            AppDatabase.class, "pandu_native_db")
                            .fallbackToDestructiveMigration() // For development simplicity
                            .allowMainThreadQueries() // Warn: Only for initialization if needed, prefer background
                            .build();
                }
            }
        }
        return INSTANCE;
    }
}
