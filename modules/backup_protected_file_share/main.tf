resource "time_sleep" "wait_pre" {
  create_duration = lookup(var.backup_protected_file_share.sleep_timer, "60s")
}
resource "azurerm_backup_protected_file_share" "this" {
  resource_group_name       = var.backup_protected_file_share.vault_resource_group_name
  recovery_vault_name       = var.backup_protected_file_share.vault_name
  source_storage_account_id = var.backup_protected_file_share.source_storage_account_id
  source_file_share_name    = var.backup_protected_file_share.source_file_share_name
  backup_policy_id          = var.backup_protected_file_share.backup_policy_id
}