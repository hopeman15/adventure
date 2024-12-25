plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.compose.compiler)

    // Quality gates
    alias(libs.plugins.detekt)
    alias(libs.plugins.kotlinter)
}

android {
    namespace = "com.hellocuriosity.adventure.android"
    compileSdk = 35
    defaultConfig {
        applicationId = "com.hellocuriosity.adventure.android"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    buildFeatures {
        compose = true
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
        }
    }

    flavorDimensions.addAll(listOf("all"))
    productFlavors {
        create("production") {
            dimension = "all"
        }
        create("staging") {
            dimension = "all"
            versionNameSuffix = "-staging"
            applicationIdSuffix = ".staging"
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    testOptions {
        unitTests.isIncludeAndroidResources = true
        unitTests.isReturnDefaultValues = true
    }

    lint {
        checkDependencies = true
        abortOnError = true
        showAll = true
        textReport = true
        xmlReport = false
        htmlReport = true
        warningsAsErrors = true
        disable += mutableSetOf(
            "GoogleAppIndexingWarning",
            "GradleDependency",
            "ObsoleteLintCustomCheck"
        )
    }
}

dependencies {
    implementation(projects.shared)
    implementation(libs.compose.ui)
    implementation(libs.compose.ui.tooling.preview)
    implementation(libs.compose.material3)
    implementation(libs.androidx.activity.compose)
    debugImplementation(libs.compose.ui.tooling)
}
