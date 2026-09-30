# ═══════════════════════════════════════════════════════════════════
# REGLAS PROGUARD PARA BOOSTI POS
# ═══════════════════════════════════════════════════════════════════
#
# Este archivo define las clases que NO deben ser eliminadas ni
# ofuscadas por R8 durante el build de release.
#
# Se aplica desde `android/app/build.gradle` en el bloque buildTypes.release.
# ═══════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────
# FLUTTER CORE
# ─────────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# ─────────────────────────────────────────────────────────────────
# ISAR DATABASE (usa reflexión para serialización)
# ─────────────────────────────────────────────────────────────────
-keep class io.isar.** { *; }
-keep class io.isar.collection.** { *; }
-keep class io.isar.query.** { *; }
-keep class io.isar.link.** { *; }
-keep class io.isar.index.** { *; }
-keep class io.isar.native.** { *; }
-keep class io.isar.impl.** { *; }
# Reglas de protección para Isar DB
-keep class com.isarrealm.isar.** { *; }
-dontwarn com.isarrealm.isar.**

# Entidades generadas por Isar en tu app
-keep class * extends io.isar.collection.IsarCollection { *; }
-keep class **.*Entity { *; }
-keep class **.*EntitySchema { *; }
-keep class **.*EntityCollection { *; }

# ─────────────────────────────────────────────────────────────────
# SUPABASE
# ─────────────────────────────────────────────────────────────────
-keep class io.supabase.** { *; }
-keep class io.supabase_flutter.** { *; }
-keep class com.supabase.** { *; }

# ─────────────────────────────────────────────────────────────────
# MOBILE SCANNER (usa MethodChannel + JNI)
# ─────────────────────────────────────────────────────────────────
-keep class dev.steenbakker.mobile_scanner.** { *; }
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# ─────────────────────────────────────────────────────────────────
# IMAGE PICKER / FILE SELECTOR / IMAGE CROPPER
# ─────────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class com.yalantis.ucrop.** { *; }
-keep class com.yalantis.ucrop.**$* { *; }

# ─────────────────────────────────────────────────────────────────
# SHARED PREFERENCES / DEVICE INFO / SHARE PLUS
# ─────────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class dev.fluttercommunity.plus.device_info.** { *; }
-keep class dev.fluttercommunity.plus.share.** { *; }
-keep class dev.fluttercommunity.plus.packageinfo.** { *; }

# ─────────────────────────────────────────────────────────────────
# PERMISSION HANDLER
# ─────────────────────────────────────────────────────────────────
-keep class com.baseflow.permissionhandler.** { *; }

# ─────────────────────────────────────────────────────────────────
# CONNECTIVITY PLUS
# ─────────────────────────────────────────────────────────────────
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# ─────────────────────────────────────────────────────────────────
# WORKMANAGER (sincronización en background)
# ─────────────────────────────────────────────────────────────────
-keep class androidx.work.** { *; }
-keep class androidx.work.impl.** { *; }
-keep class **.BackgroundWorker { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker { *; }
-keep class be.tramckrijte.workmanager.** { *; }

# ─────────────────────────────────────────────────────────────────
# SENTRY
# ─────────────────────────────────────────────────────────────────
-keep class io.sentry.** { *; }
-keep class io.sentry.flutter.** { *; }
-keep class io.sentry.android.** { *; }
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ─────────────────────────────────────────────────────────────────
# SHOREBIRD (OTA code-push)
# ─────────────────────────────────────────────────────────────────
-keep class dev.shorebird.** { *; }
-keep class dev.shorebird.updater.** { *; }

# ─────────────────────────────────────────────────────────────────
# SHARED_PREFERENCES PLUGIN
# ─────────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# ─────────────────────────────────────────────────────────────────
# PLATFORM SERIAL / BLUETOOTH
# ─────────────────────────────────────────────────────────────────
-keep class com.licheedev.serialport.** { *; }
-keep class com.licheedev.serialport.**$* { *; }
-keep class com.hoho.android.usbserial.** { *; }
-keep class com.hoho.android.usbserial.**$* { *; }
-keep class com.lib.flutter_blue_plus.** { *; }
-keep class com.boskokg.flutter_blue_plus.** { *; }

# ─────────────────────────────────────────────────────────────────
# ESC POS PRINTER (Bluetooth printing)
# ─────────────────────────────────────────────────────────────────
-keep class com.dantsu.escposprinter.** { *; }
-keep class com.dantsu.escposprinter.**$* { *; }

# ─────────────────────────────────────────────────────────────────
# PATH PROVIDER / OPEN FILEX
# ─────────────────────────────────────────────────────────────────
-keep class io.flutter.plugins.pathprovider.** { *; }
-keep class com.crazecoder.openfile.** { *; }

# ─────────────────────────────────────────────────────────────────
# CHARSET CONVERTER
# ─────────────────────────────────────────────────────────────────
-keep class com.tosantechno.charset_converter.** { *; }

# ─────────────────────────────────────────────────────────────────
# DART / FLUTTER JNI
# ─────────────────────────────────────────────────────────────────
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.engine.loader.** { *; }

# ─────────────────────────────────────────────────────────────────
# REGLAS GENERALES
# ─────────────────────────────────────────────────────────────────
# Preserva annotations (necesario para GSON, JSON, etc.)
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Preserva clases con métodos nativos (JNI)
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserva clases Parcelable
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}

# Preserva clases Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Preserva enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Preserva constructores con @Keep
-keep @androidx.annotation.Keep class * {*;}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <methods>;
}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <fields>;
}
-keepclasseswithmembers class * {
    @androidx.annotation.Keep <init>(...);
}

# ─────────────────────────────────────────────────────────────────
# EXCEPCIONES (evita crashes por warnings menores de librerías)
# ─────────────────────────────────────────────────────────────────
-dontwarn io.flutter.**
-dontwarn io.isar.**
-dontwarn io.supabase.**
-dontwarn com.google.**
-dontwarn org.jetbrains.**
-dontwarn kotlin.**
-dontwarn okio.**
-dontwarn retrofit2.**
-dontwarn okhttp3.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
-dontwarn com.google.mlkit.**