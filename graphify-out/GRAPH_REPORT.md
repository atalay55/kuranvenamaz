# Graph Report - kuranvenamaz  (2026-11-26)

## Corpus Check
- 52 files · ~42,123 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 39 file(s) not represented in the graph (top: .xml 18, (none) 4, .plist 4)

## Summary
- 857 nodes · 1112 edges · 44 communities (31 shown, 13 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `af4f9587`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- settings_service.dart
- PrayerForegroundService
- qiblah_screen.dart
- surah_detail_page.dart
- settings_page.dart
- dependencies
- zikirmatik.dart
- home.dart
- httpcontroller.dart
- hadith_list_page.dart
- content_data.dart
- mainprayerclockwidget.dart
- hijricalendar.dart
- device_settings_service.dart
- app_translations.dart
- notificationservice.dart
- app_theme.dart
- utilities.dart
- widget_service.dart
- AppTranslations
- cityselect.dart
- surah_list_page.dart
- countryselect.dart
- MainActivity.kt
- country.dart
- AppDelegate.swift
- main.dart
- package:flutter/material.dart
- hadith_model.dart
- PrayerAlarmStopReceiver.kt
- ayetduahadistheme.dart
- .onReceive
- analysis_options.yaml
- Map
- namazvakitleri.dart
- PrayerNotificationDismissReceiver.kt
- kuranvenamaz
- city.dart
- LaunchImage.imageset/README.md

## God Nodes (most connected - your core abstractions)
1. `PrayerForegroundService` - 31 edges
2. `dependencies` - 16 edges
3. `PrayerAlarmReceiver` - 8 edges
4. `MainActivity` - 7 edges
5. `flutter_launcher_icons` - 5 edges
6. `Runnable` - 4 edges
7. `_HomePageState` - 4 edges
8. `_SettingsPageState` - 4 edges
9. `dev_dependencies` - 4 edges
10. `NamazWidgetProvider` - 3 edges

## Surprising Connections (you probably didn't know these)
- `PrayerForegroundService` --references--> `PowerManager`  [EXTRACTED]
  android/app/src/main/kotlin/com/fatihatalay/kuranvenamaz/PrayerForegroundService.kt →   _Bridges community 1 → community 23_
- `HadithListPage` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/pages/hadith/hadith_list_page.dart → None  _Bridges community 2 → community 9_
- `HomePage` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/pages/home.dart → None  _Bridges community 2 → community 7_
- `MainPrayerClockWidget` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/pages/prayertime/mainprayerclockwidget.dart → None  _Bridges community 2 → community 11_
- `SurahDetailPage` --inherits--> `StatefulWidget`  [EXTRACTED]
  lib/pages/quran/surah_detail_page.dart → None  _Bridges community 2 → community 3_

## Import Cycles
- None detected.

## Communities (44 total, 13 thin omitted)

### Community 0 - "settings_service.dart"
Cohesion: 0.03
Nodes (66): _askedPrompt, _calculationMethod, calculationMethodNotifier, copyDayToAll, copyDayToWeekdays, copyDayToWeekend, _dayPrayers, _daySecondPrayers (+58 more)

### Community 1 - "PrayerForegroundService"
Cohesion: 0.08
Nodes (6): LivePrayerStatus, PrayerForegroundService, Runnable, BroadcastReceiver, BroadcastReceiver, PrayerScheduleItem

### Community 2 - "qiblah_screen.dart"
Cohesion: 0.05
Nodes (34): HijriCalendarWidget, _HijriCalendarWidgetState, build, _buildBottomStatsRow, _buildCompassStack, _buildHeaderCard, _buildStatItem, _calculateQiblaBearing (+26 more)

### Community 3 - "surah_detail_page.dart"
Cohesion: 0.05
Nodes (39): arabicText, AyahDetail, englishNameTranslation, name, number, numberInSurah, numberOfAyahs, revelationType (+31 more)

### Community 4 - "settings_page.dart"
Cohesion: 0.05
Nodes (42): SettingsService, build, _buildAllGoodCard, _buildCalculationMethodCard, _buildDeviceCustomSoundBanner, _buildGenericOEMCard, _buildLanguageCard, _buildPermissionCard (+34 more)

### Community 5 - "dependencies"
Cohesion: 0.05
Nodes (37): dependencies, cupertino_icons, flutter, flutter_local_notifications, flutter_localizations, flutter_qiblah, flutter_timezone, geolocator (+29 more)

### Community 6 - "zikirmatik.dart"
Cohesion: 0.06
Nodes (34): arabic, build, _buildMainCounterButton, _buildStatsDisplay, _buildTargetSelectorRow, _buildZikirSelectorCard, count, createState (+26 more)

### Community 7 - "home.dart"
Cohesion: 0.06
Nodes (24): build, _buildAppDrawer, _buildGuideStep, _buildPermissionStep, _buildQuickAccessBar, _buildQuickTile, _checkFirstTimeNotificationPrompt, _checkOEMBatteryOptimization (+16 more)

### Community 8 - "httpcontroller.dart"
Cohesion: 0.05
Nodes (30): _adjustTimesByOffset, _apiHeaders, _bukhariCache, _cleanTime, _fetchAladhanMonth, fetchCities, fetchCountryJSONData, fetchDiyanetAyet (+22 more)

### Community 9 - "hadith_list_page.dart"
Cohesion: 0.07
Nodes (28): _apiCategories, _applyFilter, build, _copyToClipboard, createState, _currentPage, dispose, _favoriteHadithIds (+20 more)

### Community 10 - "content_data.dart"
Cohesion: 0.07
Nodes (23): arabic, ayetler, ContentData, ContentItem, dualar, english, fetchLiveAyet, fetchLiveHadis (+15 more)

### Community 11 - "mainprayerclockwidget.dart"
Cohesion: 0.05
Nodes (30): build, _buildDateNavigationBar, _buildTimeUnit, _cachedVakitler, _calculationMethod, cityName, countryName, createState (+22 more)

### Community 12 - "hijricalendar.dart"
Cohesion: 0.08
Nodes (22): build, createState, date, DiniGunItem, diniGunler, dispose, _formatHijriDate, getGregorianDate (+14 more)

### Community 13 - "device_settings_service.dart"
Cohesion: 0.08
Nodes (20): androidVersion, batteryOptimizationIgnored, _channel, checkNotificationPermissions, DeviceSettingsService, exactAlarmAllowed, getDeviceManufacturer, isFullyConfigured (+12 more)

### Community 14 - "app_translations.dart"
Cohesion: 0.09
Nodes (17): changeLocale, currentLanguageCode, currentLocaleNotifier, defaultLocale, getLocalizedCardTitle, getLocalizedCountryName, getLocalizedPrayerName, getPrayerScheduleName (+9 more)

### Community 15 - "notificationservice.dart"
Cohesion: 0.06
Nodes (24): _activeReschedule, buildSevenDaySchedulePlan, cancelAllNotifications, cancelNotification, _deviceChannel, _doReschedulePrayerNotifications, ezanChannelId, _getNotificationDetails (+16 more)

### Community 16 - "app_theme.dart"
Cohesion: 0.10
Nodes (18): AppTheme, bgBookParchment, bgDark, cardDark, cardDecoration, goldAccent, goldBookBorder, goldLight (+10 more)

### Community 17 - "utilities.dart"
Cohesion: 0.11
Nodes (15): buildVakitList, cachedTimesByDate, city, country, _fetchedTimes, getAllPrayerTimesByDate, getCityAndCountry, getNamazVakitleri (+7 more)

### Community 18 - "widget_service.dart"
Cohesion: 0.20
Nodes (5): androidWidgetProvider, _getVakitKey, iosWidgetName, updateWidgetData, WidgetService

### Community 20 - "cityselect.dart"
Cohesion: 0.13
Nodes (14): _allCities, build, cities, CitySelectPage, _CitySelectPageState, controller, country, createState (+6 more)

### Community 21 - "surah_list_page.dart"
Cohesion: 0.13
Nodes (11): build, createState, dispose, filteredSurahs, _filterSurahs, initState, lastReadBookmark, _loadBookmark (+3 more)

### Community 22 - "countryselect.dart"
Cohesion: 0.14
Nodes (10): _allCountries, build, controller, countries, CountrySelectPage, _CountrySelectPageState, createState, dispose (+2 more)

### Community 23 - "MainActivity.kt"
Cohesion: 0.07
Nodes (3): MainActivity, NamazWidgetProvider, PrayerAlarmReceiver

### Community 24 - "country.dart"
Cohesion: 0.50
Nodes (3): code, Country, name

### Community 25 - "AppDelegate.swift"
Cohesion: 0.20
Nodes (4): Flutter, flutter_local_notifications, AppDelegate, UIKit

### Community 26 - "main.dart"
Cohesion: 0.17
Nodes (5): build, initializeDateFormatting, initialLocale, isFirstRun, main

### Community 27 - "package:flutter/material.dart"
Cohesion: 0.20
Nodes (5): build, callback, error, _getVakitIcon, namazVakitleriKucuk

### Community 28 - "hadith_model.dart"
Cohesion: 0.22
Nodes (7): arabic, category, HadithItem, id, source, topic, turkish

### Community 30 - "ayetduahadistheme.dart"
Cohesion: 0.17
Nodes (8): MyApp, LocationErrorWidget, arabicText, AyetDuaHadisTheme, build, description, kaynakca, title

### Community 32 - "analysis_options.yaml"
Cohesion: 0.50
Nodes (3): include, linter, rules

### Community 34 - "namazvakitleri.dart"
Cohesion: 0.50
Nodes (3): namazSaati, NamazVakitleri, vakitIsmi

## Knowledge Gaps
- **508 isolated node(s):** `UIKit`, `Flutter`, `flutter_local_notifications`, `keyAppLocale`, `defaultLocale` (+503 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 634 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **13 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PrayerForegroundService` connect `PrayerForegroundService` to `MainActivity.kt`?**
  _High betweenness centrality (0.068) - this node is a cross-community bridge._
- **What connects `UIKit`, `Flutter`, `flutter_local_notifications` to the rest of the system?**
  _508 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `settings_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.02857142857142857 - nodes in this community are weakly interconnected._
- **Why does `SettingsService` connect `settings_page.dart` to `settings_service.dart`?**
  _High betweenness centrality (0.007) - this node is a cross-community bridge._
- **Should `PrayerForegroundService` be split into smaller, more focused modules?**
  _Cohesion score 0.07755102040816327 - nodes in this community are weakly interconnected._
- **Should `qiblah_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.04810360777058279 - nodes in this community are weakly interconnected._
- **Should `surah_detail_page.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.047619047619047616 - nodes in this community are weakly interconnected._