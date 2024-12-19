resource "azurerm_user_assigned_identity" "containerapps" {
  location            = azurerm_resource_group.main.location
  name                = "a40-demohub-container-mid"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_container_app_environment" "container-env" {
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  name                     = "aw40-demohub-cae"
  infrastructure_subnet_id = azurerm_subnet.container_snet.id

  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }

  lifecycle {
    ignore_changes = [workload_profile,infrastructure_resource_group_name]
  }
}

resource "azurerm_container_registry" "registry" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  name                = "aw40demohubacr"
  sku                 = "Basic"
}

resource "azurerm_role_assignment" "app_pull" {
  principal_id         = azurerm_user_assigned_identity.containerapps.principal_id
  scope                = azurerm_container_registry.registry.id
  role_definition_name = "AcrPull"
}

resource "azurerm_role_assignment" "build_push" {
  principal_id         = azurerm_user_assigned_identity.build.principal_id
  scope                = azurerm_container_registry.registry.id
  role_definition_name = "ACRPush"
}