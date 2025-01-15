
resource "azurerm_site_recovery_network_mapping" "this" {
  name                                      = var.site_recovery_network_mapping.name #["name"]
  resource_group_name                       = var.site_recovery_network_mapping.vault_resource_group_name #["vault_resource_group_name"]
  recovery_vault_name                       = var.site_recovery_network_mapping.vault_name #["vault_name"]
  source_recovery_fabric_name = var.site_recovery_network_mapping.source_recovery_fabric_name #["source_recovery_fabric_name"]
  target_recovery_fabric_name = var.site_recovery_network_mapping.target_recovery_fabric_name #["target_recovery_fabric_name"]
  source_network_id           = var.site_recovery_network_mapping.source_network_id #["source_network_id"]
  target_network_id           = var.site_recovery_network_mapping.target_network_id #["target_network_id"]
  
  timeouts {
    create = "60m"
    delete = "60m"
    read = "10m"
  }
}