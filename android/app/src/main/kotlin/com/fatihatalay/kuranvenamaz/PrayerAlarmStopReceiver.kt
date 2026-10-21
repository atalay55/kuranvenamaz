package com.fatihatalay.kuranvenamaz

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class PrayerAlarmStopReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        try {
            PrayerForegroundService.stopAlarm(context)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
