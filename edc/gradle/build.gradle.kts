/*
 * This file was generated by the Gradle 'init' task.
 *
 * This is a general purpose Gradle build.
 * Learn more about Gradle by exploring our samples at https://docs.gradle.org/8.0.2/samples
 */

plugins {
    `java-library`
    id("application")
    id("com.github.johnrengelman.shadow") version "7.1.2"
}

val edcGroupId: String by project
val edcVersion: String by project
val postgresqlGroupId: String by project
val postgresqlVersion: String by project

dependencies {
    implementation("$edcGroupId:runtime-metamodel:$edcVersion")

    implementation("$edcGroupId:control-plane-core:$edcVersion")
    implementation("$edcGroupId:control-plane-api:$edcVersion")
    implementation("$edcGroupId:control-plane-api-client:$edcVersion")

    implementation("$edcGroupId:api-observability:$edcVersion")

    implementation("$edcGroupId:configuration-filesystem:$edcVersion")
    implementation("$edcGroupId:vault-filesystem:$edcVersion")
    implementation("$edcGroupId:iam-mock:$edcVersion")

    implementation("$edcGroupId:auth-tokenbased:$edcVersion")
    implementation("$edcGroupId:management-api:$edcVersion")

    implementation("$edcGroupId:dsp:$edcVersion")

    implementation("$edcGroupId:data-plane-aws-s3:$edcVersion")
    implementation("$edcGroupId:data-plane-azure-storage:$edcVersion")
    implementation("$edcGroupId:data-plane-http:$edcVersion")

    implementation("$edcGroupId:data-plane-core:$edcVersion")
    implementation("$edcGroupId:data-plane-api:$edcVersion")

    implementation("$edcGroupId:data-plane-selector-core:$edcVersion")
    implementation("$edcGroupId:data-plane-selector-client:$edcVersion")
    implementation("$edcGroupId:data-plane-selector-api:$edcVersion")

    implementation("$edcGroupId:transfer-data-plane:$edcVersion")

    implementation("$edcGroupId:asset-index-sql:$edcVersion")
    implementation("$edcGroupId:policy-definition-store-sql:$edcVersion")
    implementation("$edcGroupId:contract-definition-store-sql:$edcVersion")
    implementation("$edcGroupId:contract-negotiation-store-sql:$edcVersion")
    implementation("$edcGroupId:transfer-process-store-sql:$edcVersion")

    implementation("$edcGroupId:sql-pool-apache-commons:$edcVersion")
    implementation("$edcGroupId:transaction-local:$edcVersion")
    implementation("$edcGroupId:transaction-datasource-spi:$edcVersion")
    implementation("$postgresqlGroupId:postgresql:$postgresqlVersion")

    implementation("$edcGroupId:self-description-api:$edcVersion")

    implementation(project(":edc-extensions:federated-catalog"))
    implementation(project(":edc-extensions:healthcheck"))
}

application {
    mainClass.set("org.eclipse.edc.boot.system.runtime.BaseRuntime")
}

tasks.withType<com.github.jengelman.gradle.plugins.shadow.tasks.ShadowJar> {
    exclude("**/pom.properties", "**/pom.xm")
    mergeServiceFiles()
    archiveFileName.set("connector.jar")
}
