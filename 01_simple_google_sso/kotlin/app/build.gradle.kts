plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
}

if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
} else {
    logger.warn("google-services.json no encontrado en app/. La app sincroniza, pero Firebase no funcionará hasta agregarlo.")
}

android {
    namespace = "com.example.authorscollection"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.authorscollection"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        vectorDrawables {
            useSupportLibrary = true
        }

        buildConfigField(
            "String",
            "GOOGLE_WEB_CLIENT_ID_PLACEHOLDER",
            "\"YOUR_WEB_CLIENT_ID.apps.googleusercontent.com\""
        )
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    val composeUiVersion = "1.7.8"
    val material3Version = "1.3.1"
    val lifecycleVersion = "2.8.7"
    val navigationVersion = "2.8.6"
    val credentialsVersion = "1.3.0"
    val firebaseBomVersion = "34.7.0"
    val googleIdVersion = "1.1.1"
    val coilVersion = "2.7.0"

    implementation("androidx.core:core-ktx:1.15.0")
    implementation("androidx.activity:activity-compose:1.10.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:$lifecycleVersion")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:$lifecycleVersion")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:$lifecycleVersion")
    implementation("androidx.navigation:navigation-compose:$navigationVersion")

    implementation("androidx.compose.ui:ui:$composeUiVersion")
    implementation("androidx.compose.ui:ui-tooling-preview:$composeUiVersion")
    implementation("androidx.compose.material3:material3:$material3Version")
    implementation("androidx.compose.material:material-icons-extended:$composeUiVersion")

    implementation("com.google.android.material:material:1.13.0")
    implementation("androidx.credentials:credentials:$credentialsVersion")
    implementation("androidx.credentials:credentials-play-services-auth:$credentialsVersion")
    implementation("com.google.android.libraries.identity.googleid:googleid:$googleIdVersion")

    implementation(platform("com.google.firebase:firebase-bom:$firebaseBomVersion"))
    implementation("com.google.firebase:firebase-auth")

    implementation("io.coil-kt:coil-compose:$coilVersion")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.9.0")

    debugImplementation("androidx.compose.ui:ui-tooling:$composeUiVersion")
    debugImplementation("androidx.compose.ui:ui-test-manifest:$composeUiVersion")
}

