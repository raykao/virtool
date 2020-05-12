resource azurerm_lb "web" {
  name = "lb-virtool-web"
  location = azurerm_virtual_network.virtool.location
  resource_group_name = azurerm_resource_group.virtool.name
  sku = "standard"

  frontend_ip_configuration {
    name    = "privateIP"
    subnet_id = azurerm_subnet.loadbalancers.id
    private_ip_address_allocation = "Static"
    private_ip_address  = "10.0.0.68"
  }
}

resource azurerm_lb_backend_address_pool "web" {
  resource_group_name = azurerm_resource_group.virtool.name
  loadbalancer_id     = azurerm_lb.web.id
  name                = "webBackendPool"
}

resource azurerm_lb_probe "webHttp" {
  resource_group_name = azurerm_resource_group.virtool.name
  loadbalancer_id     = azurerm_lb.web.id
  name                = "web-http-running-probe"
  port                = 80
}

resource azurerm_lb_rule "webHttp" {
  resource_group_name            = azurerm_resource_group.virtool.name
  loadbalancer_id                = azurerm_lb.web.id
  name                           = "WebHttpRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_id        = azurerm_lb_backend_address_pool.web.id
  probe_id                       = azurerm_lb_probe.webHttp.id
  frontend_ip_configuration_name = "privateIP"
}

resource azurerm_lb_rule "webHttps" {
  resource_group_name            = azurerm_resource_group.virtool.name
  loadbalancer_id                = azurerm_lb.web.id
  name                           = "WebHttpsRule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  backend_address_pool_id        = azurerm_lb_backend_address_pool.web.id
  probe_id                       = azurerm_lb_probe.webHttp.id
  frontend_ip_configuration_name = "privateIP"
}

resource azurerm_lb "api" {
  name = "lb-virtool-api"
  location = azurerm_virtual_network.virtool.location
  resource_group_name = azurerm_resource_group.virtool.name
  sku = "standard"

  frontend_ip_configuration {
    name    = "privateIP"
    subnet_id = azurerm_subnet.loadbalancers.id
    private_ip_address_allocation = "Static"
    private_ip_address  = "10.0.0.69"
  }
}

resource azurerm_lb_backend_address_pool "api" {
  resource_group_name = azurerm_resource_group.virtool.name
  loadbalancer_id     = azurerm_lb.api.id
  name                = "apiBackendPool"
}

resource azurerm_lb "job" {
  name = "lb-virtool-job"
  location = azurerm_virtual_network.virtool.location
  resource_group_name = azurerm_resource_group.virtool.name
  sku = "standard"

  frontend_ip_configuration {
    name    = "privateIP"
    subnet_id = azurerm_subnet.loadbalancers.id
    private_ip_address_allocation = "Static"
    private_ip_address  = "10.0.0.70"
  }
}

resource azurerm_lb_backend_address_pool "job" {
  resource_group_name = azurerm_resource_group.virtool.name
  loadbalancer_id     = azurerm_lb.job.id
  name                = "jobBackendPool"
}

resource azurerm_lb "admin" {
  name = "lb-admin"
  location = azurerm_virtual_network.virtool.location
  resource_group_name = azurerm_resource_group.virtool.name
  sku = "standard"

  frontend_ip_configuration {
    name    = "privateIP"
    subnet_id = azurerm_subnet.loadbalancers.id
    private_ip_address_allocation = "Static"
    private_ip_address  = "10.0.0.71"
  }
}

resource azurerm_lb_backend_address_pool "admin" {
  resource_group_name = azurerm_resource_group.virtool.name
  loadbalancer_id     = azurerm_lb.admin.id
  name                = "adminBackendPool"
}

resource azurerm_lb "mongo" {
  name = "lb-mongo"
  location = azurerm_virtual_network.virtool.location
  resource_group_name = azurerm_resource_group.virtool.name
  sku = "standard"

  frontend_ip_configuration {
    name    = "privateIP"
    subnet_id = azurerm_subnet.loadbalancers.id
    private_ip_address_allocation = "Static"
    private_ip_address  = "10.0.0.72"
  }
}

resource azurerm_lb_backend_address_pool "mongo" {
  resource_group_name = azurerm_resource_group.virtool.name
  loadbalancer_id     = azurerm_lb.mongo.id
  name                = "mongoBackendPool"
}
