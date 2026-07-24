package com.fatihatalay.kuranvenamaz

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class NamazWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_namaz_vakitleri).apply {
                val city = widgetData.getString("city_name", "İstanbul") ?: "İstanbul"
                val country = widgetData.getString("country_name", "Turkey") ?: "Turkey"
                val nextName = widgetData.getString("next_prayer_name", "Vakit") ?: "Vakit"
                val nextTime = widgetData.getString("next_prayer_time", "") ?: ""
                val remaining = widgetData.getString("remaining_short", "") ?: ""

                val imsak = widgetData.getString("vakit_imsak", "--:--") ?: "--:--"
                val gunes = widgetData.getString("vakit_gunes", "--:--") ?: "--:--"
                val ogle = widgetData.getString("vakit_ogle", "--:--") ?: "--:--"
                val ikindi = widgetData.getString("vakit_ikindi", "--:--") ?: "--:--"
                val aksam = widgetData.getString("vakit_aksam", "--:--") ?: "--:--"
                val yatsi = widgetData.getString("vakit_yatsi", "--:--") ?: "--:--"

                setTextViewText(R.id.widget_city_name, "$city, $country")
                setTextViewText(R.id.widget_next_prayer_name, nextName.uppercase())
                setTextViewText(
                    R.id.widget_next_prayer_time,
                    if (nextTime.isNotEmpty()) "($nextTime)" else ""
                )
                setTextViewText(
                    R.id.widget_remaining_time,
                    if (remaining.isNotEmpty()) "Kalan: $remaining" else ""
                )

                setTextViewText(R.id.widget_vakit_imsak, imsak)
                setTextViewText(R.id.widget_vakit_gunes, gunes)
                setTextViewText(R.id.widget_vakit_ogle, ogle)
                setTextViewText(R.id.widget_vakit_ikindi, ikindi)
                setTextViewText(R.id.widget_vakit_aksam, aksam)
                setTextViewText(R.id.widget_vakit_yatsi, yatsi)

                // Widget'a tıklanınca uygulamayı aç
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
