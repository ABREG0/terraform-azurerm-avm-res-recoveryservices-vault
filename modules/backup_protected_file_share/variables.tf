variable "backup_protected_file_share" {
  type = object({
    source_storage_account_id              = string
    backup_policy_id          = string
    source_file_share_name          = string
    vault_name                = string
    vault_resource_group_name = string
    

  })
  default = null
}