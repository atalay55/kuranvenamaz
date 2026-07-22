package com.fatihatalay.kuranvenamaz

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.fatihatalay.kuranvenamaz/device_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getDeviceManufacturer" -> {
                    result.success(Build.MANUFACTURER)
                }
                "isIgnoringBatteryOptimizations" -> {
                    val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        result.success(powerManager.isIgnoringBatteryOptimizations(packageName))
                    } else {
                        result.success(true)
                    }
                }
                "openAutostartSettings" -> {
                    try {
                        val manufacturer = Build.MANUFACTURER.lowercase()
                        var intentOpened = false

                        if (manufacturer.contains("xiaomi") || manufacturer.contains("redmi") || manufacturer.contains("poco")) {
                            val intent = Intent()
                            intent.component = ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity")
                            try {
                                startActivity(intent)
                                intentOpened = true
                            } catch (e: Exception) {
                                try {
                                    val intent2 = Intent()
                                    intent2.component = ComponentName("com.miui.securitycenter", "com.miui.powerkeeper.ui.HiddenAppsConfigActivity")
                                    startActivity(intent2)
                                    intentOpened = true
                                } catch (e2: Exception) {}
                            }
                        } else if (manufacturer.contains("huawei") || manufacturer.contains("honor")) {
                            val intent = Intent()
                            intent.component = ComponentName("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity")
                            try {
                                startActivity(intent)
                                intentOpened = true
                            } catch (e: Exception) {}
                        } else if (manufacturer.contains("oppo") || manufacturer.contains("realme")) {
                            val intent = Intent()
                            intent.component = ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity")
                            try {
                                startActivity(intent)
                                intentOpened = true
                            } catch (e: Exception) {}
                        } else if (manufacturer.contains("vivo")) {
                            val intent = Intent()
                            intent.component = ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity")
                            try {
                                startActivity(intent)
                                intentOpened = true
                            } catch (e: Exception) {}
                        } else if (manufacturer.contains("samsung")) {
                            val intent = Intent()
                            intent.component = ComponentName("com.samsung.android.looper", "com.samsung.android.sm.ui.battery.BatteryActivity")
                            try {
                                startActivity(intent)
                                intentOpened = true
                            } catch (e: Exception) {}
                        }

                        if (!intentOpened) {
                            openAppDetailsSettings()
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        openAppDetailsSettings()
                        result.success(false)
                    }
                }
                "openBatteryOptimizationSettings" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                            intent.data = Uri.parse("package:$packageName")
                            startActivity(intent)
                        } else {
                            openAppDetailsSettings()
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)
                            startActivity(intent)
                            result.success(true)
                        } catch (ex: Exception) {
                            openAppDetailsSettings()
                            result.success(false)
                        }
                    }
                }
                "openExactAlarmSettings" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                            intent.data = Uri.parse("package:$packageName")
                            startActivity(intent)
                        } else {
                            openAppDetailsSettings()
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        openAppDetailsSettings()
                        result.success(false)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun openAppDetailsSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:$packageName")
        startActivity(intent)
    }
}
