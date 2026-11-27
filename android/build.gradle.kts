allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    val enforceCompileSdk = {
        if (plugins.hasPlugin("com.android.library")) {
            extensions.findByType(com.android.build.gradle.LibraryExtension::class.java)?.apply {
                if ((compileSdk ?: 0) < 36) {
                    compileSdk = 36
                }
            }
        }
    }
    if (state.executed) {
        enforceCompileSdk()
    } else {
        afterEvaluate { enforceCompileSdk() }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    if (project.name != "app") {
        project.afterEvaluate {
            plugins.withId("com.android.library") {
                val androidExt = extensions.findByName("android") ?: return@withId
                val getCompileSdk = androidExt.javaClass.methods.firstOrNull {
                    it.name == "getCompileSdk" && it.parameterCount == 0
                }
                val currentSdk = (getCompileSdk?.invoke(androidExt) as? Int) ?: 0
                if (currentSdk < 36) {
                    val setCompileSdk = androidExt.javaClass.methods.firstOrNull {
                        it.name == "setCompileSdk" &&
                            it.parameterCount == 1 &&
                            (it.parameterTypes[0] == Int::class.java ||
                                it.parameterTypes[0] == java.lang.Integer::class.java)
                    }
                    setCompileSdk?.invoke(androidExt, 36)
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
