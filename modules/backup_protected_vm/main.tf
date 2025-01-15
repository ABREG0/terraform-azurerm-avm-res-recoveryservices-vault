resource "azurerm_backup_protected_vm" "this" {
  resource_group_name = var.backup_protected_vm.vault_resource_group_name
  recovery_vault_name = var.backup_protected_vm.vault_name
  source_vm_id        = var.backup_protected_vm.source_vm_id
  backup_policy_id    = var.backup_protected_vm.backup_policy_id
}
variable "backup_protected_vm" {
  type = object({
    source_vm_id = string
    backup_policy_id = string
    vault_name = string
    vault_resource_group_name = string
    # timeouts = map(string)

  })
  default = null
}