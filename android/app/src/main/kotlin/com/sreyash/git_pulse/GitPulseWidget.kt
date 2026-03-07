package com.sreyash.git_pulse

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

// R is generated under the namespace declared in build.gradle.kts
import com.sreyash.git_pulse.R

class GitPulseWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d("GitPulseWidget", "onUpdate called for ${appWidgetIds.size} widget(s)")
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int
    ) {
        try {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.git_pulse_widget)

            val todayCommits = widgetData.getInt("today_commits", -1)
            val streak = widgetData.getInt("current_streak", -1)
            val awaitingReview = widgetData.getInt("awaiting_review", -1)
            val lastRepo = widgetData.getString("last_repo", null)
            val lastUpdated = widgetData.getString("last_updated", null)

            val hasData = todayCommits >= 0

            views.setTextViewText(
                R.id.widget_today_commits,
                if (hasData) todayCommits.toString() else "—"
            )
            views.setTextViewText(
                R.id.widget_streak,
                if (hasData) streak.toString() else "—"
            )
            views.setTextViewText(
                R.id.widget_awaiting_review,
                if (hasData) awaitingReview.toString() else "—"
            )
            views.setTextViewText(
                R.id.widget_last_repo,
                lastRepo ?: "Open Git Pulse to load"
            )
            views.setTextViewText(
                R.id.widget_last_updated,
                if (lastUpdated != null) "Updated $lastUpdated" else "Tap to refresh"
            )

            if (hasData) {
                val reviewColor = if (awaitingReview > 0)
                    android.graphics.Color.parseColor("#FFF85149")
                else
                    android.graphics.Color.parseColor("#FFD29922")
                views.setTextColor(R.id.widget_awaiting_review, reviewColor)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
            Log.d("GitPulseWidget", "Widget updated. hasData=$hasData commits=$todayCommits streak=$streak")

        } catch (e: Exception) {
            Log.e("GitPulseWidget", "Error: ${e.message}", e)
            try {
                val views = RemoteViews(context.packageName, R.layout.git_pulse_widget)
                views.setTextViewText(R.id.widget_last_repo, "Open Git Pulse to load")
                views.setTextViewText(R.id.widget_today_commits, "—")
                views.setTextViewText(R.id.widget_streak, "—")
                views.setTextViewText(R.id.widget_awaiting_review, "—")
                views.setTextViewText(R.id.widget_last_updated, "Tap to refresh")
                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (fallbackEx: Exception) {
                Log.e("GitPulseWidget", "Fallback failed: ${fallbackEx.message}")
            }
        }
    }
}