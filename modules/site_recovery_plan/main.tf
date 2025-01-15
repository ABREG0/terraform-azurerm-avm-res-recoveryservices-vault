
resource "azurerm_site_recovery_replication_recovery_plan" "this" {
  name                                                 = var.site_recovery_plan.name
  recovery_vault_id         = var.site_recovery_plan.recovery_vault_id
  source_recovery_fabric_id = var.site_recovery_plan.source_recovery_fabric_id
  target_recovery_fabric_id = var.site_recovery_plan.target_recovery_fabric_id

  shutdown_recovery_group {}
  #  {
  #   pre_action {
  #     name = var.site_recovery_plan.shutdown_recovery_group.pre_action.name # (Required) Name of the Action.
  #     type = var.site_recovery_plan.shutdown_recovery_group.pre_action.type # (Required) Type of the action detail. Possible values are AutomationRunbookActionDetails, ManualActionDetails and ScriptActionDetails.
  #     fail_over_directions = var.site_recovery_plan.shutdown_recovery_group.pre_action.fail_over_directions # (Required) Directions of fail over. Possible values are PrimaryToRecovery and RecoveryToPrimary
  #     fail_over_types = var.site_recovery_plan.shutdown_recovery_group.pre_action.fail_over_types # (Required) Types of fail over. Possible values are TestFailover, PlannedFailover and UnplannedFailover
  #     fabric_location = var.site_recovery_plan.shutdown_recovery_group.pre_action.fabric_location # (Optional) The fabric location of runbook or script. Possible values are Primary and Recovery. It must not be specified when type is ManualActionDetails.
  #   }
  #   post_action {
  #     name = var.site_recovery_plan.shutdown_recovery_group.post_action.name # (Required) Name of the Action.
  #     type = var.site_recovery_plan.shutdown_recovery_group.post_action.type # (Required) Type of the action detail. Possible values are AutomationRunbookActionDetails, ManualActionDetails and ScriptActionDetails.
  #     fail_over_directions = var.site_recovery_plan.shutdown_recovery_group.post_action.fail_over_directions # (Required) Directions of fail over. Possible values are PrimaryToRecovery and RecoveryToPrimary
  #     fail_over_types = var.site_recovery_plan.shutdown_recovery_group.post_action.fail_over_types # (Required) Types of fail over. Possible values are TestFailover, PlannedFailover and UnplannedFailover
  #     fabric_location = var.site_recovery_plan.shutdown_recovery_group.post_action.fabric_location # (Optional) The fabric location of runbook or script. Possible values are Primary and Recovery. It must not be specified when type is ManualActionDetails.
  #   }
  # }
  failover_recovery_group {}
  # {
  #   pre_action {
  #     name = var.site_recovery_plan.shutdown_recovery_group.pre_action.name # (Required) Name of the Action.
  #     type = var.site_recovery_plan.shutdown_recovery_group.pre_action.type # (Required) Type of the action detail. Possible values are AutomationRunbookActionDetails, ManualActionDetails and ScriptActionDetails.
  #     fail_over_directions = var.site_recovery_plan.shutdown_recovery_group.pre_action.fail_over_directions # (Required) Directions of fail over. Possible values are PrimaryToRecovery and RecoveryToPrimary
  #     fail_over_types = var.site_recovery_plan.shutdown_recovery_group.pre_action.fail_over_types # (Required) Types of fail over. Possible values are TestFailover, PlannedFailover and UnplannedFailover
  #     fabric_location = var.site_recovery_plan.shutdown_recovery_group.pre_action.fabric_location # (Optional) The fabric location of runbook or script. Possible values are Primary and Recovery. It must not be specified when type is ManualActionDetails.
  #   }
  #   post_action {
  #     name = var.site_recovery_plan.shutdown_recovery_group.post_action.name # (Required) Name of the Action.
  #     type = var.site_recovery_plan.shutdown_recovery_group.post_action.type # (Required) Type of the action detail. Possible values are AutomationRunbookActionDetails, ManualActionDetails and ScriptActionDetails.
  #     fail_over_directions = var.site_recovery_plan.shutdown_recovery_group.post_action.fail_over_directions # (Required) Directions of fail over. Possible values are PrimaryToRecovery and RecoveryToPrimary
  #     fail_over_types = var.site_recovery_plan.shutdown_recovery_group.post_action.fail_over_types # (Required) Types of fail over. Possible values are TestFailover, PlannedFailover and UnplannedFailover
  #     fabric_location = var.site_recovery_plan.shutdown_recovery_group.post_action.fabric_location # (Optional) The fabric location of runbook or script. Possible values are Primary and Recovery. It must not be specified when type is ManualActionDetails.
  #   }
  # }
  # boot_recovery_group {
  #   pre_action {
  #     name = var.site_recovery_plan.shutdown_recovery_group.pre_action.name # (Required) Name of the Action.
  #     type = var.site_recovery_plan.shutdown_recovery_group.pre_action.type # (Required) Type of the action detail. Possible values are AutomationRunbookActionDetails, ManualActionDetails and ScriptActionDetails.
  #     fail_over_directions = var.site_recovery_plan.shutdown_recovery_group.pre_action.fail_over_directions # (Required) Directions of fail over. Possible values are PrimaryToRecovery and RecoveryToPrimary
  #     fail_over_types = var.site_recovery_plan.shutdown_recovery_group.pre_action.fail_over_types # (Required) Types of fail over. Possible values are TestFailover, PlannedFailover and UnplannedFailover
  #     fabric_location = var.site_recovery_plan.shutdown_recovery_group.pre_action.fabric_location # (Optional) The fabric location of runbook or script. Possible values are Primary and Recovery. It must not be specified when type is ManualActionDetails.
  #   }
  #   post_action {
  #     name = var.site_recovery_plan.shutdown_recovery_group.post_action.name # (Required) Name of the Action.
  #     type = var.site_recovery_plan.shutdown_recovery_group.post_action.type # (Required) Type of the action detail. Possible values are AutomationRunbookActionDetails, ManualActionDetails and ScriptActionDetails.
  #     fail_over_directions = var.site_recovery_plan.shutdown_recovery_group.post_action.fail_over_directions # (Required) Directions of fail over. Possible values are PrimaryToRecovery and RecoveryToPrimary
  #     fail_over_types = var.site_recovery_plan.shutdown_recovery_group.post_action.fail_over_types # (Required) Types of fail over. Possible values are TestFailover, PlannedFailover and UnplannedFailover
  #     fabric_location = var.site_recovery_plan.shutdown_recovery_group.post_action.fabric_location # (Optional) The fabric location of runbook or script. Possible values are Primary and Recovery. It must not be specified when type is ManualActionDetails.
  #   }
  # }
  azure_to_azure_settings {
    primary_zone = null
    recovery_zone = null
    primary_edge_zone = null
    recovery_edge_zone = null
  }

  boot_recovery_group {
    replicated_protected_items = var.site_recovery_plan.replicated_protected_items
  }

}