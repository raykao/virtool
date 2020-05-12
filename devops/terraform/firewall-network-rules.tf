resource azurerm_firewall_nat_rule_collection "virtoolWebHttp" {
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

resource azurerm_firewall_nat_rule_collection "virtoolWebHttps" {
  name                = "virtoolHTTPSInbound"
  azure_firewall_name = azurerm_firewall.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  priority            = 110
  action              = "Dnat"

  rule {
    name = "virtoolHTTPSDnat"

    source_addresses = ["*"]

    destination_addresses = [
      azurerm_public_ip.firewall-primary.ip_address
    ]

    destination_ports = [
      "443"
    ]

    protocols = [
      "TCP"
    ]

    translated_address =  azurerm_lb.web.private_ip_address

    translated_port = "443"
  }
}

resource azurerm_firewall_nat_rule_collection "adminSSH" {
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

resource azurerm_firewall_network_rule_collection "adminSSHSnat" {
  name                = "adminSSHSnat"
  azure_firewall_name = azurerm_firewall.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  priority            = 300
  action              = "Allow"

  rule {
    name = "adminSSHSnat"

    source_addresses = concat([],azurerm_subnet.admin.address_prefixes)

    destination_addresses = [
      "*"
    ]

    destination_ports = [
      "*"
    ]

    protocols = [
      "Any"
    ]
  }
}
