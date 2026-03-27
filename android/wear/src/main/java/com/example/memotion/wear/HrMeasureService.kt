package com.example.memotion.wear

import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothGatt
import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattDescriptor
import android.bluetooth.BluetoothGattServer
import android.bluetooth.BluetoothGattServerCallback
import android.bluetooth.BluetoothGattService
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothProfile
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.content.Intent
import android.os.ParcelUuid
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.health.services.client.HealthServices
import androidx.health.services.client.MeasureCallback
import androidx.health.services.client.data.Availability
import androidx.health.services.client.data.DataPointContainer
import androidx.health.services.client.data.DataType
import androidx.health.services.client.data.DataTypeAvailability
import androidx.health.services.client.data.DeltaDataType
import androidx.lifecycle.LifecycleService
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.guava.await
import kotlinx.coroutines.launch
import java.util.UUID

@SuppressLint("MissingPermission")
class HrMeasureService : LifecycleService() {

    companion object {
        private const val TAG = "HrMeasureService"
        private const val NOTIFICATION_ID = 1001
        private const val CHANNEL_ID = "hr_measure_channel"

        // Standard BLE Heart Rate Service / Characteristic / CCCD UUIDs
        val HR_SERVICE_UUID: UUID = UUID.fromString("0000180d-0000-1000-8000-00805f9b34fb")
        val HR_MEASUREMENT_UUID: UUID = UUID.fromString("00002a37-0000-1000-8000-00805f9b34fb")
        val CCCD_UUID: UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")

        // Shared state — MainActivity observes this
        val bpmFlow = MutableStateFlow(0)
        val availabilityFlow = MutableStateFlow<DataTypeAvailability>(DataTypeAvailability.UNKNOWN)
        val isRunning = MutableStateFlow(false)
    }

    // ── Health Services ───────────────────────────────────────────────────────

    private val measureClient by lazy {
        HealthServices.getClient(this).measureClient
    }

    private val hrCallback = object : MeasureCallback {
        override fun onAvailabilityChanged(dataType: DeltaDataType<*, *>, availability: Availability) {
            if (availability is DataTypeAvailability) {
                availabilityFlow.value = availability
                Log.d(TAG, "HR availability: $availability")
            }
        }

        override fun onDataReceived(data: DataPointContainer) {
            val points = data.getData(DataType.HEART_RATE_BPM)
            if (points.isNotEmpty()) {
                val bpm = points.last().value.toInt()
                bpmFlow.value = bpm
                Log.d(TAG, "HR received: $bpm bpm")
                notifyHrToPhone(bpm)
            }
        }
    }

    // ── BLE GATT Server ───────────────────────────────────────────────────────

    private var bluetoothManager: BluetoothManager? = null
    private var gattServer: BluetoothGattServer? = null
    private var hrCharacteristic: BluetoothGattCharacteristic? = null
    private val subscribedDevices = mutableSetOf<BluetoothDevice>()

    private val gattServerCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                Log.d(TAG, "Phone connected: ${device.address}")
                subscribedDevices.add(device)
            } else {
                Log.d(TAG, "Phone disconnected: ${device.address}")
                subscribedDevices.remove(device)
            }
        }

        override fun onCharacteristicReadRequest(
            device: BluetoothDevice, requestId: Int, offset: Int,
            characteristic: BluetoothGattCharacteristic,
        ) {
            gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, characteristic.value)
        }

        override fun onDescriptorWriteRequest(
            device: BluetoothDevice, requestId: Int,
            descriptor: BluetoothGattDescriptor,
            preparedWrite: Boolean, responseNeeded: Boolean,
            offset: Int, value: ByteArray,
        ) {
            // Phone writes to CCCD to enable/disable notifications
            descriptor.value = value
            if (responseNeeded) {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, 0, null)
            }
            val enabled = value.contentEquals(BluetoothGattDescriptor.ENABLE_NOTIFICATION_VALUE)
            Log.d(TAG, "Notifications ${if (enabled) "enabled" else "disabled"} by ${device.address}")
        }
    }

    // ── Lifecycle ─────────────────────────────────────────────────────────────

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        super.onStartCommand(intent, flags, startId)
        startForeground(NOTIFICATION_ID, buildNotification())
        registerHrCallback()
        startGattServer()
        startAdvertising()
        isRunning.value = true
        Log.d(TAG, "Service started")
        return START_STICKY
    }

    override fun onDestroy() {
        stopAdvertising()
        gattServer?.close()
        unregisterHrCallback()
        isRunning.value = false
        bpmFlow.value = 0
        availabilityFlow.value = DataTypeAvailability.UNKNOWN
        Log.d(TAG, "Service destroyed")
        super.onDestroy()
    }

    // ── Health Services ───────────────────────────────────────────────────────

    private fun registerHrCallback() {
        lifecycleScope.launch {
            try {
                val capabilities = measureClient.getCapabilitiesAsync().await()
                if (DataType.HEART_RATE_BPM !in capabilities.supportedDataTypesMeasure) {
                    Log.w(TAG, "HEART_RATE_BPM not supported on this device")
                    return@launch
                }
                measureClient.registerMeasureCallback(DataType.HEART_RATE_BPM, hrCallback)
                Log.d(TAG, "HR callback registered")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to register HR callback: $e")
            }
        }
    }

    private fun unregisterHrCallback() {
        lifecycleScope.launch {
            try {
                measureClient.unregisterMeasureCallbackAsync(DataType.HEART_RATE_BPM, hrCallback).await()
            } catch (e: Exception) {
                Log.e(TAG, "Failed to unregister HR callback: $e")
            }
        }
    }

    // ── GATT Server ───────────────────────────────────────────────────────────

    private fun startGattServer() {
        bluetoothManager = getSystemService(BluetoothManager::class.java)
        gattServer = bluetoothManager?.openGattServer(this, gattServerCallback)

        // HR Measurement characteristic (notify)
        val hrChar = BluetoothGattCharacteristic(
            HR_MEASUREMENT_UUID,
            BluetoothGattCharacteristic.PROPERTY_NOTIFY,
            BluetoothGattCharacteristic.PERMISSION_READ,
        )

        // CCCD descriptor — lets phone enable/disable notifications
        val cccd = BluetoothGattDescriptor(
            CCCD_UUID,
            BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE,
        )
        hrChar.addDescriptor(cccd)
        hrCharacteristic = hrChar

        val hrService = BluetoothGattService(HR_SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY)
        hrService.addCharacteristic(hrChar)
        gattServer?.addService(hrService)

        Log.d(TAG, "GATT server started with HR service")
    }

    private fun notifyHrToPhone(bpm: Int) {
        val char = hrCharacteristic ?: return
        if (subscribedDevices.isEmpty()) return

        // BLE Heart Rate Measurement format: flags byte (0x00 = uint8) + bpm byte
        char.value = byteArrayOf(0x00, bpm.toByte())
        subscribedDevices.forEach { device ->
            gattServer?.notifyCharacteristicChanged(device, char, false)
        }
        Log.d(TAG, "Notified ${subscribedDevices.size} device(s): $bpm bpm")
    }

    // ── BLE Advertising ───────────────────────────────────────────────────────

    private var advertiseCallback: AdvertiseCallback? = null

    private fun startAdvertising() {
        val adapter = bluetoothManager?.adapter ?: return
        val advertiser = adapter.bluetoothLeAdvertiser ?: run {
            Log.w(TAG, "BLE advertising not supported")
            return
        }

        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setConnectable(true)
            .setTimeout(0) // advertise indefinitely
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .build()

        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .addServiceUuid(ParcelUuid(HR_SERVICE_UUID))
            .build()

        advertiseCallback = object : AdvertiseCallback() {
            override fun onStartSuccess(settingsInEffect: AdvertiseSettings) {
                Log.d(TAG, "BLE advertising started — HR service visible to phone")
            }
            override fun onStartFailure(errorCode: Int) {
                Log.e(TAG, "BLE advertising failed: $errorCode")
            }
        }

        advertiser.startAdvertising(settings, data, advertiseCallback)
    }

    private fun stopAdvertising() {
        val advertiser = bluetoothManager?.adapter?.bluetoothLeAdvertiser ?: return
        advertiseCallback?.let { advertiser.stopAdvertising(it) }
    }

    // ── Notification ──────────────────────────────────────────────────────────

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID, "Heart Rate Monitor", NotificationManager.IMPORTANCE_LOW,
        ).apply { description = "Keeps heart rate sensor active for Memotion" }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    private fun buildNotification(): Notification {
        val openIntent = PendingIntent.getActivity(
            this, 0, Intent(this, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE,
        )
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_menu_compass)
            .setContentTitle("Memotion")
            .setContentText("Measuring heart rate…")
            .setContentIntent(openIntent)
            .setOngoing(true)
            .build()
    }
}
