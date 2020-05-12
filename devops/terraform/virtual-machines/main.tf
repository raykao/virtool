data template_file "cloud-init" {
  template = file("../packer/install.sh")
}

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
  name                = "nic-${local.prefix}-virtool-${local.suffix}"
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
  name                = "vm-${local.prefix}-${local.suffix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.size
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

  custom_data = base64encode(data.template_file.cloud-init.rendered)

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}