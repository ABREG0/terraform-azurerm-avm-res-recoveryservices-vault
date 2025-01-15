
output "resource" {
  description = "resource Id output"
  value       = azurerm_site_recovery_replicated_vm.this
}

# Module owners should include the full resource via a 'resource' output
# https://azure.github.io/Azure-Verified-Modules/specs/terraform/#id-tffr2---category-outputs---additional-terraform-outputs
output "resource_id" {
  description = "resource Id output"
  value       = azurerm_site_recovery_replicated_vm.this.id
}
