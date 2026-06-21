# =============================================================================
# outputs.tf
# Output values displayed after `terraform apply`
# =============================================================================

output "dev_resource_group_name" {
  description = "Name of the Development resource group"
  value       = azurerm_resource_group.dev.name
}

output "prod_resource_group_name" {
  description = "Name of the Production resource group"
  value       = azurerm_resource_group.prod.name
}

output "vm_public_ip" {
  description = "Public IP address of the Ubuntu VM"
  value       = azurerm_public_ip.dev.ip_address
}

output "vm_ssh_command" {
  description = "Ready-to-use SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.dev.ip_address}"
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.dev.name
}

# output "sql_server_fqdn" {
#   description = "Fully qualified domain name of the Azure SQL logical server"
#   value       = azurerm_mssql_server.dev.fully_qualified_domain_name
# }

# output "sql_database_name" {
#   description = "Name of the SQL database"
#   value       = azurerm_mssql_database.dev.name
# }
