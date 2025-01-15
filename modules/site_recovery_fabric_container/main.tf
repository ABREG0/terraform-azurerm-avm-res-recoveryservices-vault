
resource "time_sleep" "wait_pre" {
  create_duration = try(var.site_recovery_fabric_container.sleep_timer, "60s")
}

resource "azurerm_site_recovery_protection_container" "this" {
  name                 = var.site_recovery_fabric_container.name
  resource_group_name  = var.site_recovery_fabric_container.vault_resource_group_name
  recovery_vault_name  = var.site_recovery_fabric_container.vault_name
  recovery_fabric_name = var.site_recovery_fabric_container.fabric_name
  timeouts {
    create = "60m"
    delete = "60m"
    read   = "10m"
  }
  
  depends_on          = [time_sleep.wait_pre]
}
resource "time_sleep" "wait" {
  create_duration = try(var.site_recovery_fabric_container.sleep_timer, "60s")

  depends_on = [azurerm_site_recovery_protection_container.this]

}