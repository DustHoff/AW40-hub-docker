resource "azurerm_container_app" "nautilus" {
  depends_on = [azurerm_container_registry_task_schedule_run_now.start-nautilus-build]
  container_app_environment_id = azurerm_container_app_environment.container-env.id
  name                         = "aw40-demohub-nautilus-ca"
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  workload_profile_name = "Consumption"

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.containerapps.id]
  }

  ingress {
    target_port                = 3000
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
      image  = "${azurerm_container_registry.registry.login_server}/nautilus:latest"
      memory = "0.5Gi"
      name   = "nautilus"
      env {
        name  = "USE_SWAGGER"
        value = "no"
      }
    }
  }
}

module "nautilus_app_cert" {
  source = "./modules/container-app-certificate"
  cname_target = azurerm_container_app_environment.container-env.static_ip_address
  container_app_resource_id = azurerm_container_app.nautilus.id
  container_app_environment_id = azurerm_container_app_environment.container-env.id
  location = azurerm_resource_group.main.location
  resource_group = azurerm_resource_group.main.name
  zone_name = azurerm_dns_zone.aw40.name
  name = "nautilus"
  txt_verification = azurerm_container_app.nautilus.custom_domain_verification_id
}