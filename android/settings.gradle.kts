pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            var path = properties.getProperty("flutter.sdk")
            require(path != null) { "flutter.sdk not set in local.properties" }
            // In-memory substitution only — never write back to disk.
            // If Flutter was previously at a spaced path, map it to C:\flutter.
            if (path.contains(" ")) {
                path = path.replace("D:\\program files\\flutter", "C:\\flutter")
                          .replace("D:/program files/flutter", "C:/flutter")
                          .replace("C:\\Program Files\\flutter", "C:\\flutter")
                          .replace("C:/Program Files/flutter", "C:/flutter")
            }
            path
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
