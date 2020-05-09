
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

resource "azurerm_firewall_nat_rule_collection" "web" {
  name                = "testcollection"
  azure_firewall_name = azurerm_firewall.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  priority            = 100
  action              = "Dnat"

  rule {
    name = "webDnat"

    source_addresses = ["*"]

    destination_addresses = [
      azurerm_public_ip.virtool.ip_address
    ]

    destination_ports = [
      "80"
    ]

    protocols = [
      "TCP"
    ]

    translated_address =  azurerm_lb.web.private_ip_address

    translated_port = "80"
  }
}