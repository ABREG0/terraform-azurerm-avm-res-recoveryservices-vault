# Example 03 Import Run Log

Date: 2026-06-07
Scope: `examples/03-private-endpoints`
Scenario: Import an existing Recovery Services vault into the latest AzAPI-based module path
Target subscription: `subscription-guid-xxxxxxxx`

## Purpose
This file captures the full step-by-step execution of the import scenario in a more verbose form than the postmortem. It records what was done, what Terraform reported, what failed, and how the state was repaired.

## Starting Point
- The example had already been validated and applied successfully before this scenario.
- The module had been updated to use `azapi_resource` for the Recovery Services vault.
- The existing vault already existed in Azure in subscription `'subscription-guid-xxxxxxxx'`.
- The goal was to deliberately remove the vault from Terraform state and confirm that the module could recover it by import.

## Step 1: Inspect the current state
Command used:

```powershell
terraform state list
```

Observed result:
- The state still contained the vault entry under the older AzureRM address:
  - `module.recovery_services_vault.azurerm_recovery_services_vault.this`
- The state also contained the two private endpoints and the DNS zone links that support the vault.

Why this step mattered:
- Before removing anything, it was necessary to confirm the exact resource address Terraform was tracking.
- This also established the baseline for the import scenario.

## Step 2: Back up the state
Command used:

```powershell
terraform state pull > state-backup-before-rsv-import-20260607.tfstate
```

Observed result:
- The current state was saved to a local backup file.

Why this step mattered:
- Removing state entries is destructive to Terraform's view of the world, even if the Azure resource itself remains unchanged.
- A backup provides a recovery path if the scenario needs to be rolled back.

## Step 3: Remove the vault from Terraform state
Command used:

```powershell
terraform state rm module.recovery_services_vault.azurerm_recovery_services_vault.this
```

Observed result:
- Terraform reported:
  - `Removed module.recovery_services_vault.azurerm_recovery_services_vault.this`
  - `Successfully removed 1 resource instance(s).`

Why this step mattered:
- This intentionally made Terraform forget the vault so the next plan/apply would treat the Azure vault as unmanaged.
- The point of the scenario was to verify the import path for the new AzAPI resource address.

## Step 4: Run plan with the vault missing from state
Command used:

```powershell
terraform plan -no-color
```

Observed result:
- Terraform refreshed the existing resources that were still in state.
- The plan showed a new `azapi_resource` for the vault:
  - `module.recovery_services_vault.azapi_resource.this will be created`
- The plan also showed the two private endpoints would be recreated:
  - `module.recovery_services_vault.azurerm_private_endpoint.this_managed_dns_zone_groups["AzureBackup"]`
  - `module.recovery_services_vault.azurerm_private_endpoint.this_managed_dns_zone_groups["AzureSiteRecovery"]`
- The plan summary was:
  - `Plan: 3 to add, 1 to change, 2 to destroy`

Why this step mattered:
- This confirmed the expected drift after removing the vault from state.
- Terraform was correctly trying to create the vault because it no longer knew the vault already existed.
- The endpoint resources were also part of the drift because they are managed under the vault module path.

### Explicit explanation of the `2 to destroy`
The `2 to destroy` in the plan were these two resources:
- `module.recovery_services_vault.azurerm_private_endpoint.this_managed_dns_zone_groups["AzureBackup"]`
- `module.recovery_services_vault.azurerm_private_endpoint.this_managed_dns_zone_groups["AzureSiteRecovery"]`

Why Terraform planned to destroy them:
- Both private endpoints contain `private_service_connection.private_connection_resource_id` pointing to the Recovery Services vault resource ID.
- Because the vault was no longer in state, Terraform planned to create a "new" vault at the AzAPI address.
- That made the endpoint connection target become unknown at plan time, which is a ForceNew attribute on private endpoints.
- Result: Terraform planned replacement (`-/+`) for both endpoints, which appears in the summary as `2 to destroy` and corresponding adds.

How this was addressed:
- The first apply was intentionally allowed to proceed to capture the real failure mode for documentation.
- After the expected vault creation failure (`Resource already exists`), the vault was imported into AzAPI state.
- A second apply reconciled references and recreated the endpoints, ending with no remaining destroys in the final apply summary.

## Step 5: Run apply without importing the vault first
Command used:

```powershell
terraform apply -auto-approve -no-color
```

Observed result:
- Terraform started applying the plan.
- The telemetry resource updated in place.
- Both private endpoints were destroyed.
- Terraform then attempted to create the vault at the AzAPI address:
  - `module.recovery_services_vault.azapi_resource.this`
- The run failed with:

```text
Error: Resource already exists

with module.recovery_services_vault.azapi_resource.this,
on ..\..\main.tf line 11, in resource "azapi_resource" "this":
11: resource "azapi_resource" "this" {

A resource with the ID
"/subscriptions/subscription-guid-xxxxxxxx/resourceGroups/rg-example/providers/Microsoft.RecoveryServices/vaults/rsv-example"
already exists - to be managed via Terraform this resource needs to be imported into the State.
```

Why this step failed:
- Terraform had lost the vault state entry, but the Azure vault still existed.
- Because the new module uses AzAPI, Terraform attempted a create operation instead of adopting the existing resource.
- Azure rejected the create because the vault name and resource ID already existed.

Why this mattered:
- This is the exact failure mode that import is supposed to resolve.
- It proved the scenario was not a code creation problem; it was a state ownership problem.

## Step 6: Import the existing vault into the AzAPI state address
Command used:

```powershell
terraform import 'module.recovery_services_vault.azapi_resource.this' '/subscriptions/subscription-guid-xxxxxxxx/resourceGroups/rg-example/providers/Microsoft.RecoveryServices/vaults/rsv-example'
```

Observed result:
- Terraform prepared the `azapi_resource` import.
- The import completed successfully.
- Terraform reported that the resource was now in state and managed by Terraform.

Why this step mattered:
- Import is the correct recovery mechanism when an Azure resource already exists but Terraform does not own it.
- This moved state ownership from a missing entry to the new AzAPI resource address.

## Step 7: Re-run apply after import
Command used:

```powershell
terraform apply -auto-approve -no-color
```

Observed result:
- Terraform refreshed all existing resources.
- The vault was now recognized under `module.recovery_services_vault.azapi_resource.this`.
- The plan showed:
  - `Plan: 2 to add, 1 to change, 0 to destroy`
- The AzAPI vault resource updated in place.
- The two private endpoints were recreated successfully.
- Final output:

```text
Apply complete! Resources: 2 added, 1 changed, 0 destroyed.
```

Why this step mattered:
- This confirmed the import was effective.
- It also restored the private endpoints that were removed during the failed apply.
- The module is now fully managing the existing vault again, but through AzAPI.

## Issues Encountered and Fixes

### Issue 1: Terraform tried to create an existing vault
- Cause: The vault was removed from state, so Terraform no longer recognized it as managed.
- Symptom: `Error: Resource already exists`
- Fix: Import the vault into `module.recovery_services_vault.azapi_resource.this`.

### Issue 2: Private endpoints were destroyed during the failed apply
- Cause: Terraform executed part of the plan before hitting the vault creation error.
- Symptom: The two private endpoints were removed during the failed run.
- Fix: Re-run apply after the vault import so Terraform could recreate them.
- Additional note: This is why the plan had `2 to destroy` before import and then `0 to destroy` after import.

### Issue 3: State ownership was split between old AzureRM and new AzAPI behavior
- Cause: The module had moved to AzAPI, but the vault was deliberately removed from the old state path.
- Symptom: Terraform could not reconcile the live vault until imported at the new address.
- Fix: Import the live vault into the AzAPI resource address and re-apply.

## Final State
- Vault is managed by Terraform at:
  - `module.recovery_services_vault.azapi_resource.this`
- Private endpoints were recreated and are again present in Azure.
- The scenario ended with a successful apply.

## Takeaway
If an existing Recovery Services vault already exists in Azure and the state entry is missing, the module will attempt to create it and fail with `Resource already exists`. The fix is to import the live vault into the AzAPI resource address, then run apply again so Terraform can reconcile the rest of the module resources.
