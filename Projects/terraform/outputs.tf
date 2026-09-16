output "resource_group_name" {
  value = azurerm_resource_group.warden.name
}

output "dc_private_ip" {
  value = azurerm_network_interface.dc01.private_ip_address
}

output "client_private_ip" {
  value = azurerm_network_interface.cl01.private_ip_address
}

output "vm_admin_username" {
  value = var.admin_username
}

output "vm_admin_password" {
  value     = random_password.vm_admin.result
  sensitive = true
}

output "log_analytics_workspace_name" {
  value = azurerm_log_analytics_workspace.warden.name
}