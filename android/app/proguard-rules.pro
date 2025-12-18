############################################
# Flutter Core
############################################

# Flutter engine & embedding
-keep class io.flutter.app.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }

# Generated plugin registrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }


############################################
# App Entry Points (Keep only what is needed)
############################################

# MainActivity (Flutter entry)
-keep class com.workbench.MainActivity { *; }

# DeviceStateProvider (MethodChannel target)
-keep class com.workbench.DeviceInfoService { *; }


# Kotlin metadata (required for Kotlin reflection)
-keep class kotlin.Metadata { *; }


############################################
# Google Play Services (Location)
############################################

-keep class com.google.android.gms.location.** { *; }
-keep class com.google.android.gms.common.api.** { *; }
-dontwarn com.google.android.gms.**


############################################
# Google Play Core (Deferred Components)
############################################

-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**


############################################
# Riverpod / Annotations Safety
############################################

# Riverpod uses no reflection, safe to ignore
-dontwarn javax.annotation.**

# Keep annotations for future serializers
-keepattributes *Annotation*


############################################
# Logging Optimization (Release)
############################################

# Strip debug / verbose / info logs only
-assumenosideeffects class android.util.Log {
    public static int v(...);
    public static int d(...);
    public static int i(...);
}


############################################
# Crypto / TLS Warnings (Safe)
############################################

-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**


############################################
# Crash Reporting Support
############################################

# Preserve source info for stacktrace mapping
-keepattributes SourceFile,LineNumberTable