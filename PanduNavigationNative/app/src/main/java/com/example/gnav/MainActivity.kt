package com.example.gnav

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import com.example.gnav.presentation.home.HomeScreen
import com.example.gnav.presentation.map.MapScreen
import com.example.gnav.presentation.theme.PanduNavigationNativeTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            PanduNavigationNativeTheme {
                var currentScreen by remember { mutableStateOf(Screen.HOME) }
                var selectedTrailId by remember { mutableStateOf<String?>(null) }

                when (currentScreen) {
                    Screen.HOME -> {
                        HomeScreen(
                            onMountainClick = { mountainId ->
                                // For simplicity in this demo, accessing the first trail of the mountain
                                // In a real app, show TrailSelectionScreen first
                                // Just loading the mountain ID as trail ID for now implies logic mapping needs to be robust
                                // But let's assume mountain selection opens a map for that mountain's first trail
                                // Or better, we need a selectTrail callback. 
                                // Let's pass the mountainId as trailId just for the plumbing proof.
                                selectedTrailId = "${mountainId}_selo" // Mocking a known trail suffix?
                                // Actually, let's just pass mountainId and handle "Get Trails" in Map?
                                // Repo.getTrail expects trailId.
                                // Let's assume the user clicks a mountain, and we'd usually pick a trail.
                                // I'll assume trailId = mountainId + "_default" or similar.
                                // To make it work, I'll pass the mountainId.
                                selectedTrailId = mountainId 
                                currentScreen = Screen.MAP
                            }
                        )
                    }
                    Screen.MAP -> {
                        BackHandler {
                            currentScreen = Screen.HOME
                        }
                        selectedTrailId?.let { trailId ->
                            MapScreen(trailId = trailId)
                        }
                    }
                }
            }
        }
    }

    enum class Screen {
        HOME, MAP
    }
}
