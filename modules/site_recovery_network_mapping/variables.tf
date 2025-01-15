
variable "site_recovery_network_mapping" {
  type = object({
    name                        = string
    vault_name                  = string
    vault_resource_group_name   = string
    source_recovery_fabric_name = string
    target_recovery_fabric_name = string
    source_network_id           = string
    target_network_id           = string
  })
  default = null
}
