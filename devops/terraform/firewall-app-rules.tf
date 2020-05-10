resource azurerm_firewall_application_rule_collection "updates" {
  name                = "updateInfrastructure"
  azure_firewall_name = azurerm_firewall.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  priority            = 100
  action              = "Allow"

  rule {
    name = "updateInfraRules"

    source_addresses = [
      "10.0.0.0/16",
    ]

    target_fqdns = [
      "azure.archive.ubuntu.com",
      "security.ubuntu.com"
    ]

    protocol {
      port = "443"
      type = "Https"
    }

    protocol {
      port = "80"
      type = "Http"
    }
  }
}