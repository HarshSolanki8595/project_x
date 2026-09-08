import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ================================================================
// RELEASE SIGNING (added 2026-09-06)
// ================================================================
//
// Reads android/key.properties for the real release keystore. That
// file is already covered by android/.gitignore's "key.properties"
// / "**/*.jks" / "**/*.keystore" lines -- it and the keystore itself
// must never be committed. If key.properties doesn't exist yet (a
// fresh checkout, or before you've generated a keystore),
// releaseSigningProperties stays null and the release build type
// below quietly falls back to the debug key, same as before this
// change -- so `flutter run --release` never breaks just because a
// keystore isn't set up yet.
//
val keyPropertiesFile = rootProject.file("key.properties")
val releaseSigningProperties: Properties? = if (keyPropertiesFile.exists()) {
    Properties().apply {
        load(FileInputStream(keyPropertiesFile))
    }
} else {
    null
}

// ================================================================
// SECRETS (added 2026-09-06, app-cloning hardening)
// ================================================================
//
// Reads android/secrets.properties for the Google Maps API key --
// moved out of AndroidManifest.xml, which used to hold it as a
// plaintext literal (readable straight out of a decompiled/cloned
// APK with zero effort, and also sitting in git history). This file
// is covered by android/.gitignore's new "secrets.properties" line
// below, same protection as key.properties gets. Falls back to an
// empty string if the file is missing so a fresh checkout without
// secrets.properties still compiles (Maps just won't render until
// the file is added) instead of failing the build outright.
//
val secretsPropertiesFile = rootProject.file("secrets.properties")
val secretsProperties = Properties().apply {
    if (secretsPropertiesFile.exists()) {
        load(FileInputStream(secretsPropertiesFile))
    }
}

android {
    namespace = "com.projectx.app"
    // Hardcoded to 36 (Android 16) 2026-09-04, not left to
    // flutter.compileSdkVersion's default -- Google Play requires
    // apps to target API 36+ as of Aug 31, 2026, and this machine's
    // Android SDK already has Platform 36.1 installed (confirmed
    // via `flutter doctor -v`), so there's no reason to depend on
    // whatever a given Flutter version's default happens to be.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.projectx.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        // Hardcoded to 36 for the same reason as compileSdk above.
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Injected into AndroidManifest.xml's ${MAPS_API_KEY}
        // placeholder at build time -- see the secrets.properties
        // block above.
        manifestPlaceholders["MAPS_API_KEY"] =
            secretsProperties.getProperty("MAPS_API_KEY") ?: ""
    }

    signingConfigs {
        if (releaseSigningProperties != null) {
            create("release") {
                storeFile = file(releaseSigningProperties.getProperty("storeFile"))
                storePassword = releaseSigningProperties.getProperty("storePassword")
                keyAlias = releaseSigningProperties.getProperty("keyAlias")
                keyPassword = releaseSigningProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Signs with the real release key once android/key.properties
            // exists (see the block above); falls back to the debug key
            // otherwise so `flutter run --release`/`build apk` never
            // breaks just because you haven't generated a keystore yet.
            signingConfig = if (releaseSigningProperties != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }

            // ------------------------------------------------------
            // CODE SHRINKING + OBFUSCATION (added 2026-09-06,
            // app-cloning hardening)
            // ------------------------------------------------------
            //
            // Was off entirely before this -- a release APK/AAB built
            // without these was trivially decompilable back into
            // near-original, fully-named Kotlin/Java (the native
            // Android side; Dart code needs its own separate
            // --obfuscate flag on the `flutter build` command, see
            // build_release.bat). R8 (which Android Gradle Plugin
            // runs automatically when isMinifyEnabled is true) both
            // strips unused code and renames classes/methods to
            // meaningless short names, and isShrinkResources removes
            // unused resources from the APK/AAB. proguard-rules.pro
            // (new file, same directory as this build.gradle.kts)
            // keeps the Flutter engine, Firebase, Play Integrity/App
            // Check, and Google Maps classes R8 would otherwise be
            // tempted to strip or rename in ways that break them at
            // runtime.
            //
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
