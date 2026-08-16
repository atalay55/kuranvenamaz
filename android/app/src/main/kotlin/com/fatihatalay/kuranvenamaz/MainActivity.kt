package com.fatihatalay.kuranvenamaz

import android.app.NotificationManager
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

                // Tüm gerekli bildirim izinlerinin durumunu tek seferde döner
                "checkNotificationPermissions" -> {
                    val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val isIgnoringBattery = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        powerManager.isIgnoringBatteryOptimizations(packageName)
                    } else {
                        true
                    }

                    val notifManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    val areNotificationsEnabled = notifManager.areNotificationsEnabled()

                    val canScheduleExact = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as android.app.AlarmManager
                        alarmManager.canScheduleExactAlarms()
                    } else {
                        true
                    }

                    val permissions = mapOf(
                        "notificationsEnabled" to areNotificationsEnabled,
                        "batteryOptimizationIgnored" to isIgnoringBattery,
                        "exactAlarmAllowed" to canScheduleExact,
                        "manufacturer" to Build.MANUFACTURER,
                        "model" to Build.MODEL,
                        "androidVersion" to Build.VERSION.SDK_INT
                    )
                    result.success(permissions)
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
                    val intentOpened = tryOpenAutostartSettings()
                    if (!intentOpened) {
                        openAppDetailsSettings()
                    }
                    result.success(intentOpened)
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

                "openNotificationSettings" -> {
                    try {
                        val intent = Intent()
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            intent.action = Settings.ACTION_APP_NOTIFICATION_SETTINGS
                            intent.putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        } else {
                            intent.action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS
                            intent.data = Uri.parse("package:$packageName")
                        }
                        startActivity(intent)
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

    /**
     * Xiaomi MIUI / HyperOS + diğer OEM üreticiler için otomatik başlatma
     * (Autostart) ayarlarını açmayı dener. Birden fazla fallback yolu
     * denenir; hiçbiri işe yaramazsa false döner.
     */
    private fun tryOpenAutostartSettings(): Boolean {
        val manufacturer = Build.MANUFACTURER.lowercase()

        // Xiaomi / Redmi / POCO (MIUI 12 ve öncesi)
        if (manufacturer.contains("xiaomi") || manufacturer.contains("redmi") || manufacturer.contains("poco")) {
            // HyperOS / MIUI 14+ → yeni paket adı
            val hyperosTargets = listOf(
                Pair("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"),
                Pair("com.miui.securitycenter", "com.miui.powerkeeper.ui.HiddenAppsContainerManagementActivity"),
                Pair("com.miui.securitycenter", "com.miui.powerkeeper.ui.HiddenAppsConfigActivity"),
                Pair("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"),
                // MIUI 10 ve öncesi
                Pair("com.xiaomi.xmsf", "com.xiaomi.xmsf.push.service.XmsfPushServiceAutoStartManagementActivity")
            )
            for ((pkg, cls) in hyperosTargets) {
                if (tryStartActivity(pkg, cls)) return true
            }
        }

        // Huawei / Honor
        if (manufacturer.contains("huawei") || manufacturer.contains("honor")) {
            val targets = listOf(
                Pair("com.huawei.systemmanager", "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity"),
                Pair("com.huawei.systemmanager", "com.huawei.systemmanager.optimize.process.ProtectActivity"),
                Pair("com.huawei.systemmanager", "com.huawei.systemmanager.appcontrol.activity.StartupAppControlActivity")
            )
            for ((pkg, cls) in targets) {
                if (tryStartActivity(pkg, cls)) return true
            }
        }

        // OPPO / Realme / OnePlus (ColorOS)
        if (manufacturer.contains("oppo") || manufacturer.contains("realme") || manufacturer.contains("oneplus")) {
            val targets = listOf(
                Pair("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"),
                Pair("com.coloros.oppoguardelf", "com.coloros.powermanager.powersave.PowerUsageModelActivity"),
                Pair("com.oppo.safe", "com.oppo.safe.permission.startup.StartupAppListActivity")
            )
            for ((pkg, cls) in targets) {
                if (tryStartActivity(pkg, cls)) return true
            }
        }

        // Vivo / iQOO (FunTouchOS / OriginOS)
        if (manufacturer.contains("vivo")) {
            val targets = listOf(
                Pair("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"),
                Pair("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.AddWhiteListActivity"),
                Pair("com.iqoo.secure", "com.iqoo.secure.ui.phoneoptimize.BgStartUpManager")
            )
            for ((pkg, cls) in targets) {
                if (tryStartActivity(pkg, cls)) return true
            }
        }

        // Samsung (One UI)
        if (manufacturer.contains("samsung")) {
            val targets = listOf(
                Pair("com.samsung.android.lool", "com.samsung.android.sm.ui.battery.BatteryActivity"),
                Pair("com.samsung.android.sm", "com.samsung.android.sm.ui.battery.BatteryActivity")
            )
            for ((pkg, cls) in targets) {
                if (tryStartActivity(pkg, cls)) return true
            }
        }

        return false
    }

    private fun tryStartActivity(pkg: String, cls: String): Boolean {
        return try {
            val intent = Intent()
            intent.component = ComponentName(pkg, cls)
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun openAppDetailsSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.parse("package:$packageName")
        startActivity(intent)
    }
}
