resource "azurerm_cosmosdb_account" "cosmosdb" {
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  name                 = "aw40-cosmos"
  offer_type           = "Standard"
  kind                 = "MongoDB"
  mongo_server_version = "7.0"

  capabilities {
    name = "EnableMongo"
  }

  capabilities {
    name = "EnableMongoRoleBasedAccessControl"
  }

  consistency_policy {
    consistency_level = "Strong"
  }

  geo_location {
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_mongo_database" "mongodb" {
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  name                = "mongo-cosmon"
  resource_group_name = azurerm_resource_group.main.name
  throughput          = 400
}

resource "random_password" "mongo_api_password" {
  length  = 16
  special = false
}

resource "azurerm_cosmosdb_mongo_user_definition" "api_user" {
  cosmos_mongo_database_id = azurerm_cosmosdb_mongo_database.mongodb.id
  username                 = "api"
  password                 = random_password.mongo_api_password.result
}

resource "azurerm_private_dns_zone" "mongo-endpoint-dns-zone" {
  name                = "privatelink.mongo.cosmos.azure.com"
  resource_group_name = azurerm_resource_group.main.name
}
resource "azurerm_private_endpoint" "mongo-endpoint" {
  location                      = azurerm_resource_group.main.location
  name                          = "aw40-mongo-pep"
  custom_network_interface_name = "aw40-mongo-pep-nic"
  resource_group_name           = azurerm_resource_group.main.name
  subnet_id                     = azurerm_subnet.mongodb_snet.id


  private_dns_zone_group {
    name = "privatelink-mysql-database-azure-com"
    private_dns_zone_ids = [azurerm_private_dns_zone.mongo-endpoint-dns-zone.id]
  }
  private_service_connection {
    is_manual_connection           = false
    name                           = "aw40-mongo-pep"
    subresource_names = ["MongoDB"]
    private_connection_resource_id = azurerm_cosmosdb_account.cosmosdb.id
  }
  lifecycle {
    replace_triggered_by = [azurerm_subnet.mysql_snet]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "mongo-dnslink" {
  name                  = "mongo-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.mongo-endpoint-dns-zone.name
  resource_group_name   = azurerm_resource_group.main.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}