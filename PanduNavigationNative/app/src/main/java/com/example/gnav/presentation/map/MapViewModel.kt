package com.example.gnav.presentation.map

import android.content.Context
import android.content.Intent
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.gnav.data.db.BreadcrumbEntity
import com.example.gnav.domain.repository.NavigationRepository
import com.example.gnav.service.TrackingService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

@HiltViewModel
class MapViewModel @Inject constructor(
    private val repository: NavigationRepository
) : ViewModel() {

    val currentBreadcrumb: StateFlow<BreadcrumbEntity?> = repository.observeLastBreadcrumb()
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.WhileSubscribed(5000),
            initialValue = null
        )

    fun startNavigation(context: Context, trailId: String) {
        val intent = Intent(context, TrackingService::class.java).apply {
            action = TrackingService.ACTION_START_TRACKING
            putExtra(TrackingService.EXTRA_TRAIL_ID, trailId)
        }
        context.startForegroundService(intent)
    }

    fun stopNavigation(context: Context) {
        val intent = Intent(context, TrackingService::class.java).apply {
            action = TrackingService.ACTION_STOP_TRACKING
        }
        context.startService(intent)
    }
}
