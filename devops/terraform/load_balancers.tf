
resource azurerm_lb "web" {
  name = "webLoadBalancer"
  location = "canadacentral"
  resource_group_name = azurerm_resource_group.virtool.name
  sku = "standard"

  frontend_ip_configuration {
    name    = "privateIP"
    subnet_id = azurerm_subnet.loadbalancers.id
    private_ip_address_allocation = "Static"
    private_ip_address  = "10.0.0.68"
  }
}

resource "azurerm_lb_backend_address_pool" "web" {
  resource_group_name = azurerm_resource_group.virtool.name
  loadbalancer_id     = azurerm_lb.web.id
  name                = "webBackendPool"
}

resource azurerm_lb "api" {
  name = "apiLoadBalancer"
  location = "canadacentral"
  resource_group_name = azurerm_resource_group.virtool.name
  sku = "standard"

  frontend_ip_configuration {
    name    = "privateIP"
    subnet_id = azurerm_subnet.loadbalancers.id
    private_ip_address_allocation = "Static"
    private_ip_address  = "10.0.0.69"
  }
}

resource "azurerm_lb_backend_address_pool" "api" {
  resource_group_name = azurerm_resource_group.virtool.name
  loadbalancer_id     = azurerm_lb.api.id
  name                = "apiBackendPool"
}

resource azurerm_lb "job" {
  name = "jobLoadBalancer"
  location = "canadacentral"
  resource_group_name = azurerm_resource_group.virtool.name
  sku = "standard"

  frontend_ip_configuration {
    name    = "privateIP"
    subnet_id = azurerm_subnet.loadbalancers.id
    private_ip_address_allocation = "Static"
    private_ip_address  = "10.0.0.70"
  }
}

resource "azurerm_lb_backend_address_pool" "job" {
  resource_group_name = azurerm_resource_group.virtool.name
  loadbalancer_id     = azurerm_lb.job.id
  name                = "jobBackendPool"
}
