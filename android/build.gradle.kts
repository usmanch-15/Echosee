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
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.whenPluginAdded {
        if (this.javaClass.name.contains("com.android.build.gradle.LibraryPlugin") || 
            this.javaClass.name.contains("com.android.build.gradle.AppPlugin")) {
            val androidMetadata = project.extensions.findByName("android")
            if (androidMetadata != null) {
                try {
                    val namespaceMethod = androidMetadata.javaClass.getMethod("getNamespace")
                    val currentNamespace = namespaceMethod.invoke(androidMetadata)
                    if (currentNamespace == null) {
                        val setNamespace = androidMetadata.javaClass.getMethod("setNamespace", String::class.java)
                        setNamespace.invoke(androidMetadata, "com.echosee.dependency.${project.name.replace(":", ".").replace("-", ".")}")
                    }
                } catch (e: Exception) {
                    // Ignore if method not found
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
