package com.example.gnav.core.di

import android.content.Context
import androidx.room.Room
import com.example.gnav.data.db.AppDatabase
import com.example.gnav.data.db.NavigationDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideAppDatabase(@ApplicationContext context: Context): AppDatabase {
        return Room.databaseBuilder(
            context,
            AppDatabase::class.java,
            "gnav_native_db"
        ).build()
    }

    @Provides
    fun provideNavigationDao(database: AppDatabase): NavigationDao {
        return database.navigationDao()
    }
}
