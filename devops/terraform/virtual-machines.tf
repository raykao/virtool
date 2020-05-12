resource azurerm_resource_group "web" {
  name = "${local.environment}-virtool-web"
  location = azurerm_virtual_network.virtool.location
}

module "virtool-web0001" {
  source = "./virtual-machines"

  prefix = "web"
  resource_group_name = azurerm_resource_group.web.name
  location            = azurerm_resource_group.web.location
  subnet_id           = azurerm_subnet.web.id
  lb_backend_address_pool_id  = azurerm_lb_backend_address_pool.web.id
}

resource azurerm_resource_group "admin" {
  name = "${local.environment}-virtool-admin"
  location = azurerm_virtual_network.virtool.location
}

module "virtool-admin0001" {
  source = "./virtual-machines"

  prefix = "admin"
  resource_group_name = azurerm_resource_group.admin.name
  location            = azurerm_resource_group.admin.location
  subnet_id           = azurerm_subnet.admin.id
  lb_backend_address_pool_id  = azurerm_lb_backend_address_pool.admin.id
}

resource azurerm_resource_group "mongo" {
  name = "${local.environment}-virtool-mongo"
  location = azurerm_virtual_network.virtool.location
}

module "virtool-mongo001" {
  source = "./virtual-machines"

  prefix = "mongo"
  resource_group_name = azurerm_resource_group.mongo.name
  location            = azurerm_resource_group.mongo.location
  subnet_id           = azurerm_subnet.mongo.id
  lb_backend_address_pool_id  = azurerm_lb_backend_address_pool.mongo.id
}
