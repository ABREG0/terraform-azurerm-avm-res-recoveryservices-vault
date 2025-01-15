

variable "fabric_mapping" {
  type = object({
    name                                      = string
    vault_name                                = string
    vault_resource_group_name                 = string
    recovery_source_fabric_name               = string
    recovery_source_protection_container_name = string
    recovery_target_protection_container_id   = string
    recovery_replication_policy_id            = string
    sleep_timer = optional(string, "60s")
  })
  default = null
}