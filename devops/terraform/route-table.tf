
resource azurerm_route_table "default" {
  name                          = "defaultRouteTable"
  location                      = azurerm_resource_group.virtool.location
  resource_group_name           = azurerm_resource_group.virtool.name
  disable_bgp_route_propagation = false

  route {
    name           = "defaultTraffic"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.virtool.ip_configuration[0].private_ip_address
  }

  tags = {
    environment = terraform.workspace
  }
}

resource azurerm_subnet_route_table_association "webtofw" {
  subnet_id = azurerm_subnet.web.id
  route_table_id  = azurerm_route_table.default.id
}

resource azurerm_subnet_route_table_association "apitofw" {
  subnet_id = azurerm_subnet.api.id
  route_table_id  = azurerm_route_table.default.id
}

resource azurerm_subnet_route_table_association "jobtofw" {
  subnet_id = azurerm_subnet.job.id
  route_table_id  = azurerm_route_table.default.id
}

resource azurerm_subnet_route_table_association "admintofw" {
  subnet_id = azurerm_subnet.admin.id
  route_table_id  = azurerm_route_table.default.id
}