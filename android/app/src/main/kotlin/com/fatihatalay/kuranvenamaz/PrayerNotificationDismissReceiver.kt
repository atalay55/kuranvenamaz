package com.fatihatalay.kuranvenamaz

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class PrayerNotificationDismissReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        // Kullanıcı bildirimi kaydırarak silmeye veya kapatmaya çalışırsa anında geri getir
        try {
            PrayerForegroundService.startService(context)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
