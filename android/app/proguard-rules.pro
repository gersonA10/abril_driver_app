# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Flutter Background Service
-keep class id.flutter.flutter_background_service.** { *; }
-keep class com.ryanheise.audioservice.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# SharedPreferences
-keep class androidx.preference.** { *; }

# Android Intent Plus
-keep class dev.fluttercommunity.plus.androidintent.** { *; }

# Mantener clases con @pragma('vm:entry-point')
-keep @interface io.flutter.embedding.engine.dart.DartEntrypoint
-keep @io.flutter.embedding.engine.dart.DartEntrypoint class * { *; }