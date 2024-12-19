resource "azurerm_user_assigned_identity" "build" {
  location            = azurerm_resource_group.main.location
  name                = "aw40-demohub-builder-mid"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_container_registry_task" "api-build" {
  container_registry_id = azurerm_container_registry.registry.id
  name                  = "aw40-api"
  platform {
    os = "Linux"
  }
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.build.id]
  }
  file_step {
    task_file_path       = "task.yaml"
    context_path         = "https://github.com/DustHoff/AW40-hub-docker#main:api"
    context_access_token = var.github_token
  }
}

resource "azurerm_container_registry_task_schedule_run_now" "start-api-build" {
  container_registry_task_id = azurerm_container_registry_task.api-build.id
}

resource "azurerm_container_registry_task" "diagnostics-build" {
  container_registry_id = azurerm_container_registry.registry.id
  name                  = "diagnostics"
  platform {
    os = "Linux"
  }
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.build.id]
  }
  file_step {
    task_file_path       = "task.yaml"
    context_path         = "https://github.com/DustHoff/AW40-hub-docker#main:diagnostics"
    context_access_token = var.github_token
  }
}

resource "azurerm_container_registry_task_schedule_run_now" "start-diagnostics-build" {
  container_registry_task_id = azurerm_container_registry_task.diagnostics-build.id
}

resource "azurerm_container_registry_task" "frontend-build" {
  container_registry_id = azurerm_container_registry.registry.id
  name                  = "frontend"
  platform {
    os = "Linux"
  }
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.build.id]
  }
  file_step {
    values = {
      API_ADDRESS                  = "api.aw40.prod.lmis.de"
      FRONTEND_ADDRESS             = "frontend.aw40.prod.lmis.de"
      FRONTEND_PATH                = "/"
      KEYCLOAK_ADDRESS             = "auth.aw40.prod.lmis.de"
      KEYCLOAK_FRONTEND_CLIENT     = "demohub"
      KEYCLOAK_REALM               = "demohub"
      FRONTEND_LOG_LEVEL           = "warning"
      FRONTEND_REDIRECT_URI_MOBILE = "mobile"
      PROXY_DEFAULT_SCHEME         = "https"
    }
    task_file_path       = "task.yaml"
    context_path         = "https://github.com/DustHoff/AW40-hub-docker#main:frontend"
    context_access_token = var.github_token
  }
}

resource "azurerm_container_registry_task_schedule_run_now" "start-frontend-build" {
  container_registry_task_id = azurerm_container_registry_task.frontend-build.id
}

resource "azurerm_container_registry_task" "keycloak-build" {
  container_registry_id = azurerm_container_registry.registry.id
  name                  = "keycloak"
  platform {
    os = "Linux"
  }
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.build.id]
  }
  file_step {
    task_file_path       = "task.yaml"
    context_path         = "https://github.com/DustHoff/AW40-hub-docker#main:keycloak"
    context_access_token = var.github_token
  }
}

resource "azurerm_container_registry_task_schedule_run_now" "start-keycloak-build" {
  container_registry_task_id = azurerm_container_registry_task.keycloak-build.id
}

resource "azurerm_container_registry_task" "knowledgegraph-build" {
  container_registry_id = azurerm_container_registry.registry.id
  name                  = "knowledgegraph"
  platform {
    os = "Linux"
  }
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.build.id]
  }
  file_step {
    task_file_path       = "task.yaml"
    context_path         = "https://github.com/DustHoff/AW40-hub-docker#main:knowledge-graph"
    context_access_token = var.github_token
  }
}

resource "azurerm_container_registry_task_schedule_run_now" "start-knowledgegraph-build" {
  container_registry_task_id = azurerm_container_registry_task.knowledgegraph-build.id
}

resource "azurerm_container_registry_task" "nautilus-build" {
  container_registry_id = azurerm_container_registry.registry.id
  name                  = "nautilus"
  platform {
    os = "Linux"
  }
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.build.id]
  }
  file_step {
    task_file_path       = "task.yaml"
    context_path         = "https://github.com/DustHoff/AW40-hub-docker#main:nautilus"
    context_access_token = var.github_token
  }
}

resource "azurerm_container_registry_task_schedule_run_now" "start-nautilus-build" {
  container_registry_task_id = azurerm_container_registry_task.nautilus-build.id
}