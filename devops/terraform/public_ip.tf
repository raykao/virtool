resource azurerm_public_ip_prefix "virtool" {
  name                = "virtoolPublicIpPrefix1"
  location            = azurerm_resource_group.virtool.location
  resource_group_name = azurerm_resource_group.virtool.name

  prefix_length = 30

  tags = {
    environment = terraform.workspace
  }
}

resource azurerm_public_ip "virtool" {
  name                = "virtoolpip"
  location            = azurerm_resource_group.virtool.location
  resource_group_name = azurerm_resource_group.virtool.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "rkvirtool-${terraform.workspace}"
  public_ip_prefix_id  = azurerm_public_ip_prefix.virtool.id
}