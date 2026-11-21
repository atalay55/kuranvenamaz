# Graph Report - kuranvenamaz  (2026-11-21)

## Corpus Check
- 51 files · ~40,405 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 38 file(s) not represented in the graph (top: .xml 17, (none) 4, .plist 4)

## Summary
- 821 nodes · 1037 edges · 36 communities (25 shown, 11 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `1592bfcc`
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
- MainActivity.kt
- country.dart
- AppDelegate.swift
- main.dart
- analysis_options.yaml
- Map
- namazvakitleri.dart
- kuranvenamaz
- city.dart
- LaunchImage.imageset/README.md

## God Nodes (most connected - your core abstractions)
1. `PrayerForegroundService` - 24 edges
2. `dependencies` - 16 edges
3. `BroadcastReceiver` - 12 edges
4. `MainActivity` - 6 edges
5. `flutter_launcher_icons` - 5 edges
6. `Runnable` - 4 edges
7. `_HomePageState` - 4 edges
8. `_SettingsPageState` - 4 edges
9. `dev_dependencies` - 4 edges
10. `NamazWidgetProvider` - 3 edges

## Surprising Connections (you probably didn't know these)
- `PrayerAlarmStopReceiver` --inherits--> `BroadcastReceiver`  [EXTRACTED]
  android/app/src/main/kotlin/com/fatihatalay/kuranvenamaz/PrayerAlarmStopReceiver.kt → android/app/src/main/kotlin/com/fatihatalay/kuranvenamaz/PrayerForegroundService.kt
- `PrayerBootReceiver` --inherits--> `BroadcastReceiver`  [EXTRACTED]
  android/app/src/main/kotlin/com/fatihatalay/kuranvenamaz/PrayerBootReceiver.kt → android/app/src/main/kotlin/com/fatihatalay/kuranvenamaz/PrayerForegroundService.kt
- `PrayerNotificationDismissReceiver` --inherits--> `BroadcastReceiver`  [EXTRACTED]
  android/app/src/main/kotlin/com/fatihatalay/kuranvenamaz/PrayerNotificationDismissReceiver.kt → android/app/src/main/kotlin/com/fatihatalay/kuranvenamaz/PrayerForegroundService.kt

## Import Cycles
- None detected.

## Communities (36 total, 11 thin omitted)

### Community 0 - "settings_service.dart"
Cohesion: 0.03
Nodes (66): _askedPrompt, _calculationMethod, calculationMethodNotifier, copyDayToAll, copyDayToWeekdays, copyDayToWeekend, _dayPrayers, _daySecondPrayers (+58 more)

### Community 1 - "PrayerForegroundService"
Cohesion: 0.07
Nodes (8): PrayerAlarmStopReceiver, PrayerBootReceiver, LivePrayerStatus, PrayerForegroundService, Runnable, BroadcastReceiver, PrayerScheduleItem, PrayerNotificationDismissReceiver

### Community 2 - "qiblah_screen.dart"
Cohesion: 0.05
Nodes (34): build, _buildBottomStatsRow, _buildCompassStack, _buildHeaderCard, _buildStatItem, _calculateQiblaBearing, _checkLocationStatus, createState (+26 more)

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
Nodes (26): _apiCategories, _applyFilter, build, _copyToClipboard, createState, _currentPage, dispose, _favoriteHadithIds (+18 more)

### Community 10 - "content_data.dart"
Cohesion: 0.07
Nodes (23): arabic, ayetler, ContentData, ContentItem, dualar, english, fetchLiveAyet, fetchLiveHadis (+15 more)

### Community 11 - "mainprayerclockwidget.dart"
Cohesion: 0.05
Nodes (30): build, _buildDateNavigationBar, _buildTimeUnit, _cachedVakitler, _calculationMethod, cityName, countryName, createState (+22 more)

### Community 12 - "hijricalendar.dart"
Cohesion: 0.07
Nodes (24): build, createState, date, DiniGunItem, diniGunler, dispose, _formatHijriDate, getGregorianDate (+16 more)

### Community 13 - "device_settings_service.dart"
Cohesion: 0.08
Nodes (20): androidVersion, batteryOptimizationIgnored, _channel, checkNotificationPermissions, DeviceSettingsService, exactAlarmAllowed, getDeviceManufacturer, isFullyConfigured (+12 more)

### Community 14 - "app_translations.dart"
Cohesion: 0.09
Nodes (17): changeLocale, currentLanguageCode, currentLocaleNotifier, defaultLocale, getLocalizedCardTitle, getLocalizedCountryName, getLocalizedPrayerName, getPrayerScheduleName (+9 more)

### Community 15 - "notificationservice.dart"
Cohesion: 0.07
Nodes (19): cancelAllNotifications, cancelNotification, ezanChannelId, _getNotificationDetails, hatirlatmaChannelId, initNotification, _instance, _isInitialized (+11 more)

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
Cohesion: 0.05
Nodes (35): build, createState, dispose, filteredSurahs, _filterSurahs, initState, lastReadBookmark, _loadBookmark (+27 more)

### Community 24 - "country.dart"
Cohesion: 0.50
Nodes (3): code, Country, name

### Community 25 - "AppDelegate.swift"
Cohesion: 0.20
Nodes (4): Flutter, flutter_local_notifications, AppDelegate, UIKit

### Community 30 - "main.dart"
Cohesion: 0.06
Nodes (25): arabic, category, HadithItem, id, source, topic, turkish, build (+17 more)

### Community 32 - "analysis_options.yaml"
Cohesion: 0.50
Nodes (3): include, linter, rules

### Community 34 - "namazvakitleri.dart"
Cohesion: 0.50
Nodes (3): namazSaati, NamazVakitleri, vakitIsmi

## Knowledge Gaps
- **503 isolated node(s):** `UIKit`, `Flutter`, `flutter_local_notifications`, `keyAppLocale`, `defaultLocale` (+498 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 625 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What connects `UIKit`, `Flutter`, `flutter_local_notifications` to the rest of the system?**
  _503 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `settings_service.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.02857142857142857 - nodes in this community are weakly interconnected._
- **Should `PrayerForegroundService` be split into smaller, more focused modules?**
  _Cohesion score 0.06558441558441558 - nodes in this community are weakly interconnected._
- **Should `qiblah_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.04810360777058279 - nodes in this community are weakly interconnected._
- **Should `surah_detail_page.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.047619047619047616 - nodes in this community are weakly interconnected._
- **Should `settings_page.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.045454545454545456 - nodes in this community are weakly interconnected._
- **Should `dependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.05263157894736842 - nodes in this community are weakly interconnected._