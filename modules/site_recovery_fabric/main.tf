
resource "time_sleep" "wait_pre" {
  create_duration = try(var.site_recovery_fabric.sleep_timer, "60s")
}
resource "azurerm_site_recovery_fabric" "this" {
  name                = var.site_recovery_fabric.name 
  recovery_vault_name = var.site_recovery_fabric.vault_name
  resource_group_name = var.site_recovery_fabric.vault_resource_group_name
  location            = var.site_recovery_fabric.location
  timeouts {
    create = "60m"
    delete = "60m"
    read   = "10m"
  }
  
  depends_on          = [time_sleep.wait_pre]
}
resource "time_sleep" "wait" {
  create_duration = try(var.site_recovery_fabric.sleep_timer, "60s")

  depends_on = [azurerm_site_recovery_fabric.this]
}