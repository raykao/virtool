resource "random_string" "suffix" {
  length = 4
  upper   = false
  special = false
}

locals {
  prefix = var.prefix
  suffix = random_string.suffix.result
}

resource "azurerm_network_interface" "virtool" {
  name                = "${local.prefix}-virtool-nic-${local.suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "${local.prefix}nicconfig${local.suffix}"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource azurerm_network_interface_backend_address_pool_association "virtool" {
  network_interface_id    = azurerm_network_interface.virtool.id
  ip_configuration_name   = "${local.prefix}nicconfig${local.suffix}"
  backend_address_pool_id = var.lb_backend_address_pool_id
}

resource "azurerm_linux_virtual_machine" "virtool" {
  name                = "${local.prefix}-virtool-machine-${local.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_D4s_v3"
  admin_username      = "${local.prefix}virtooladmin"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "${local.prefix}virtooladmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  network_interface_ids = [
    azurerm_network_interface.virtool.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 1024
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}