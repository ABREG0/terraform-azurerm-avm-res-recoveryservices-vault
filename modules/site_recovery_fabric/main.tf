

resource "time_sleep" "wait_pre" {

  create_duration = "60s"
}
resource "azurerm_site_recovery_fabric" "this" {
  depends_on = [ time_sleep.wait_pre ]
  name                =  var.site_recovery_fabric.name #!= null ? var.site_recovery_fabric.fabric_name : "fabric-${var.site_recovery_fabric.name}"
  recovery_vault_name = var.site_recovery_fabric.vault_name
  resource_group_name = var.site_recovery_fabric.vault_resource_group_name
  location            = var.site_recovery_fabric.location
  timeouts {
    create = "60m"
    delete = "60m"
    read = "10m"
  }
}
resource "time_sleep" "wait" {
  depends_on = [azurerm_site_recovery_fabric.this]

  create_duration = "60s"
}