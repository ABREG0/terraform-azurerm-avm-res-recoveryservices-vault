resource "time_sleep" "wait_pre" {
  create_duration = lookup(var.site_recovery_fabric.sleep_timer, "60s")
}
resource "azurerm_site_recovery_replicated_vm" "this" {
  name                                      = var.replicated_virtual_machine.name
  resource_group_name                       = var.replicated_virtual_machine.vault_resource_group_name
  recovery_vault_name                       = var.replicated_virtual_machine.vault_name
  source_recovery_fabric_name               = var.replicated_virtual_machine.source_recovery_fabric_name
  source_vm_id                              = var.replicated_virtual_machine.vm_id
  recovery_replication_policy_id            = var.replicated_virtual_machine.recovery_replication_policy_id
  source_recovery_protection_container_name = var.replicated_virtual_machine.source_recovery_protection_container_name

  target_resource_group_id                = var.replicated_virtual_machine.target_resource_group_id
  target_recovery_fabric_id               = var.replicated_virtual_machine.target_recovery_fabric_id
  target_recovery_protection_container_id = var.replicated_virtual_machine.target_recovery_protection_container_id

  dynamic "managed_disk" {
    for_each = var.replicated_virtual_machine.managed_disk
    content {
      disk_id                    = managed_disk.value.disk_id
      staging_storage_account_id = managed_disk.value.staging_storage_account_id
      target_resource_group_id   = managed_disk.value.target_resource_group_id
      target_disk_type           = managed_disk.value.target_disk_type
      target_replica_disk_type   = managed_disk.value.target_replica_disk_type
    }
  }

  dynamic "network_interface" {
    for_each = var.replicated_virtual_machine.network_interface
    content {
      source_network_interface_id   = network_interface.value.source_network_interface_id
      target_subnet_name            = network_interface.value.target_subnet_name
      recovery_public_ip_address_id = network_interface.value.recovery_public_ip_address_id
    }
  }
  timeouts {
    create = "2h"
    delete = "2h"
    read   = "20m"
  }
  lifecycle {
    ignore_changes = [managed_disk, network_interface]
  }
}
