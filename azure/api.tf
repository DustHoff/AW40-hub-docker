resource "random_string" "api_key" {
  length  = 64
  special = false
}

resource "azurerm_container_app" "api" {
  depends_on = [azurerm_container_registry_task_schedule_run_now.start-api-build]
  container_app_environment_id = azurerm_container_app_environment.container-env.id
  name                         = "aw40-demohub-api-ca"
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.containerapps.id]
  }

  ingress {
    target_port                = 8000
    allow_insecure_connections = false
    external_enabled           = true
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  registry {
    server   = azurerm_container_registry.registry.login_server
    identity = azurerm_user_assigned_identity.containerapps.id
  }

  template {
    min_replicas = 1
    max_replicas = 1
    container {
      cpu    = 0.25
      image  = "${azurerm_container_registry.registry.login_server}/api:latest"
      memory = "0.5Gi"
      name   = "api"
      command = ["uvicorn", "--reload", "api.main:app", "--root-path", "api"]
      env {
        name  = "API_ALLOW_ORIGINS"
        value = "*.aw40.lmis.de"
      }
      env {
        name  = "API_KEY_DIAGNOSTICS"
        value = random_string.api_key.result
      }
      env {
        name  = "API_KEY_ASSETS"
        value = random_string.api_key.result
      }
      env {
        name  = "MONGO_HOST"
        value = "${azurerm_cosmosdb_account.cosmosdb.name}.mongo.cosmos.azure.com"
      }
      env {
        name  = "MONGO_PORT"
        value = "10255"
      }
      env {
        name  = "MONGO_PARAM"
        value = "?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@aw40-cosmos@"
      }
      env {
        name  = "MONGO_USERNAME"
        value = azurerm_cosmosdb_account.cosmosdb.name
      }
      env {
        name  = "MONGO_PASSWORD"
        value = azurerm_cosmosdb_account.cosmosdb.primary_key
      }
      env {
        name  = "MONGO_DB"
        value = azurerm_cosmosdb_mongo_database.mongodb.name
      }
      env {
        name  = "REDIS_HOST"
        value = azurerm_redis_cache.redis.hostname
      }
      env {
        name  = "REDIS_PASSWORD"
        value = azurerm_redis_cache.redis.primary_access_key
      }
      env {
        name  = "EXCLUDE_DIAGNOSTICS_ROUTER"
        value = "false"
      }
      env {
        name  = "UVICORN_HOST"
        value = "0.0.0.0"
      }
      env {
        name  = "UVICORN_LOG_LEVEL"
        value = "debug"
      }
      env {
        name  = "KNOWLEDGE_GRAPH_URL"
        value = "https://knowledgegraph.${azurerm_dns_zone.aw40.name}"
      }
      env {
        name  = "KEYCLOAK_URL"
        value = "https://auth.${azurerm_dns_zone.aw40.name}"
      }
      env {
        name  = "NAUTILUS_URL"
        value = "https://nautilus.${azurerm_dns_zone.aw40.name}"
      }
    }
  }
  lifecycle {
    replace_triggered_by = [azurerm_container_registry_task_schedule_run_now.start-api-build.id]
  }
}

module "api_app_cert" {
  source                       = "./modules/container-app-certificate"
  cname_target                 = azurerm_container_app_environment.container-env.static_ip_address
  container_app_resource_id    = azurerm_container_app.api.id
  container_app_environment_id = azurerm_container_app_environment.container-env.id
  location                     = azurerm_resource_group.main.location
  resource_group               = azurerm_resource_group.main.name
  zone_name                    = azurerm_dns_zone.aw40.name
  name                         = "api"
  txt_verification             = azurerm_container_app.api.custom_domain_verification_id
}