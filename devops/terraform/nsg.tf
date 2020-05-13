# Admin
resource azurerm_network_security_group "admin" {
    name                = "adminSubnetNSG"
    location            = azurerm_resource_group.admin.location
    resource_group_name = azurerm_resource_group.admin.name

    security_rule {
        name                       = "allowSSHFromFW"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "22"
        destination_port_range     = "22"
        source_address_prefix      = join(", ", azurerm_subnet.firewall.address_prefixes)
        destination_address_prefix = join(", ", azurerm_subnet.admin.address_prefixes)
    }

    tags = {
        environment = local.environment
    }
}

resource azurerm_subnet_network_security_group_association "admin" {
    subnet_id                   = azurerm_subnet.admin.id
    network_security_group_id   = azurerm_network_security_group.admin.id
}

# Web
resource azurerm_network_security_group "web" {
    name                = "webSubnetNSG"
    location            = azurerm_resource_group.web.location
    resource_group_name = azurerm_resource_group.web.name

    security_rule {
        name                       = "allowHealthProbeFromAzureLB"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "AzureLoadBalancer"
        destination_address_prefix = join(", ", azurerm_subnet.web.address_prefixes)
    }

    security_rule {
        name                       = "allowHttpFromAzureFW"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = join(", ", azurerm_subnet.firewall.address_prefixes)
        destination_address_prefix = join(", ", azurerm_subnet.web.address_prefixes)
    }

    security_rule {
        name                       = "allowHttpsFromAzureFW"
        priority                   = 111
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = join(", ", azurerm_subnet.firewall.address_prefixes)
        destination_address_prefix = join(", ", azurerm_subnet.web.address_prefixes)
    }

    security_rule {
        name                       = "allowSSHFromAdminSubnet"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = join(", ", azurerm_subnet.admin.address_prefixes)
        destination_address_prefix = join(", ", azurerm_subnet.web.address_prefixes)
    }

    security_rule {
        name                       = "denyAllFromVNET"
        priority                   = 4000
        direction                  = "Inbound"
        protocol                   = "*"
        access                     = "Deny"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "VirtualNetwork"
    }

    tags = {
        environment = local.environment
    }
}

resource azurerm_subnet_network_security_group_association "web" {
    subnet_id                   = azurerm_subnet.web.id
    network_security_group_id   = azurerm_network_security_group.web.id
}

# Mongo
resource azurerm_network_security_group "mongo" {
    name                = "mongoSubnetNSG"
    location            = azurerm_resource_group.mongo.location
    resource_group_name = azurerm_resource_group.mongo.name

    security_rule {
        name                       = "allowMongoFromWebSubnet"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "TCP"
        source_port_range          = "*"
        destination_port_range     = "27017"
        source_address_prefix      = join(", ", azurerm_subnet.web.address_prefixes)
        destination_address_prefix = join(", ", azurerm_subnet.mongo.address_prefixes)
    }

    security_rule {
        name                       = "allowSSHFromAdminSubnet"
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "TCP"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = join(", ", azurerm_subnet.admin.address_prefixes)
        destination_address_prefix = join(", ", azurerm_subnet.mongo.address_prefixes)
    }

    security_rule {
        name                       = "denyAllFromVNET"
        priority                   = 4000
        direction                  = "Inbound"
        protocol                   = "*"
        access                     = "Deny"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "VirtualNetwork"
    }

    tags = {
        environment = local.environment
    }
}

resource azurerm_subnet_network_security_group_association "mongo" {
    subnet_id                   = azurerm_subnet.mongo.id
    network_security_group_id   = azurerm_network_security_group.mongo.id
}