resource azurerm_firewall_application_rule_collection "updates" {
  name                = "updateInfrastructure"
  azure_firewall_name = azurerm_firewall.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  priority            = 300
  action              = "Allow"

  rule {
    name = "updateInfraRules"

    source_addresses = concat([],azurerm_virtual_network.virtool.address_space)

    target_fqdns = [
      "azure.archive.ubuntu.com",
      "security.ubuntu.com",
      "launchpad.net",
      "ppa.launchpad.net",
      "keyserver.ubuntu.com"
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

    source_addresses = concat([],azurerm_virtual_network.virtool.address_space)

    target_fqdns = [
      "*.docker.com",
      "*.docker.io"
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

    source_addresses = concat([],azurerm_subnet.web.address_prefixes)

    target_fqdns = [
      "github.com",
      "*.github.com",
      "github-production-release-asset-2e65be.s3.amazonaws.com",
      "www.bioinformatics.babraham.ac.uk",
      "eddylab.org",
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

resource azurerm_firewall_application_rule_collection "mongo" {
  name                = "mongoRules"
  azure_firewall_name = azurerm_firewall.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  priority            = 510
  action              = "Allow"

  rule {
    name = "mongoRules"

    source_addresses = concat([],azurerm_subnet.mongo.address_prefixes)

    target_fqdns = [
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

resource azurerm_firewall_application_rule_collection "letsEncrypt" {
  name                = "letsEncryptRules"
  azure_firewall_name = azurerm_firewall.virtool.name
  resource_group_name = azurerm_resource_group.virtool.name
  priority            = 600
  action              = "Allow"

  rule {
    name = "letsEncrypt"

    source_addresses = [
      azurerm_subnet.web.address_prefixes[0]
    ]

    target_fqdns = [
      "*.letsencrypt.org"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

