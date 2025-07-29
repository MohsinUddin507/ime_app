apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'dev.flutter.flutter-gradle-plugin'

android {
    namespace "com.example.ime_app"
    compileSdkVersion 34
    ndkVersion "27.0.12077973"

    defaultConfig {
        applicationId "com.example.ime_app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}
