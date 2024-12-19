resource "azurerm_redis_cache" "redis" {
  capacity            = 0
  family              = "C"
  location            = azurerm_resource_group.main.location
  name                = "aw40-demohub-redis"
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "Basic"
}