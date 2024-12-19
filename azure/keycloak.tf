resource "azurerm_container_app" "keycloak" {
  depends_on = [azurerm_container_registry_task_schedule_run_now.start-keycloak-build]
  container_app_environment_id = azurerm_container_app_environment.container-env.id
  resource_group_name          = azurerm_resource_group.main.name
  name                         = "aw40-demohub-keycloak-ca"
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.containerapps.id]
  }

  ingress {
    target_port                = 8080
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
      cpu = 2
      image  = "${azurerm_container_registry.registry.login_server}/keycloak:latest"
      memory = "4Gi"
      name   = "keycloak"
      command = ["/opt/keycloak/bin/kc.sh", "start-dev", "--import-realm"]

      env {
        name  = "KEYCLOAK_ADMIN"
        value = "admin"
      }
      env {
        name  = "KEYCLOAK_ADMIN_PASSWORD"
        value = "password"
      }
      env {
        name  = "KC_HTTP_ENABLED"
        value = "true"
      }
      env {
        name  = "DB_VENDOR"
        value = "MYSQL"
      }
      env {
        name  = "KC_DB_URL_HOST"
        value = azurerm_mysql_flexible_server.mysql-server.fqdn
      }
      env {
        name  = "KC_DB_URL_PORT"
        value = "3306"
      }
      env {
        name  = "KC_DB_URL_DATABASE"
        value = azurerm_mysql_flexible_database.keycloak.name
      }
      env {
        name  = "KC_DB_USERNAME"
        value = azurerm_mysql_flexible_server.mysql-server.administrator_login
      }
      env {
        name  = "KC_DB_PASSWORD"
        value = azurerm_mysql_flexible_server.mysql-server.administrator_password
      }
      env {
        name  = "KC_PROXY"
        value = "edge"
      }
      env {
        name  = "KC_HOSTNAME_URL"
        value = "https://auth.aw40.lmis.de/"
      }
      env {
        name  = "KC_HOSTNAME_ADMIN_URL"
        value = "https://auth.aw40.lmis.de/"
      }
      env {
        name  = "KC_HOSTNAME_STRICT"
        value = "true"
      }
      env {
        name  = "WERKSTATT_ADMIN"
        value = "werkstatt_admin"
      }
      env {
        name  = "WERKSTATT_ADMIN_PASSWORD"
        value = "password"
      }
      env {
        name  = "WERKSTATT_ANALYST"
        value = "analyst"
      }
      env {
        name  = "WERKSTATT_ANALYST_PASSWORD"
        value = "password"
      }
      env {
        name  = "WERKSTATT_ANALYST_ROLE"
        value = "analyst"
      }
      env {
        name  = "WERKSTATT_MECHANIC"
        value = "machanic"
      }
      env {
        name  = "WERKSTATT_MECHANIC_PASSWORD"
        value = "password"
      }
      env {
        name  = "WERKSTATT_MECHANIC_ROLE"
        value = "mechanic"
      }
      env {
        name  = "FRONTEND_REDIRECT_URIS"
        value = "https://frontend.aw40.lmis.de/*"
      }
      env {
        name  = "CREATE_DEV_USER"
        value = "false"
      }
    }
  }
}

resource "azurerm_mysql_flexible_database" "keycloak" {
  depends_on = [azurerm_mysql_flexible_server_firewall_rule.mysql-server_firewall]
  name                = "keycloak"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.mysql-server.name
  charset             = "utf8mb3"
  collation           = "utf8mb3_general_ci"
}

module "keycloak_app_cert" {
  source                       = "./modules/container-app-certificate"
  cname_target                 = azurerm_container_app_environment.container-env.static_ip_address
  container_app_resource_id    = azurerm_container_app.keycloak.id
  container_app_environment_id = azurerm_container_app_environment.container-env.id
  location                     = azurerm_resource_group.main.location
  resource_group               = azurerm_resource_group.main.name
  zone_name                    = azurerm_dns_zone.aw40.name
  name                         = "auth"
  txt_verification             = azurerm_container_app.keycloak.custom_domain_verification_id
}