
resource "azurerm_site_recovery_protection_container_mapping" "this" {
  name                                      = var.fabric_mapping.name
  recovery_vault_name                       = var.fabric_mapping.vault_name
  resource_group_name                       = var.fabric_mapping.vault_resource_group_name
  recovery_fabric_name                      = var.fabric_mapping.recovery_source_fabric_name
  recovery_source_protection_container_name = var.fabric_mapping.recovery_source_protection_container_name
  recovery_target_protection_container_id   = var.fabric_mapping.recovery_target_protection_container_id
  recovery_replication_policy_id            = var.fabric_mapping.recovery_replication_policy_id

  timeouts {
    create = "60m"
    delete = "60m"
    read   = "10m"
  }
}
