resource azurerm_resource_group "web" {
  name = "web-virtool-rg"
  location = azurerm_resource_group.virtool.location
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
  name = "admin-virtool-rg"
  location = azurerm_resource_group.virtool.location
}

module "virtool-admin0001" {
  source = "./virtual-machines"

  prefix = "admin"
  resource_group_name = azurerm_resource_group.admin.name
  location            = azurerm_resource_group.admin.location
  subnet_id           = azurerm_subnet.admin.id
  lb_backend_address_pool_id  = azurerm_lb_backend_address_pool.admin.id
}