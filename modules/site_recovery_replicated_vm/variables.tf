variable "replicated_virtual_machine" {
  type = object({
    name                                      = string
    vault_name                                = string
    vault_resource_group_name                 = string
    source_recovery_fabric_name               = string
    recovery_replication_policy_id            = string
    source_recovery_protection_container_name = string
    target_resource_group_id                  = string
    target_recovery_fabric_id                 = string
    target_recovery_protection_container_id   = string

    vm_id = string
    managed_disk = map(object({
      disk_id                    = string
      staging_storage_account_id = string
      target_resource_group_id   = string
      target_disk_type           = string
      target_replica_disk_type   = string
    }))
    network_interface = map(object({
      source_network_interface_id   = string
      target_subnet_name            = string
      recovery_public_ip_address_id = string
    }))
  })
  default = null
}