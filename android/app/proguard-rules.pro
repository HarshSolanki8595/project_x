# ================================================================
# PROGUARD / R8 KEEP RULES (added 2026-09-06, app-cloning hardening)
# ================================================================
#
# Paired with isMinifyEnabled/isShrinkResources in build.gradle.kts.
# Without these keep rules, R8's aggressive shrinking/renaming can
# strip or rename classes that Firebase, Play Integrity/App Check,
# and Google Maps reach via reflection at runtime -- which doesn't
# show up as a build error, it shows up as a crash or a silent
# feature failure on a real device. These are the standard,
# widely-documented keep rules for this exact stack (Flutter +
# Firebase + App Check + Google Maps); nothing app-specific.

# ----------------------------------------------------------------
# Flutter engine + generated plugin registrant
# ----------------------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# ----------------------------------------------------------------
# Firebase (Auth, Firestore, Storage, Functions, Messaging)
# ----------------------------------------------------------------
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# ----------------------------------------------------------------
# App Check / Play Integrity (2026-09-06 addition)
# ----------------------------------------------------------------
-keep class com.google.firebase.appcheck.** { *; }
-dontwarn com.google.firebase.appcheck.**

# ----------------------------------------------------------------
# Google Play Core (Flutter's deferred-components support pulls
# this in even when deferred components aren't actually used)
# ----------------------------------------------------------------
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# ----------------------------------------------------------------
# Google Maps
# ----------------------------------------------------------------
-keep class com.google.maps.** { *; }
-keep class com.google.android.gms.maps.** { *; }

# ----------------------------------------------------------------
# General safety -- reflection-based (de)serialization used
# internally by several of the above
# ----------------------------------------------------------------
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
