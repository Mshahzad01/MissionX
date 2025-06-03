# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.android.** { *; }
-dontwarn io.flutter.embedding.**
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable

# GetX
-keep class com.getkeepsafe.relinker.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Hive
-keep class ** implements com.google.gson.TypeAdapterFactory
-keep class ** implements com.google.gson.JsonSerializer
-keep class ** implements com.google.gson.JsonDeserializer
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Awesome Notifications
-keep class me.carda.awesome_notifications.** { *; }
-keep class androidx.core.app.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Your Models
-keep class com.example.missionx.domain.entities.** { *; }
-keep class com.example.missionx.data.models.** { *; } 