resource "azurerm_container_app" "diagnostics" {
  depends_on = [azurerm_container_registry_task_schedule_run_now.start-diagnostics-build]
  container_app_environment_id = azurerm_container_app_environment.container-env.id
  name                         = "aw40-demohub-diagnostics-ca"
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  workload_profile_name = "Consumption"

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.containerapps.id]
  }

  registry {
    server   = azurerm_container_registry.registry.login_server
    identity = azurerm_user_assigned_identity.containerapps.id
  }

  template {
    min_replicas = 1
    max_replicas = 1
    container {
      cpu    = 2
      image  = "${azurerm_container_registry.registry.login_server}/diagnostics:latest"
      memory = "4Gi"
      name   = "diagnostics"
      command = ["celery", "-A", "diagnostics.tasks", "worker", "--loglevel=debug"]
      env {
        name  = "REDIS_HOST"
        value = azurerm_redis_cache.redis.hostname
      }
      env {
        name  = "REDIS_PASSWORD"
        value = azurerm_redis_cache.redis.primary_access_key
      }
      env {
        name  = "API_KEY_DIAGNOSTICS"
        value = random_string.api_key.result
      }
      env {
        name = "HUB_URL"
        value = "https://api.aw40.lmis.de/api/v1"
      }
      env {
        name = "KNOWLEDGE_GRAPH_URL"
        value = "https://knowledgegraph.aw40.lmis.de"
      }
      env {
        name = "TF_ENABLE_ONEDNN_OPTS"
        value = "0"
      }
    }
  }
}

module "diagnostics_app_cert" {
  source = "./modules/container-app-certificate"
  cname_target = azurerm_container_app_environment.container-env.static_ip_address
  container_app_resource_id = azurerm_container_app.diagnostics.id
  container_app_environment_id = azurerm_container_app_environment.container-env.id
  location = azurerm_resource_group.main.location
  resource_group = azurerm_resource_group.main.name
  zone_name = azurerm_dns_zone.aw40.name
  name = "diagnostics"
  txt_verification = azurerm_container_app.diagnostics.custom_domain_verification_id
}