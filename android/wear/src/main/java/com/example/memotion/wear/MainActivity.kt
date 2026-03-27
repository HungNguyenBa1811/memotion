package com.example.memotion.wear

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.health.services.client.data.DataTypeAvailability
import androidx.wear.compose.material.Button
import androidx.wear.compose.material.ButtonDefaults
import androidx.wear.compose.material.MaterialTheme
import androidx.wear.compose.material.Text

class MainActivity : ComponentActivity() {

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { results ->
        val granted = results.values.all { it }
        Log.d("MainActivity", "Permissions granted: $granted, results: $results")
        if (granted) startHrService()
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                HrScreen(
                    onStart = { requestPermissionsAndStart() },
                    onStop = { stopHrService() },
                )
            }
        }
    }

    private fun requestPermissionsAndStart() {
        val perms = arrayOf(
            Manifest.permission.BODY_SENSORS,
            Manifest.permission.POST_NOTIFICATIONS,
            Manifest.permission.BLUETOOTH_ADVERTISE,
            Manifest.permission.BLUETOOTH_CONNECT,
        )
        val allGranted = perms.all {
            checkSelfPermission(it) == PackageManager.PERMISSION_GRANTED
        }
        if (allGranted) startHrService() else permissionLauncher.launch(perms)
    }

    private fun startHrService() {
        startForegroundService(Intent(this, HrMeasureService::class.java))
    }

    private fun stopHrService() {
        stopService(Intent(this, HrMeasureService::class.java))
    }
}

@Composable
private fun HrScreen(onStart: () -> Unit, onStop: () -> Unit) {
    val bpm by HrMeasureService.bpmFlow.collectAsState()
    val availability by HrMeasureService.availabilityFlow.collectAsState()
    val isRunning by HrMeasureService.isRunning.collectAsState()

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color.Black),
        contentAlignment = Alignment.Center,
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.padding(16.dp),
        ) {
            // BPM display
            Text(
                text = if (bpm > 0) "$bpm" else "--",
                fontSize = 52.sp,
                fontWeight = FontWeight.Bold,
                color = if (bpm > 0) Color(0xFFEF5350) else Color.Gray,
                textAlign = TextAlign.Center,
            )
            Text(
                text = "bpm",
                fontSize = 16.sp,
                color = Color.Gray,
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Availability status
            Text(
                text = availability.toLabel(),
                fontSize = 12.sp,
                color = availability.toColor(),
                textAlign = TextAlign.Center,
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Start / Stop button
            Button(
                onClick = if (isRunning) onStop else onStart,
                modifier = Modifier.size(80.dp),
                colors = ButtonDefaults.buttonColors(
                    backgroundColor = if (isRunning) Color(0xFF424242) else Color(0xFF1B5E20),
                ),
            ) {
                Text(
                    text = if (isRunning) "Stop" else "Start",
                    fontSize = 14.sp,
                    color = Color.White,
                )
            }
        }
    }
}

private fun DataTypeAvailability.toLabel(): String = when (this) {
    DataTypeAvailability.AVAILABLE -> "Sensor ready"
    DataTypeAvailability.ACQUIRING -> "Acquiring…"
    DataTypeAvailability.UNAVAILABLE -> "Sensor unavailable"
    DataTypeAvailability.UNAVAILABLE_DEVICE_OFF_BODY -> "Wear the watch"
    else -> "Unknown"
}

private fun DataTypeAvailability.toColor(): Color = when (this) {
    DataTypeAvailability.AVAILABLE -> Color(0xFF66BB6A)
    DataTypeAvailability.ACQUIRING -> Color(0xFFFFA726)
    else -> Color(0xFFEF5350)
}
