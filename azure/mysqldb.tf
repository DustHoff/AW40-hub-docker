resource "random_password" "keycloak_db_password" {
  length  = 16
  special = false
}

resource "azurerm_mysql_flexible_server" "mysql-server" {
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  name                         = "aw40-demohub-mysql"
  administrator_login          = "keyclaok"
  version                      = "8.0.21"
  administrator_password       = random_password.keycloak_db_password.result
  backup_retention_days        = 1
  geo_redundant_backup_enabled = false
  sku_name                     = "B_Standard_B1ms"

  storage {
    auto_grow_enabled  = true
    io_scaling_enabled = true
    size_gb            = 20
  }

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_mysql_flexible_server_firewall_rule" "mysql-server_firewall" {
  name                = "ClientIP"
  resource_group_name = azurerm_resource_group.main.name
  server_name         = azurerm_mysql_flexible_server.mysql-server.name
  end_ip_address      = "77.21.74.237"
  start_ip_address    = "77.21.74.237"
}

resource "azurerm_private_endpoint" "database-endpoint" {
  location                      = azurerm_resource_group.main.location
  name                          = "aw40-database-pep"
  custom_network_interface_name = "aw40-database-pep-nic"
  resource_group_name           = azurerm_resource_group.main.name
  subnet_id                     = azurerm_subnet.mysql_snet.id

  private_dns_zone_group {
    name                 = "privatelink-mysql-database-azure-com"
    private_dns_zone_ids = [azurerm_private_dns_zone.database-endpoint-dns-zone.id]
  }
  private_service_connection {
    is_manual_connection           = false
    name                           = "aw40-database-pep"
    subresource_names              = ["mysqlServer"]
    private_connection_resource_id = azurerm_mysql_flexible_server.mysql-server.id
  }
  lifecycle {
    replace_triggered_by = [azurerm_subnet.mysql_snet]
  }
}

resource "azurerm_private_dns_zone" "database-endpoint-dns-zone" {
  name                = "privatelink.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "database-dnslink" {
  name                  = "database-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.database-endpoint-dns-zone.name
  resource_group_name   = azurerm_resource_group.main.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}