
resource azurerm_virtual_network "virtool" {
  name = "${local.environment}-vnet-virtool"
  location = azurerm_resource_group.virtool.location
  resource_group_name = azurerm_resource_group.virtool.name
  address_space = ["10.0.0.0/16"]
}

resource azurerm_subnet "firewall" {
  name = "AzureFirewallSubnet"
  resource_group_name = azurerm_resource_group.virtool.name
  virtual_network_name = azurerm_virtual_network.virtool.name
  address_prefixes  = ["10.0.0.0/26"]
}

resource azurerm_subnet "loadbalancers" {
  name = "loadbalancers"
  resource_group_name = azurerm_resource_group.virtool.name
  virtual_network_name = azurerm_virtual_network.virtool.name
  address_prefixes  = ["10.0.0.64/26"]
}

resource azurerm_subnet "web" {
  name = "web"
  resource_group_name = azurerm_resource_group.virtool.name
  virtual_network_name = azurerm_virtual_network.virtool.name
  address_prefixes  = ["10.0.0.128/27"]
}

resource azurerm_subnet "api" {
  name = "api"
  resource_group_name = azurerm_resource_group.virtool.name
  virtual_network_name = azurerm_virtual_network.virtool.name
  address_prefixes  = ["10.0.0.160/27"]
}

resource azurerm_subnet "mongo" {
  name = "mongo"
  resource_group_name = azurerm_resource_group.virtool.name
  virtual_network_name = azurerm_virtual_network.virtool.name
  address_prefixes  = ["10.0.0.192/27"]
}

resource azurerm_subnet "job" {
  name = "job"
  resource_group_name = azurerm_resource_group.virtool.name
  virtual_network_name = azurerm_virtual_network.virtool.name
  address_prefixes  = ["10.0.1.0/24"]
}

resource azurerm_subnet "admin" {
  name = "admin"
  resource_group_name = azurerm_resource_group.virtool.name
  virtual_network_name = azurerm_virtual_network.virtool.name
  address_prefixes  = ["10.0.255.248/29"]
}