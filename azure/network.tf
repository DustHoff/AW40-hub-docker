resource "azurerm_virtual_network" "vnet" {
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  name                = "aw40-demohub-vnet"
  address_space = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "container_snet" {
  name                 = "container-snet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.0.32/27"]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "mongodb_snet" {
  name                 = "mongodb-snet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.0.64/27"]
}

resource "azurerm_subnet" "mysql_snet" {
  name                 = "mysql-snet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.0.96/27"]
}