resource azurerm_firewall_application_rule_collection "updates" {
  name                = "updateInfrastructure"
  azure_firewall_name = azurerm_firewall.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  priority            = 300
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

resource azurerm_firewall_application_rule_collection "docker" {
  name                = "dockerRules"
  azure_firewall_name = azurerm_firewall.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  priority            = 400
  action              = "Allow"

  rule {
    name = "dockerRules"

    source_addresses = [
      "10.0.0.0/16",
    ]

    target_fqdns = [
      "download.docker.com",
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

resource azurerm_firewall_application_rule_collection "virtool" {
  name                = "virtoolRules"
  azure_firewall_name = azurerm_firewall.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  priority            = 500
  action              = "Allow"

  rule {
    name = "virtoolRules"

    source_addresses = [
      "10.0.0.0/16",
    ]

    target_fqdns = [
      "github.com",
      "*.github.com",
      "www.bioinformatics.babraham.ac.uk",
      "eddylab.org",
      "*.mongodb.org"
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