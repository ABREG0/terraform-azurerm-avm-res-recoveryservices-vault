# Example 03 Deployment Postmortem

Date: 2026-06-07
Scope: `examples/03-private-endpoints`
Subscription: `00000000-0000-0000-0000-000000000000`

## Summary
This document captures the deployment issues encountered, why each issue had to be fixed, how each one was resolved, and the Terraform imports executed to reconcile state.

## Errors and Fixes

### 1) Transient Azure API connection reset during apply
- What happened: Terraform apply failed during an NSG create due to a transient Azure connection reset.
- Why it needed to be fixed: Apply did not fully converge, so requested resources were not all guaranteed to exist.
- How it was fixed: Re-ran `terraform apply -auto-approve -no-color` and allowed Terraform to converge idempotently.
- Outcome: Apply succeeded on retry.

### 2) Destroy process did not fully complete in one pass
- What happened: Long-running destroy left residual state/resources due to in-progress/finalization behavior.
- Why it needed to be fixed: Environment teardown was incomplete and not in a known-clean state.
- How it was fixed:
  - Checked state with `terraform state list`.
  - Verified Azure-side resource group/resource status.
  - Ran a follow-up `terraform destroy -auto-approve -no-color` cleanup pass.
- Outcome: Residual resources were removed and teardown completed.

### 3) Redeploy failed with "resource already exists" errors
- What happened: A later apply failed because several Azure resources already existed but were missing from Terraform state.
- Why it needed to be fixed: Terraform could not manage those resources without state ownership, blocking apply.
- How it was fixed:
  - Audited tracked resources using `terraform state list`.
  - Imported each pre-existing resource into state using `terraform import`.
  - Re-ran apply.
- Outcome: State and Azure inventory were reconciled; apply completed successfully.

### 4) Deprecation warning: `soft_delete_enabled`
- What happened: Provider emitted deprecation warning for `soft_delete_enabled`.
- Why it needed to be addressed: Not a runtime blocker today, but relevant for future provider major version upgrades.
- How it was handled: Left unchanged for this deployment because it was non-blocking; warning recorded.
- Outcome: No deployment impact in this run.

## Imports Performed

All imports were executed from `examples/03-private-endpoints`.

### 1) Private DNS VNet link (blob)
- Terraform address:
  - `azurerm_private_dns_zone_virtual_network_link.private_links["blob"]`
- Resource ID:
  - `/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net/virtualNetworkLinks/blob_vnet-tmxy-link`
- Why imported:
  - Resource already existed in Azure but was not present in Terraform state.

### 2) Private DNS VNet link (queue)
- Terraform address:
  - `azurerm_private_dns_zone_virtual_network_link.private_links["queue"]`
- Resource ID:
  - `/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net/virtualNetworkLinks/queue_vnet-tmxy-link`
- Why imported:
  - Resource already existed in Azure but was not present in Terraform state.

### 3) Private DNS VNet link (AzureBackup)
- Terraform address:
  - `azurerm_private_dns_zone_virtual_network_link.private_links["AzureBackup"]`
- Resource ID:
  - `/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/privateDnsZones/privatelink.usc.backup.windowsazure.com/virtualNetworkLinks/AzureBackup_vnet-tmxy-link`
- Why imported:
  - Resource already existed in Azure but was not present in Terraform state.

### 4) Private DNS VNet link (AzureSiteRecovery)
- Terraform address:
  - `azurerm_private_dns_zone_virtual_network_link.private_links["AzureSiteRecovery"]`
- Resource ID:
  - `/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.Network/privateDnsZones/privatelink.siterecovery.windowsazure.com/virtualNetworkLinks/AzureSiteRecovery_vnet-tmxy-link`
- Why imported:
  - Resource already existed in Azure but was not present in Terraform state.

### 5) Recovery Services Vault
- Terraform address:
  - `module.recovery_services_vault.azurerm_recovery_services_vault.this`
- Resource ID:
  - `/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-example/providers/Microsoft.RecoveryServices/vaults/rsv-example`
- Why imported:
  - Resource already existed in Azure but was not present in Terraform state.

## Import Method Used
1. Run `terraform state list` to identify what was already tracked.
2. For each missing Azure object, run `terraform import <address> <resource-id>`.
3. Confirm `Import successful!` for each import.
4. Run `terraform apply -auto-approve -no-color` to validate state consistency and converge.

## Final Deployment Result
- Apply status: `Apply complete! Resources: 2 added, 0 changed, 0 destroyed.`
- Subscription: `00000000-0000-0000-0000-000000000000`
- Location: `centralus`
- Resource group: `rg-example`
- Vault: `rsv-example`

## Notes for Future Runs
- If apply reports "already exists" on resources that are known to be real in Azure, reconcile Terraform state with import before retrying repeated applies.
- Treat `soft_delete_enabled` as technical debt for future AzureRM provider major upgrade planning.

## 2026-06-07 Addendum: Example 03 Apply Risk (AzAPI Subscription Context)

### What was observed
- Running `terraform plan` while Azure CLI was set to subscription `11111111-1111-1111-1111-111111111111` produced a destructive plan:
  - `Plan: 3 to add, 1 to change, 3 to destroy`
  - Included replacement of `module.recovery_services_vault.azapi_resource.this` and private endpoints.
- Running `terraform plan` after switching Azure CLI to subscription `00000000-0000-0000-0000-000000000000` produced a non-destructive plan:
  - `Plan: 0 to add, 2 to change, 0 to destroy`

### Why this happens
- In `examples/03-private-endpoints/provider.tf`:
  - `azurerm` is pinned by `subscription_id = var.subscription_id`.
  - `azapi` is declared as `provider "azapi" {}` with no explicit subscription binding.
- AzAPI therefore follows the current Azure CLI context (`az account show`), which can diverge from `var.subscription_id`.

### Risk if apply is run in mismatched context
- Unintended replacement of vault and private endpoints.
- Possible apply failures from cross-subscription resource references.
- Potential service disruption due to destroy/recreate operations.

### Safe run procedure before apply
1. Set the intended subscription explicitly:
   - `az account set --subscription 00000000-0000-0000-0000-000000000000`
2. Verify active account:
   - `az account show --query "{subscriptionId:id,name:name}" -o json`
3. Run `terraform plan -no-color` and confirm no forced replacement of:
   - `module.recovery_services_vault.azapi_resource.this`
   - `module.recovery_services_vault.azurerm_private_endpoint.this_managed_dns_zone_groups[...]`
4. Only then run apply.

### Hardening recommendation
- Pin AzAPI provider context for this example to the same subscription intent as AzureRM (to avoid CLI-context drift causing destructive plans).

## 2026-06-07 Scenario: Import an Existing RSV with AzAPI

### Goal
- Import the existing Recovery Services vault into the latest module path managed by `azapi_resource`.
- Validate the workflow after removing the vault from Terraform state.

### What was done
1. Backed up the current state with `terraform state pull`.
2. Removed the vault from state only:
   - `terraform state rm module.recovery_services_vault.azurerm_recovery_services_vault.this`
3. Ran `terraform plan` and `terraform apply` before importing the vault.
4. Imported the existing vault into the new AzAPI state address:
   - `module.recovery_services_vault.azapi_resource.this`
5. Re-ran `terraform apply` to restore the desired state.

### Error observed before import
- Terraform attempted to create the vault because it was no longer tracked in state.
- Apply failed with:
  - `Error: Resource already exists`
- The failure happened at the new AzAPI resource address because the vault already existed in Azure.

### Why this had to be fixed
- Terraform cannot create a resource that already exists in Azure unless it is imported into the correct state address.
- Without import, the module would keep failing on apply and would not own the live vault.

### How it was fixed
- Imported the live vault into:
  - `module.recovery_services_vault.azapi_resource.this`
- Then re-ran apply.

### Result after import
- Apply succeeded.
- Final result:
  - `Apply complete! Resources: 2 added, 1 changed, 0 destroyed.`
- The vault remained managed by Terraform under the AzAPI resource path.
- The two private endpoints were recreated after the failed attempt removed them during the first apply.

### Potential follow-up fix
- If this scenario is expected to repeat, consider documenting the import command alongside the example README so the next maintainer can recover state faster.
