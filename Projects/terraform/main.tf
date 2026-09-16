locals {
  tags = {
    project   = "warden"
    env       = "lab"
    lifecycle = "temporary"
    managed   = "terraform"
  }
}

resource "azurerm_resource_group" "warden" {
  name     = "rg-warden-lab-aue"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "warden" {
  name                = "vnet-warden"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.warden.location
  resource_group_name = azurerm_resource_group.warden.name
  tags                = local.tags
}

resource "azurerm_subnet" "core" {
  name                 = "snet-core"
  resource_group_name  = azurerm_resource_group.warden.name
  virtual_network_name = azurerm_virtual_network.warden.name
  address_prefixes     = ["10.10.1.0/24"]

  # Lab trade-off: explicit legacy/default outbound access is enabled so
  # Windows activation, updates and AMA can reach public Azure endpoints
  # without paying for a NAT Gateway.
  default_outbound_access_enabled = true
}

resource "azurerm_network_security_group" "core" {
  name                = "nsg-warden-core"
  location            = azurerm_resource_group.warden.location
  resource_group_name = azurerm_resource_group.warden.name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "core" {
  subnet_id                 = azurerm_subnet.core.id
  network_security_group_id = azurerm_network_security_group.core.id
}

resource "azurerm_network_interface" "dc01" {
  name                = "nic-warden-dc01"
  location            = azurerm_resource_group.warden.location
  resource_group_name = azurerm_resource_group.warden.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.core.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.1.4"
  }

  tags = local.tags
}

resource "azurerm_network_interface" "cl01" {
  name                = "nic-warden-cl01"
  location            = azurerm_resource_group.warden.location
  resource_group_name = azurerm_resource_group.warden.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.core.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

resource "random_password" "vm_admin" {
  length           = 24
  special          = true
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  override_special = "!@#$%*-_"
}

resource "azurerm_windows_virtual_machine" "dc01" {
  name                = "vm-warden-dc01"
  computer_name       = "WARDEN-DC01"
  location            = azurerm_resource_group.warden.location
  resource_group_name = azurerm_resource_group.warden.name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.vm_admin.result

  network_interface_ids = [
    azurerm_network_interface.dc01.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  tags = local.tags
}

resource "azurerm_windows_virtual_machine" "cl01" {
  name                = "vm-warden-cl01"
  computer_name       = "WARDEN-CL01"
  location            = azurerm_resource_group.warden.location
  resource_group_name = azurerm_resource_group.warden.name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = random_password.vm_admin.result

  # Windows 11 in Azure requires Trusted Launch capabilities.
  secure_boot_enabled = true
  vtpm_enabled        = true

  network_interface_ids = [
    azurerm_network_interface.cl01.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = var.client_image_sku
    version   = "latest"
  }

  tags = local.tags
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "dc01" {
  virtual_machine_id    = azurerm_windows_virtual_machine.dc01.id
  location              = azurerm_resource_group.warden.location
  enabled               = true
  daily_recurrence_time = var.shutdown_time
  timezone              = "AUS Eastern Standard Time"

  notification_settings {
    enabled = false
  }

  tags = local.tags
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "cl01" {
  virtual_machine_id    = azurerm_windows_virtual_machine.cl01.id
  location              = azurerm_resource_group.warden.location
  enabled               = true
  daily_recurrence_time = var.shutdown_time
  timezone              = "AUS Eastern Standard Time"

  notification_settings {
    enabled = false
  }

  tags = local.tags
}

resource "azurerm_log_analytics_workspace" "warden" {
  name                = "law-warden"
  location            = azurerm_resource_group.warden.location
  resource_group_name = azurerm_resource_group.warden.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}