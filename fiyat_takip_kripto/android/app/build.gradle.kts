plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fiyat_takip_kripto"
    compileSdk = 35

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.fiyat_takip_kripto"
        minSdk = 23  // Güncellenen minimum SDK
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
        
        // Redmi 10 için optimize edilmiş ayarlar
        multiDexEnabled = true
        
        // Bildirim ve background service için gerekli
        manifestPlaceholders["appLabel"] = "Kripto Takip"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            isMinifyEnabled = false
            isDebuggable = true
            applicationIdSuffix = ".debug"
        }
    }
    
    // Redmi 10 için ek build ayarları
    buildFeatures {
        buildConfig = true
    }
    
    packagingOptions {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring için gerekli
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // Redmi 10 ve düşük API seviyeli cihazlar için MultiDex desteği
    implementation("androidx.multidex:multidex:2.0.1")
}
