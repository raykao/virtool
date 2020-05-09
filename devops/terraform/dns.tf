
resource azurerm_private_dns_zone "virtool" {
  name                = "virtool.ca"
  resource_group_name = azurerm_resource_group.virtool.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "test"
  resource_group_name   = azurerm_resource_group.virtool.name
  private_dns_zone_name = azurerm_private_dns_zone.virtool.name
  virtual_network_id    = azurerm_virtual_network.virtool.id
  registration_enabled  = true
}

resource azurerm_private_dns_a_record "web" {
  name                = "web"
  zone_name           = azurerm_private_dns_zone.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  ttl                 = 300
  records             = [azurerm_lb.web.private_ip_address]
}

resource azurerm_private_dns_a_record "api" {
  name                = "api"
  zone_name           = azurerm_private_dns_zone.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  ttl                 = 300
  records             = [azurerm_lb.api.private_ip_address]
}

resource azurerm_private_dns_a_record "job" {
  name                = "job"
  zone_name           = azurerm_private_dns_zone.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  ttl                 = 300
  records             = [azurerm_lb.job.private_ip_address]
}