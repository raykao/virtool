resource azurerm_public_ip_prefix "virtool" {
  name                = "virtoolPublicIpPrefix1"
  location            = azurerm_resource_group.virtool.location
  resource_group_name = azurerm_resource_group.virtool.name

  prefix_length = 30

  tags = {
    environment = local.environment
  }
}

resource azurerm_public_ip "firewall-primary" {
  name                = "firewall-primary-pip"
  location            = azurerm_resource_group.virtool.location
  resource_group_name = azurerm_resource_group.virtool.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${local.environment}-virtool-${local.suffix}"
  public_ip_prefix_id  = azurerm_public_ip_prefix.virtool.id
}