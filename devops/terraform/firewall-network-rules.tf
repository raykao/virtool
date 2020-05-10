resource "azurerm_firewall_nat_rule_collection" "virtoolWeb" {
  name                = "virtoolHTTPInbound"
  azure_firewall_name = azurerm_firewall.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  priority            = 100
  action              = "Dnat"

  rule {
    name = "virtoolHTTPDnat"

    source_addresses = ["*"]

    destination_addresses = [
      azurerm_public_ip.firewall-primary.ip_address
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

resource "azurerm_firewall_nat_rule_collection" "adminSSH" {
  name                = "adminSSHInbound"
  azure_firewall_name = azurerm_firewall.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  priority            = 200
  action              = "Dnat"

  rule {
    name = "adminSSHDnat"

    source_addresses = ["*"]

    destination_addresses = [
      azurerm_public_ip.firewall-primary.ip_address
    ]

    destination_ports = [
      "22"
    ]

    protocols = [
      "TCP"
    ]

    translated_address =  module.virtool-admin0001.private_ip_address

    translated_port = "22"
  }
}