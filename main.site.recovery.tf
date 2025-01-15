
locals {
  policies = { 
    
    # for top_key, top_value in var.site_recovery_fabric_mapping.policies:
    # top_key => top_value
    # if var.site_recovery_fabric_mapping == null
  }
  fabrics = { 
    # for top_key, top_value in var.site_recovery_fabric_mapping.fabrics:
    # top_key => top_value
    # if var.site_recovery_fabric_mapping.fabrics != null
  }
  network_mapping = { 
    # for top_key, top_value in var.site_recovery_fabric_mapping.network_mapping:
    # top_key => top_value
    # if var.site_recovery_fabric_mapping.network_mapping != null
  }
  create_policies = merge(try(var.site_recovery_policies, null), try(var.site_recovery_fabric_mapping.policies, null))
  create_fabrics = merge(try(var.site_recovery_fabrics, {}), try(var.site_recovery_fabric_mapping.fabrics, {})) # local.fabrics)
  create_mapping = merge(try(var.site_recovery_network_mapping, {}), try(var.site_recovery_fabric_mapping.network_mapping, {})) # local.network_mapping)
  output_fabrics = {for top_key, top_value in merge(module.site_recovery_fabric, module.site_recovery_fabric_container): 
                      top_key => top_value["resource"] 
                      # if top_value["resource"].name == "fab-centralus-s2"
                    }
}
output "taget_container_id_westus" {
  value = module.site_recovery_fabric_container["eastus"].resource.id
}
/*

module "backup_protected_vm" {
  source = "./modules/backup_protected_vm"

  for_each = try(var.site_recovery_backup_protected_vm != null ? var.site_recovery_backup_protected_vm : {})
  backup_protected_vm = {
    source_vm_id = each.value.source_vm_id
    backup_policy_id = each.value.backup_policy_id
    vault_name = azurerm_recovery_services_vault.this.name
    vault_resource_group_name = azurerm_recovery_services_vault.this.resource_group_name
  }
}

  output "policy_id" {
    value = [for top_key, top_value in module.site_recovery_policies: 
              top_value["resource"].id 
              if top_value["resource"].name == "pol-westus2-to-centralus-s2"
            ] 
  }

  output "containers" {
    value = [for top_key, top_value in module.site_recovery_fabric_container: 
              top_value["resource"].id 
              if top_value["resource"].name == "con-westus-s1"
            ]
  }
  output "fabrics" {
    value = [for top_key, top_value in module.site_recovery_fabric: 
              top_value["resource"].id 
              if top_value["resource"].name == "fab-westus-s1"
            ]
  }
*/
  module "site_recovery_network_mapping" {

    source = "./modules/site_recovery_network_mapping"

    for_each = try(var.site_recovery_network_mapping != null ? var.site_recovery_network_mapping : {}) # local.create_mapping != null ? local.create_mapping : {}
    
    site_recovery_network_mapping = {
      name = each.value.name
      vault_name = azurerm_recovery_services_vault.this.name
      vault_resource_group_name = azurerm_recovery_services_vault.this.resource_group_name
      source_recovery_fabric_name = each.value.source_recovery_fabric_name
      target_recovery_fabric_name = each.value.target_recovery_fabric_name
      source_network_id = each.value.source_network_id
      target_network_id = each.value.target_network_id
    }    
    
    depends_on = [ module.site_recovery_fabric_container, module.site_recovery_policies ]

  }

resource "time_sleep" "wait_60_seconds_site_recovery" {
  depends_on = [azurerm_recovery_services_vault.this]

  create_duration = "60s"
}

module "site_recovery_fabric" {
  source = "./modules/site_recovery_fabric"

  for_each = try(var.site_recovery_fabrics != null ? var.site_recovery_fabrics : {}) 
  
    site_recovery_fabric = {
        name = each.value.fabric_name
        location = each.value.location
        vault_name = azurerm_recovery_services_vault.this.name
        vault_resource_group_name = azurerm_recovery_services_vault.this.resource_group_name
    }

  depends_on = [ time_sleep.wait_60_seconds_site_recovery ]

}

resource "time_sleep" "wait_60_seconds_fabric1" {
  depends_on = [module.site_recovery_fabric]

  create_duration = "60s"
}

module "site_recovery_fabric_container" {
    depends_on = [ module.site_recovery_fabric, time_sleep.wait_60_seconds_fabric1, ]
  source = "./modules/site_recovery_fabric_container"

  for_each = try(var.site_recovery_fabrics != null ? var.site_recovery_fabrics : {}) 
    site_recovery_fabric_container = {
        name = each.value.container_name
        fabric_name = each.value.fabric_name
        location = each.value.location
        vault_name = azurerm_recovery_services_vault.this.name
        vault_resource_group_name = azurerm_recovery_services_vault.this.resource_group_name

    }

}

module "site_recovery_policies" {
  source = "./modules/site_recovery_policy"

  for_each = local.create_policies != null ? local.create_policies : {}

  site_recovery_policy = {
    name                                                 = each.value.name
    resource_group_name  = azurerm_recovery_services_vault.this.resource_group_name
    recovery_vault_name  = azurerm_recovery_services_vault.this.name
    recovery_point_retention_in_minutes                  = each.value.recovery_point_retention_in_minutes #24 * 60
    application_consistent_snapshot_frequency_in_minutes = each.value.application_consistent_snapshot_frequency_in_minutes # 4 * 60

  }
}

module "site_recovery_fabric_mapping" {

  source = "./modules/site_recovery_fabric_mapping"

  for_each = try(var.site_recovery_fabrics_mapping != null ? var.site_recovery_fabrics_mapping : {}) 
  
    fabric_mapping = {
      name                                      = each.value.name
      vault_name = azurerm_recovery_services_vault.this.name
      vault_resource_group_name = azurerm_recovery_services_vault.this.resource_group_name
      recovery_source_fabric_name                      = each.value.recovery_source_fabric_name # module.site_recovery_fabric[each.value.recovery_source_fabric_name].resource.name
      recovery_source_protection_container_name = each.value.recovery_source_protection_container_name # module.site_recovery_fabric_container[each.value.recovery_source_protection_container_name].resource.name
      recovery_target_protection_container_id   = module.site_recovery_fabric_container[each.value.recovery_targe_protection_container_name].resource.id
      recovery_replication_policy_id            = module.site_recovery_policies[each.value.recovery_replication_policy_name].resource.id
    }
}
