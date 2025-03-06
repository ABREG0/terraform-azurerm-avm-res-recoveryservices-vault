
data "azurerm_subscription" "This" {
  subscription_id = "c5c1228d-b650-4f0a-97ea-1f8cfdc417c5"
}
# This ensures we have unique CAF compliant names for our resources.
# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(local.test_regions) - 1
  min = 0
}
# This allow use to randomize the name of resources
resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}
# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

resource "azurerm_resource_group" "this" {
  location = "westus3"              #local.test_regions[random_integer.region_index.result]
  name     = "rg-westus3-vault-001" #module.naming.resource_group.name_unique
}
resource "azurerm_resource_group" "primary_wus1" {
  location = "westus"
  name     = "rg-vm-westus-primary-001"
}
resource "azurerm_resource_group" "primary_wus2" {
  location = "westus2"
  name     = "rg-vm-westus2-primary-001"
}
resource "azurerm_resource_group" "primary_wus3" {
  location = "westus3"
  name     = "rg-vm-westus3-primary-001"
}
resource "azurerm_resource_group" "secondary_eus" {
  location = "eastus"
  name     = "rg-vm-secondary_eus-001"
}
resource "azurerm_resource_group" "secondary_eus2" {
  location = "eastus2"
  name     = "rg-vm-secondary_eus2-001"
}
resource "azurerm_resource_group" "secondary_cus" {
  location = "centralus"
  name     = "rg-vm-secondary_cus-001"
}
# output "network" {
#   value = "${data.azurerm_subscription.This.id}/resourceGroups/${azurerm_resource_group.primary_wus1.name}/providers/Microsoft.Network/virtualNetworks/vnet-westus"
# }
locals {
  test_regions = ["eastus", "eastus2", "westus3"] #  "westu2",
  vault_name   = "${module.naming.recovery_services_vault.slug}-${module.azure_region.location_short}-001"
}

module "regions" {
  source  = "Azure/regions/azurerm"
  version = "0.5.2" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints
}

module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "7.1.1"

  azure_region = "westus3"
}
# must be located in the same region as the VM to be backed up
resource "azurerm_storage_account" "primary_wus1" {
  name                     = "srv${azurerm_resource_group.primary_wus1.location}001"
  location                 = azurerm_resource_group.primary_wus1.location
  resource_group_name      = azurerm_resource_group.primary_wus1.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_account" "primary_wus2" {
  name                     = "srv${azurerm_resource_group.primary_wus2.location}001"
  location                 = azurerm_resource_group.primary_wus2.location
  resource_group_name      = azurerm_resource_group.primary_wus2.name
  account_tier             = "Standard"
  account_replication_type = "ZRS"
}
resource "azurerm_storage_account" "primary_wus3" {
  name                     = "srv${azurerm_resource_group.primary_wus3.location}001"
  location                 = azurerm_resource_group.primary_wus3.location
  resource_group_name      = azurerm_resource_group.primary_wus3.name
  account_tier             = "Standard"
  account_replication_type = "ZRS"
}
resource "azurerm_storage_share" "this" {
  name               = "share1"
  storage_account_id = azurerm_storage_account.primary_wus3.id
  quota              = 50
}
resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  name                = "uami-${azurerm_resource_group.this.location}-001"
  resource_group_name = azurerm_resource_group.this.name
}

module "recovery_services_vault" {

  source = "../../"

  name                                           = local.vault_name #"srv-test-vault-001"
  location                                       = azurerm_resource_group.this.location
  resource_group_name                            = azurerm_resource_group.this.name
  cross_region_restore_enabled                   = false
  alerts_for_all_job_failures_enabled            = true
  alerts_for_critical_operation_failures_enabled = true
  classic_vmware_replication_enabled             = false
  public_network_access_enabled                  = true
  storage_mode_type                              = "GeoRedundant"
  sku                                            = "RS0"
  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [azurerm_user_assigned_identity.this.id, ]
  }

  tags = {
    env   = "Prod"
    owner = "ABREG0"
    dept  = "IT"
  }

  # fabric are created in spefici 'locations' to either be a source or target of VM replications

  site_recovery_fabrics = {
    westus = {
      container_name = "con-westus-s1" #"container001"
      fabric_name    = "fab-westus-s1" #"fabric001"
      location       = "westus"        # location where the VM are or source of the replication
    }
    westus2 = {
      container_name = "con-westus2-s2" #"container001"
      fabric_name    = "fab-westus2-s2" #"fabric001"
      location       = "westus2"        # location where the VM are or source of the replication
    }
    westus3 = {
      container_name = "con-westus3-s3" #"container001"
      fabric_name    = "fab-westus3-s3" #"fabric001"
      location       = "westus3"        # location where the VM are or source of the replication
    }
    eastus = {
      container_name = "con-eastus-s1" #"container001"
      fabric_name    = "fab-eastus-s1" #"fabric001"
      location       = "eastus"        # location where you want the VMs to be replicated to
    }
    centralus = {
      container_name = "con-centralus-s2" #"container001"
      fabric_name    = "fab-centralus-s2" #"fabric001"
      location       = "centralus"        # location where you want the VMs to be replicated to
    }
    eastus2 = {
      container_name = "con-eastus2-s2" #"container001"
      fabric_name    = "fab-eastus2-s2" #"fabric001"
      location       = "eastus2"        # location where you want the VMs to be replicated to
    }
  }
  site_recovery_policies = {
    pol-westus-to-eastus-s1 = {
      name                                                 = "pol-westus-to-eastus-s1"
      recovery_point_retention_in_minutes                  = 24 * 60
      application_consistent_snapshot_frequency_in_minutes = 4 * 60
    }
    pol-westus2-to-centralus-s2 = {
      name                                                 = "pol-westus2-to-centralus-s2"
      recovery_point_retention_in_minutes                  = 24 * 60
      application_consistent_snapshot_frequency_in_minutes = 4 * 60
    }
    pol-westus3-to-eastus2-s3 = {
      name                                                 = "pol-westus3-to-eastus2-s3"
      recovery_point_retention_in_minutes                  = 24 * 60
      application_consistent_snapshot_frequency_in_minutes = 4 * 60
    }
  }
  site_recovery_network_mapping = {
    site1 = {
      name                        = "site1-network-mapping"
      source_recovery_fabric_name = "fab-westus-s1"
      target_recovery_fabric_name = "fab-eastus-s1"
      source_network_id           = "${data.azurerm_subscription.This.id}/resourceGroups/${azurerm_resource_group.primary_wus1.name}/providers/Microsoft.Network/virtualNetworks/vnet-${azurerm_resource_group.primary_wus1.location}"
      target_network_id           = "${data.azurerm_subscription.This.id}/resourceGroups/${azurerm_resource_group.secondary_eus.name}/providers/Microsoft.Network/virtualNetworks/vnet-${azurerm_resource_group.secondary_eus.location}"
    }
    site2 = {
      name                        = "site2-network-mapping"
      source_recovery_fabric_name = "fab-westus2-s2"
      target_recovery_fabric_name = "fab-centralus-s2"
      source_network_id           = "${data.azurerm_subscription.This.id}/resourceGroups/${azurerm_resource_group.primary_wus2.name}/providers/Microsoft.Network/virtualNetworks/vnet-${azurerm_resource_group.primary_wus2.location}"
      target_network_id           = "${data.azurerm_subscription.This.id}/resourceGroups/${azurerm_resource_group.secondary_cus.name}/providers/Microsoft.Network/virtualNetworks/vnet-${azurerm_resource_group.secondary_cus.location}"
    }
    site3 = {
      name                        = "site3-network-mapping"
      source_recovery_fabric_name = "fab-westus3-s3"
      target_recovery_fabric_name = "fab-eastus2-s2"
      source_network_id           = "${data.azurerm_subscription.This.id}/resourceGroups/${azurerm_resource_group.primary_wus3.name}/providers/Microsoft.Network/virtualNetworks/vnet-westus3"
      target_network_id           = "${data.azurerm_subscription.This.id}/resourceGroups/${azurerm_resource_group.secondary_eus2.name}/providers/Microsoft.Network/virtualNetworks/vnet-${azurerm_resource_group.secondary_eus2.location}"
    }
  }

  site_recovery_fabric_mapping = {
    site1-westus-to-eastus-s1 = {
      name                                      = "site1-westus-to-eastus-s1"
      recovery_source_fabric_name               = "fab-westus-s1"
      recovery_source_protection_container_name = "con-westus-s1"
      recovery_targe_protection_container_name  = "eastus"
      recovery_replication_policy_name          = "pol-westus-to-eastus-s1"
    }
    site2-westus2-to-centralus-s2 = {
      name                                      = "site2-westus2-to-centralus-s2"
      recovery_source_fabric_name               = "fab-westus2-s2"
      recovery_source_protection_container_name = "con-westus2-s2"
      recovery_targe_protection_container_name  = "centralus"
      recovery_replication_policy_name          = "pol-westus2-to-centralus-s2"
    }
    site3-westus3-to-eastus2-s3 = {
      name                                      = "site3-westus3-to-eastus2-s3"
      recovery_source_fabric_name               = "fab-westus3-s3"
      recovery_source_protection_container_name = "con-westus3-s3"
      recovery_targe_protection_container_name  = "eastus2"
      recovery_replication_policy_name          = "pol-westus3-to-eastus2-s3"
    }
  }

  site_recovery_virtual_machine = {
    # vm-01 =  {
    #   recovery_replication_policy_name            = "pol-westus-to-eastus-s1"
    #   source_recovery_fabric_name = "fab-westus-s1"
    #   source_recovery_protection_container_name = "con-westus-s1"
    #   target_resource_group_id               = azurerm_resource_group.secondary_eus.id
    #   target_recovery_fabric_name               = "eastus"
    #   target_recovery_protection_container_name = "eastus"
    #   name = azurerm_windows_virtual_machine.vm_wus1.name
    #   vm_id = azurerm_windows_virtual_machine.vm_wus1.id # nes/vm"
    #   managed_disk = {
    #     disk0 = {
    #       disk_id = data.azurerm_managed_disk.vm_wus1_osdisk.id
    #       staging_storage_account_id = azurerm_storage_account.primary_wus1.id
    #       target_resource_group_id = azurerm_resource_group.secondary_eus.id
    #       target_disk_type = "Premium_LRS"
    #       target_replica_disk_type = "Premium_LRS"
    #     }

    #   }
    #   network_interface = {
    #     nic0 = {
    #       source_network_interface_id = azurerm_network_interface.vm_wus1.id
    #       target_subnet_name = "targe-${azurerm_network_interface.vm_wus1.name}"
    #       recovery_public_ip_address_id = azurerm_public_ip.eastus1.id

    #     }
    #   }
    # }
    vm-02 = {
      recovery_replication_policy_name          = "pol-westus2-to-centralus-s2"
      source_recovery_fabric_name               = "fab-westus2-s2"
      source_recovery_protection_container_name = "con-westus2-s2"
      target_resource_group_id                  = azurerm_resource_group.secondary_cus.id
      target_recovery_fabric_name               = "centralus"
      target_recovery_protection_container_name = "centralus"
      name                                      = azurerm_windows_virtual_machine.vm_wus2.name
      vm_id                                     = azurerm_windows_virtual_machine.vm_wus2.id # nes/vm"
      managed_disk = {
        disk0 = {
          disk_id                    = data.azurerm_managed_disk.vm_wus2_osdisk.id
          staging_storage_account_id = azurerm_storage_account.primary_wus2.id
          target_resource_group_id   = azurerm_resource_group.secondary_cus.id
          target_disk_type           = "Premium_LRS"
          target_replica_disk_type   = "Premium_LRS"
        }

      }
      network_interface = {
        nic0 = {
          source_network_interface_id   = azurerm_network_interface.vm_wus2.id
          target_subnet_name            = "targe-${azurerm_network_interface.vm_wus2.name}"
          recovery_public_ip_address_id = azurerm_public_ip.centralus.id

        }
      }
    }
    # vm-03 =  {
    #     recovery_replication_policy_name            = "pol-westus3-to-eastus2-s3"
    #     source_recovery_fabric_name = "fab-westus3-s3"
    #     source_recovery_protection_container_name = "con-westus3-s3"
    #     target_resource_group_id               = azurerm_resource_group.secondary_eus2.id
    #     target_recovery_fabric_name               = "eastus2"
    #     target_recovery_protection_container_name = "eastus2"
    #     name = azurerm_windows_virtual_machine.vm_wus3.name
    #     vm_id = azurerm_windows_virtual_machine.vm_wus3.id # nes/vm"
    #     managed_disk = {
    #       disk0 = {
    #         disk_id = data.azurerm_managed_disk.vm_wus3_osdisk.id
    #         staging_storage_account_id = azurerm_storage_account.primary_wus3.id
    #         target_resource_group_id = azurerm_resource_group.secondary_eus2.id
    #         target_disk_type = "Premium_LRS"
    #         target_replica_disk_type = "Premium_LRS"
    #       }
    #     }
    #     network_interface = {
    #       nic0 = {
    #         source_network_interface_id = azurerm_network_interface.vm_wus3.id
    #         target_subnet_name = "targe-${azurerm_network_interface.vm_wus3.name}"
    #         recovery_public_ip_address_id = azurerm_public_ip.eastus2.id
    #       }
    #     }
    # }
  }

}








/*
  site_recovery_fabric_mapping = {
    name = "fabric-mappin-site3"
    key_fabric_source = "site3_source"
    key_fabric_target = "site3_target"
    recovery_replication_policy_id            = "pol-westus3-to-eastus2-003"
    policies = {
      site3 = {
        name = "pol-westus3-to-eastus2-003"
        recovery_point_retention_in_minutes = 24 * 60
        application_consistent_snapshot_frequency_in_minutes = 4 * 60
      }
    }
    fabrics =  {  
    site3_source = {
      container_name = "con-westus3-s3" #"container001"
      fabric_name = "fab-westus3-s3" #"fabric001"
      location = "westus3" # location where the VM are or source of the replication
    }
    site3_target = {
      container_name = "con-eastus2-s3" #"container001"
      fabric_name = "fab-eastus2-s3" #"fabric001"
      location = "eastus2" # location where you want the VMs to be replicated to
    }
    }
    network_mapping = {
      site3 = {
        name = "sit3-network-mapping"
        source_recovery_fabric_name = "fab-westus3-s3"
        target_recovery_fabric_name = "fab-eastus2-s3"
        source_network_id           = azurerm_virtual_network.westus3.id
        target_network_id           = azurerm_virtual_network.eastus2.id
      }
    }
  }
  */
# site_recovery_replication = {
#  site1 =  {
#     resource_groups = {
#       primary_resource_group_name = azurerm_resource_group.primary_wus2.name
#       primary_resource_group_id = azurerm_resource_group.primary_wus2.id
#       secondary_resource_group_name = azurerm_resource_group.secondary.name
#       secondary_resource_group_id = azurerm_resource_group.secondary.id
#     }
#     site_recovery_replication_policy = {
#       recovery_point_retention_in_minutes = 24 * 60
#       application_consistent_snapshot_frequency_in_minutes = 4 * 60
#       /*"pol-vm-replication-001" = {
#         name = "pol-vm-replication-001"
#         recovery_point_retention_in_minutes = 24 * 60
#         application_consistent_snapshot_frequency_in_minutes = 4 * 60
#       }
#       "pol-vm-replication-002" = {
#         name = "pol-vm-replication-002"
#         recovery_point_retention_in_minutes = 24 * 60
#         application_consistent_snapshot_frequency_in_minutes = 4 * 60
#       }*/
#     }
#     replication_policy_key_name = "pol-vm-replication-001"
#     primary_cache_storage_account = {
#       storage_account_id = azurerm_storage_account.primary_wus2.id
#       assigned_roles = ["Contributor", "Storage Blob Data Contributor"]
#       }
#     site_recovery_replicated_virtual_machine  = {
#       vm-01 =  {
#           name = azurerm_windows_virtual_machine.vm_wus2.name
#           vm_id = azurerm_windows_virtual_machine.vm_wus2.id # nes/vm"
#           managed_disk = {
#             disk0 = {
#               disk_id = data.azurerm_managed_disk.vm_wus2_osdisk.id
#               staging_storage_account_id = azurerm_storage_account.primary_wus2.id
#               target_resource_group_id = azurerm_resource_group.secondary.id
#               target_disk_type = "Premium_LRS"
#               target_replica_disk_type = "Premium_LRS"
#             }

#             /*disk1 = {
#               disk_id = azurerm_managed_disk.this.id
#               staging_storage_account_id = azurerm_storage_account.primary_wus2.id
#               target_resource_group_id = azurerm_resource_group.secondary.id
#               target_disk_type = "Premium_LRS"
#               target_replica_disk_type = "Premium_LRS"
#             }*/
#           }
#           network_interface = {
#             nic0 = {
#               source_network_interface_id = azurerm_network_interface.vm_wus2.id
#               target_subnet_name = "network2-subnet"
#               recovery_public_ip_address_id = azurerm_public_ip.secondary.id

#             }
#           }
#       }
#       vm-02 =  {
#           name = azurerm_windows_virtual_machine..vm_wus3..name
#           vm_id = azurerm_windows_virtual_machine..vm_wus3..id # nes/vm"
#           managed_disk = {
#             disk0 = {
#               disk_id = data.azurerm_managed_disk.vm_wus3_osdisk.id
#               staging_storage_account_id = azurerm_storage_account.primary_wus3.id
#               target_resource_group_id = azurerm_resource_group.secondary.id
#               target_disk_type = "Premium_LRS"
#               target_replica_disk_type = "Premium_LRS"
#             }

#             /*disk1 = {
#               disk_id = azurerm_managed_disk.this2.id
#               staging_storage_account_id = azurerm_storage_account.primary_wus3.id
#               target_resource_group_id = azurerm_resource_group.secondary.id
#               target_disk_type = "Premium_LRS"
#               target_replica_disk_type = "Premium_LRS"
#             }*/
#           }
#           network_interface = {
#             nic0 = {
#               source_network_interface_id = azurerm_network_interface..vm_wus3..id
#               target_subnet_name = "network2-subnet"
#               recovery_public_ip_address_id = azurerm_public_ip.centralus.id

#             }
#           }
#       }
#     }
#     site_recovery_fabric = {
#       primary_fabric = "fab-pri-${azurerm_resource_group.primary_wus3.location}"
#       primary_container = "con-pri-${azurerm_resource_group.primary_wus3.location}"
#       primary_region = azurerm_resource_group.primary_wus3.location # "westus2"
#       secondary_fabric = "fab-sec-${azurerm_resource_group.secondary.location}"
#       secondary_container = "con-sec-${azurerm_resource_group.secondary.location}"
#       secondary_region = azurerm_resource_group.secondary.location # "centralus"
#     }
#     site_recovery_network_mapping = {
#       name = "site1-network-mapping"
#       source_network_id = azurerm_virtual_network.primary_wus3.id
#       target_network_id = azurerm_virtual_network.secondary.id
#     }
#     site_recovery_plan = {
#       name = "plan1-site1"
#     }
#   }
# }