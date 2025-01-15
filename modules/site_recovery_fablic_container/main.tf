resource "time_sleep" "wait_pre" {

  create_duration = "60s"
}
resource "azurerm_site_recovery_protection_container" "this" {
  depends_on           = [time_sleep.wait_pre]
  name                 = var.site_recovery_fabric_container.name
  resource_group_name  = var.site_recovery_fabric_container.vault_resource_group_name
  recovery_vault_name  = var.site_recovery_fabric_container.vault_name
  recovery_fabric_name = var.site_recovery_fabric_container.fabric_name
  timeouts {
    create = "60m"
    delete = "60m"
    read   = "10m"
  }
}
resource "time_sleep" "wait" {
  depends_on = [azurerm_site_recovery_protection_container.this]

  create_duration = "60s"
}