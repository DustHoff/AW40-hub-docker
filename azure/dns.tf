resource "azurerm_dns_zone" "aw40" {
  name                = "aw40.lmis.de"
  resource_group_name = azurerm_resource_group.main.name
}