package com.fatihatalay.kuranvenamaz

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import org.json.JSONArray
import org.json.JSONObject

class PrayerAlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        if (intent?.action != ACTION_TRIGGER_PRAYER_ALARM) return

        val powerManager = context.getSystemService(Context.POWER_SERVICE) as? PowerManager
        val wakeLock = powerManager?.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "kuranvenamaz:AlarmReceiverWakeLock"
        )
        wakeLock?.acquire(15_000L)

        try {
            val alarmId = intent.getIntExtra(EXTRA_ALARM_ID, 9999)
            val title = intent.getStringExtra(EXTRA_TITLE) ?: "🕌 Namaz Vakti"
            val body = intent.getStringExtra(EXTRA_BODY) ?: "Haydi namaza! Durdurmak için dokunun veya ses tuşuna basın."
            PrayerForegroundService.startAlarm(context, alarmId, title, body)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    companion object {
        const val ACTION_TRIGGER_PRAYER_ALARM = "com.fatihatalay.kuranvenamaz.ACTION_TRIGGER_PRAYER_ALARM"
        const val EXTRA_ALARM_ID = "EXTRA_ALARM_ID"
        const val EXTRA_TITLE = "EXTRA_TITLE"
        const val EXTRA_BODY = "EXTRA_BODY"
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private const val KEY_SAVED_ALARMS = "native_scheduled_ezan_alarms"

        private fun buildPendingIntent(
            context: Context,
            id: Int,
            title: String,
            body: String,
            flags: Int
        ): PendingIntent? {
            val intent = Intent(context, PrayerAlarmReceiver::class.java).apply {
                action = ACTION_TRIGGER_PRAYER_ALARM
                putExtra(EXTRA_ALARM_ID, id)
                putExtra(EXTRA_TITLE, title)
                putExtra(EXTRA_BODY, body)
            }
            return PendingIntent.getBroadcast(context, id, intent, flags)
        }

        fun scheduleAlarm(
            context: Context,
            id: Int,
            triggerAtMillis: Long,
            title: String,
            body: String
        ) {
            if (triggerAtMillis <= System.currentTimeMillis()) return

            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
            val operation = buildPendingIntent(context, id, title, body, flags) ?: return

            try {
                val info = AlarmManager.AlarmClockInfo(triggerAtMillis, null)
                alarmManager.setAlarmClock(info, operation)
            } catch (e: Exception) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAtMillis, operation)
                } else {
                    alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerAtMillis, operation)
                }
            }

            saveAlarmRecord(context, id, triggerAtMillis, title, body)
        }

        fun cancelAllScheduledAlarms(context: Context) {
            try {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                val raw = prefs.getString(KEY_SAVED_ALARMS, null)
                val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                val flags = PendingIntent.FLAG_NO_CREATE or
                    (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)

                val idsToCancel = mutableSetOf(998, 999, 888)
                if (!raw.isNullOrBlank()) {
                    val arr = JSONArray(raw)
                    for (i in 0 until arr.length()) {
                        val obj = arr.optJSONObject(i) ?: continue
                        idsToCancel.add(obj.optInt("id"))
                    }
                }

                for (id in idsToCancel) {
                    val pi = buildPendingIntent(context, id, "", "", flags)
                    if (pi != null) {
                        alarmManager.cancel(pi)
                        pi.cancel()
                    }
                }

                prefs.edit().remove(KEY_SAVED_ALARMS).apply()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        fun rescheduleSavedAlarmsOnBoot(context: Context) {
            try {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                val raw = prefs.getString(KEY_SAVED_ALARMS, null) ?: return
                val arr = JSONArray(raw)
                val now = System.currentTimeMillis()
                val kept = JSONArray()

                for (i in 0 until arr.length()) {
                    val obj = arr.optJSONObject(i) ?: continue
                    val triggerAt = obj.optLong("triggerAtMillis", 0L)
                    if (triggerAt > now) {
                        val id = obj.optInt("id")
                        val title = obj.optString("title", "🕌 Namaz Vakti")
                        val body = obj.optString("body", "Haydi namaza!")
                        kept.put(obj)

                        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
                        val flags = PendingIntent.FLAG_UPDATE_CURRENT or
                            (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0)
                        val operation = buildPendingIntent(context, id, title, body, flags)
                        if (operation != null) {
                            try {
                                alarmManager.setAlarmClock(AlarmManager.AlarmClockInfo(triggerAt, null), operation)
                            } catch (_: Exception) {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerAt, operation)
                                }
                            }
                        }
                    }
                }
                prefs.edit().putString(KEY_SAVED_ALARMS, kept.toString()).apply()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }

        private fun saveAlarmRecord(
            context: Context,
            id: Int,
            triggerAtMillis: Long,
            title: String,
            body: String
        ) {
            try {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                val raw = prefs.getString(KEY_SAVED_ALARMS, null)
                val existing = if (!raw.isNullOrBlank()) JSONArray(raw) else JSONArray()
                val updated = JSONArray()
                val now = System.currentTimeMillis()

                for (i in 0 until existing.length()) {
                    val obj = existing.optJSONObject(i) ?: continue
                    if (obj.optInt("id") != id && obj.optLong("triggerAtMillis") > now) {
                        updated.put(obj)
                    }
                }

                updated.put(JSONObject().apply {
                    put("id", id)
                    put("triggerAtMillis", triggerAtMillis)
                    put("title", title)
                    put("body", body)
                })

                prefs.edit().putString(KEY_SAVED_ALARMS, updated.toString()).apply()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
