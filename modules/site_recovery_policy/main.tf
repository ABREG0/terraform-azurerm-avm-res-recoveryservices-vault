
resource "azurerm_site_recovery_replication_policy" "this" {
  name                                                 = var.site_recovery_policy.name
  resource_group_name  = var.site_recovery_policy.resource_group_name
  recovery_vault_name  = var.site_recovery_policy.recovery_vault_name
  recovery_point_retention_in_minutes                  = var.site_recovery_policy.recovery_point_retention_in_minutes
  application_consistent_snapshot_frequency_in_minutes = var.site_recovery_policy.application_consistent_snapshot_frequency_in_minutes
}