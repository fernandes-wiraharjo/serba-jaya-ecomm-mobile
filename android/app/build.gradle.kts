import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Flutter passes each --dart-define-from-file entry as a Base64 string.
val mapsAndroidApiKey = providers.gradleProperty("dart-defines").orNull.orEmpty()
    .split(",")
    .filter { it.isNotEmpty() }
    .mapNotNull { item ->
        runCatching { String(Base64.getDecoder().decode(item), Charsets.UTF_8) }.getOrNull()
    }
    .lastOrNull { it.startsWith("GOOGLE_MAPS_ANDROID_API_KEY=") }
    ?.substringAfter("=")?.trim()
    ?.takeIf { it.matches(Regex("^AIza[A-Za-z0-9_-]{35}$")) }
    .orEmpty()

android {
    namespace = "id.serbajaya.ecommerce"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "id.serbajaya.ecommerce"
        manifestPlaceholders["mapsApiKey"] = mapsAndroidApiKey
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "Serba Jaya DEV")
        }
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "Serba Jaya STG")
        }
        create("prod") {
            dimension = "environment"
            resValue("string", "app_name", "Serba Jaya")
        }
    }
}

flutter {
    source = "../.."
}
