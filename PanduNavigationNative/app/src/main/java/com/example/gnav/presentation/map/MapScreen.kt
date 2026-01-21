package com.example.gnav.presentation.map

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.gnav.presentation.theme.NeonGreen
import org.maplibre.android.MapLibre
import org.maplibre.android.maps.MapView
import org.maplibre.android.maps.Style

@Composable
fun MapScreen(
    trailId: String,
    viewModel: MapViewModel = viewModel()
) {
    val context = LocalContext.current
    val breadcrumb by viewModel.currentBreadcrumb.collectAsState()
    
    // Init MapLibre
    MapLibre.getInstance(context)

    // Lifecycle Observer for MapView
    val lifecycleOwner = LocalLifecycleOwner.current
    val mapView = remember { MapView(context) }
    
    DisposableEffect(lifecycleOwner) {
        val observer = LifecycleEventObserver { _, event ->
            when(event) {
                Lifecycle.Event.ON_START -> mapView.onStart()
                Lifecycle.Event.ON_RESUME -> mapView.onResume()
                Lifecycle.Event.ON_PAUSE -> mapView.onPause()
                Lifecycle.Event.ON_STOP -> mapView.onStop()
                Lifecycle.Event.ON_DESTROY -> mapView.onDestroy()
                else -> {}
            }
        }
        lifecycleOwner.lifecycle.addObserver(observer)
        onDispose {
            lifecycleOwner.lifecycle.removeObserver(observer)
        }
    }

    LaunchedEffect(Unit) {
        // Start Service on enter
        viewModel.startNavigation(context, trailId)
    }

    Box(modifier = Modifier.fillMaxSize()) {
        AndroidView(
            factory = { 
                mapView.apply {
                    onCreate(null)
                    getMapAsync { map ->
                        map.setStyle(Style.getPredefinedStyle("Streets"))
                        map.uiSettings.isAttributionEnabled = false
                        map.uiSettings.isLogoEnabled = false
                    }
                }
            },
            modifier = Modifier.fillMaxSize()
        )

        // HUD Overlay
        Column(
            modifier = Modifier
                .align(Alignment.BottomCenter)
                .fillMaxWidth()
                .background(Color(0xCC000000))
                .padding(16.dp)
        ) {
            Text(
                text = "STATUS: ${if (breadcrumb?.isOffTrail == true) "OFF TRAIL" else "ON TRAIL"}",
                color = if (breadcrumb?.isOffTrail == true) Color.Red else NeonGreen,
                style = MaterialTheme.typography.titleLarge
            )
            if (breadcrumb != null) {
                Text(
                    text = "Lat: ${breadcrumb?.lat} Lng: ${breadcrumb?.lng}",
                    color = Color.White
                )
                Text(
                    text = "Accuracy: ${breadcrumb?.accuracy}m",
                    color = Color.White
                )
            } else {
                Text("Waiting for GPS...", color = Color.Gray)
            }
            
            Button(
                onClick = { viewModel.stopNavigation(context) },
                modifier = Modifier.padding(top = 8.dp)
            ) {
                Text("Stop Navigation")
            }
        }
    }
}
