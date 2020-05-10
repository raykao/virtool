
resource azurerm_firewall "virtool" {
  name                = "virtoolfirewall"
  location            = azurerm_resource_group.virtool.location
  resource_group_name = azurerm_resource_group.virtool.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.virtool.id
  }
}