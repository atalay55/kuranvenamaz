package com.fatihatalay.kuranvenamaz

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.graphics.Color
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat

class PrayerForegroundService : Service() {

    companion object {
        const val CHANNEL_ID = "kuran_ve_namaz_foreground_channel"
        const val NOTIFICATION_ID = 777

        fun startService(context: Context) {
            try {
                val intent = Intent(context, PrayerForegroundService::class.java)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        fun updateWithPrayerTimes(
            context: Context,
            city: String,
            nextPrayer: String,
            nextPrayerTime: String,
            remaining: String,
            imsak: String,
            gunes: String,
            ogle: String,
            ikindi: String,
            aksam: String,
            yatsi: String
        ) {
            try {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                prefs.edit().apply {
                    if (city.isNotEmpty()) putString("flutter.city", city)
                    if (nextPrayer.isNotEmpty()) putString("flutter.next_prayer_name", nextPrayer)
                    if (nextPrayerTime.isNotEmpty()) putString("flutter.next_prayer_time", nextPrayerTime)
                    if (remaining.isNotEmpty()) putString("flutter.remaining_formatted", remaining)
                    if (imsak.isNotEmpty()) putString("flutter.vakit_imsak", imsak)
                    if (gunes.isNotEmpty()) putString("flutter.vakit_gunes", gunes)
                    if (ogle.isNotEmpty()) putString("flutter.vakit_ogle", ogle)
                    if (ikindi.isNotEmpty()) putString("flutter.vakit_ikindi", ikindi)
                    if (aksam.isNotEmpty()) putString("flutter.vakit_aksam", aksam)
                    if (yatsi.isNotEmpty()) putString("flutter.vakit_yatsi", yatsi)
                    apply()
                }

                val intent = Intent(context, PrayerForegroundService::class.java).apply {
                    putExtra("EXTRA_CITY", city)
                    putExtra("EXTRA_NEXT_PRAYER", nextPrayer)
                    putExtra("EXTRA_NEXT_TIME", nextPrayerTime)
                    putExtra("EXTRA_REMAINING", remaining)
                    putExtra("EXTRA_IMSAK", imsak)
                    putExtra("EXTRA_GUNES", gunes)
                    putExtra("EXTRA_OGLE", ogle)
                    putExtra("EXTRA_IKINDI", ikindi)
                    putExtra("EXTRA_AKSAM", aksam)
                    putExtra("EXTRA_YATSI", yatsi)
                }

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    context.startForegroundService(intent)
                } else {
                    context.startService(intent)
                }
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        fun stopService(context: Context) {
            try {
                val intent = Intent(context, PrayerForegroundService::class.java)
                context.stopService(intent)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private var watchdogHandler: Handler? = null
    private var watchdogRunnable: Runnable? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()

        watchdogHandler = Handler(Looper.getMainLooper())
        watchdogRunnable = object : Runnable {
            override fun run() {
                try {
                    val notification = buildForegroundNotification()
                    val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    manager.notify(NOTIFICATION_ID, notification)
                } catch (e: Exception) {
                    e.printStackTrace()
                }
                watchdogHandler?.postDelayed(this, 30000)
            }
        }
        watchdogHandler?.postDelayed(watchdogRunnable!!, 30000)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val notification = buildForegroundNotification(intent)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        return START_STICKY
    }

    override fun onTaskRemoved(rootIntent: Intent?) {
        super.onTaskRemoved(rootIntent)
        try {
            val restartServiceIntent = Intent(applicationContext, PrayerForegroundService::class.java).also {
                it.setPackage(packageName)
            }
            val restartPendingIntent = PendingIntent.getService(
                applicationContext,
                1001,
                restartServiceIntent,
                PendingIntent.FLAG_ONE_SHOT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
            )
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as? android.app.AlarmManager
            alarmManager?.set(
                android.app.AlarmManager.ELAPSED_REALTIME,
                android.os.SystemClock.elapsedRealtime() + 1000,
                restartPendingIntent
            )
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    override fun onDestroy() {
        watchdogRunnable?.let { watchdogHandler?.removeCallbacks(it) }
        super.onDestroy()
        startService(applicationContext)
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Namaz Vakitleri Takip Servisi",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Namaz vakitlerinin ve ezan alarmlarının kesintisiz çalışmasını sağlar."
                setShowBadge(false)
                setSound(null, null)
                enableVibration(false)
            }
            val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildForegroundNotification(intent: Intent? = null): Notification {
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = PendingIntent.getActivity(
            this,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val deleteIntent = Intent(this, PrayerNotificationDismissReceiver::class.java).apply {
            action = "ACTION_NOTIFICATION_DISMISSED"
        }
        val deletePendingIntent = PendingIntent.getBroadcast(
            this,
            778,
            deleteIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
        )

        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

        val city = intent?.getStringExtra("EXTRA_CITY")
            ?: prefs.getString("flutter.city", null)
            ?: prefs.getString("flutter.city_name", null)
            ?: "Kuran ve Namaz"

        val nextPrayer = intent?.getStringExtra("EXTRA_NEXT_PRAYER")
            ?: prefs.getString("flutter.next_prayer_name", null)
            ?: ""

        val nextTime = intent?.getStringExtra("EXTRA_NEXT_TIME")
            ?: prefs.getString("flutter.next_prayer_time", null)
            ?: ""

        val remaining = intent?.getStringExtra("EXTRA_REMAINING")
            ?: prefs.getString("flutter.remaining_formatted", null)
            ?: prefs.getString("flutter.remaining_short", null)
            ?: "00:00"

        val imsak = intent?.getStringExtra("EXTRA_IMSAK")
            ?: prefs.getString("flutter.vakit_imsak", null) ?: "--:--"
        val gunes = intent?.getStringExtra("EXTRA_GUNES")
            ?: prefs.getString("flutter.vakit_gunes", null) ?: "--:--"
        val ogle = intent?.getStringExtra("EXTRA_OGLE")
            ?: prefs.getString("flutter.vakit_ogle", null) ?: "--:--"
        val ikindi = intent?.getStringExtra("EXTRA_IKINDI")
            ?: prefs.getString("flutter.vakit_ikindi", null) ?: "--:--"
        val aksam = intent?.getStringExtra("EXTRA_AKSAM")
            ?: prefs.getString("flutter.vakit_aksam", null) ?: "--:--"
        val yatsi = intent?.getStringExtra("EXTRA_YATSI")
            ?: prefs.getString("flutter.vakit_yatsi", null) ?: "--:--"

        // 1. Küçük Görünüm (notification_prayer_bar)
        val remoteViewsSmall = RemoteViews(packageName, R.layout.notification_prayer_bar)
        try {
            populatePrayerRemoteViews(remoteViewsSmall, remaining, nextPrayer, imsak, gunes, ogle, ikindi, aksam, yatsi)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // 2. Genişletilmiş Görünüm (notification_prayer_bar_expanded)
        val remoteViewsExpanded = RemoteViews(packageName, R.layout.notification_prayer_bar_expanded)
        try {
            remoteViewsExpanded.setTextViewText(R.id.notif_expanded_city, "🕌 $city")
            val statusText = if (nextPrayer.isNotEmpty() && nextTime.isNotEmpty()) {
                "Sıradaki: $nextPrayer ($nextTime)"
            } else {
                "Ezan Alarmları Devrede"
            }
            remoteViewsExpanded.setTextViewText(R.id.notif_expanded_status, statusText)
            populatePrayerRemoteViews(remoteViewsExpanded, remaining, nextPrayer, imsak, gunes, ogle, ikindi, aksam, yatsi)
        } catch (e: Exception) {
            e.printStackTrace()
        }

        val fallbackTitle = "🕌 $city • Sıradaki: $nextPrayer ($remaining)"
        val fallbackText = "İms $imsak • Gün $gunes • Öğl $ogle • İkn $ikindi • Akş $aksam • Yat $yatsi"

        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(fallbackTitle)
            .setContentText(fallbackText)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setStyle(NotificationCompat.DecoratedCustomViewStyle())
            .setCustomContentView(remoteViewsSmall)
            .setCustomBigContentView(remoteViewsExpanded)
            .setOngoing(true)
            .setAutoCancel(false)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setContentIntent(pendingIntent)
            .setDeleteIntent(deletePendingIntent)

        val notification = builder.build()
        notification.flags = notification.flags or Notification.FLAG_NO_CLEAR or Notification.FLAG_ONGOING_EVENT
        return notification
    }

    private fun populatePrayerRemoteViews(
        views: RemoteViews,
        countdown: String,
        nextPrayer: String,
        imsak: String,
        gunes: String,
        ogle: String,
        ikindi: String,
        aksam: String,
        yatsi: String
    ) {
        views.setTextViewText(R.id.notif_countdown, countdown)
        views.setTextViewText(R.id.notif_time_imsak, imsak)
        views.setTextViewText(R.id.notif_time_gunes, gunes)
        views.setTextViewText(R.id.notif_time_ogle, ogle)
        views.setTextViewText(R.id.notif_time_ikindi, ikindi)
        views.setTextViewText(R.id.notif_time_aksam, aksam)
        views.setTextViewText(R.id.notif_time_yatsi, yatsi)

        val activeColId = when {
            nextPrayer.contains("imsak", true) || nextPrayer.contains("fajr", true) -> R.id.notif_col_imsak
            nextPrayer.contains("güneş", true) || nextPrayer.contains("gunes", true) || nextPrayer.contains("sunrise", true) -> R.id.notif_col_gunes
            nextPrayer.contains("öğle", true) || nextPrayer.contains("ogle", true) || nextPrayer.contains("zuhr", true) || nextPrayer.contains("dhuhr", true) -> R.id.notif_col_ogle
            nextPrayer.contains("ikindi", true) || nextPrayer.contains("asr", true) -> R.id.notif_col_ikindi
            nextPrayer.contains("akşam", true) || nextPrayer.contains("aksam", true) || nextPrayer.contains("maghrib", true) -> R.id.notif_col_aksam
            nextPrayer.contains("yatsı", true) || nextPrayer.contains("yatsi", true) || nextPrayer.contains("isha", true) -> R.id.notif_col_yatsi
            else -> 0
        }

        val allCols = listOf(
            Triple(R.id.notif_col_imsak, R.id.notif_name_imsak, R.id.notif_time_imsak),
            Triple(R.id.notif_col_gunes, R.id.notif_name_gunes, R.id.notif_time_gunes),
            Triple(R.id.notif_col_ogle, R.id.notif_name_ogle, R.id.notif_time_ogle),
            Triple(R.id.notif_col_ikindi, R.id.notif_name_ikindi, R.id.notif_time_ikindi),
            Triple(R.id.notif_col_aksam, R.id.notif_name_aksam, R.id.notif_time_aksam),
            Triple(R.id.notif_col_yatsi, R.id.notif_name_yatsi, R.id.notif_time_yatsi)
        )

        for ((colId, nameId, timeId) in allCols) {
            if (colId == activeColId) {
                views.setInt(colId, "setBackgroundResource", R.drawable.notification_active_pill)
                views.setTextColor(nameId, Color.parseColor("#F5E6AD"))
                views.setTextColor(timeId, Color.WHITE)
            } else {
                views.setInt(colId, "setBackgroundResource", 0)
                views.setTextColor(nameId, Color.parseColor("#757575"))
                views.setTextColor(timeId, Color.parseColor("#212121"))
            }
        }
    }
}
