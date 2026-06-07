output "deployment_summary" {
  description = "Single instance deployment summary."
  value = {
    subscription_id     = var.subscription_id
    location            = azurerm_resource_group.this.location
    resource_group_name = azurerm_resource_group.this.name
    vault_name          = module.recovery_services_vault.resource.name
  }
}
