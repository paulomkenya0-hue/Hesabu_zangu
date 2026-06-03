# ━━━ FLUTTER ━━━
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ━━━ HIVE ━━━
-keep class com.hivedb.** { *; }
-keepclassmembers class * extends com.hivedb.hive.HiveObject { *; }

# ━━━ GOOGLE ADS ━━━
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# ━━━ NOTIFICATIONS ━━━
-keep class com.dexterous.** { *; }

# ━━━ KOTLIN ━━━
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# ━━━ GENERAL ━━━
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-dontwarn sun.misc.**
-dontwarn java.lang.invoke.**
