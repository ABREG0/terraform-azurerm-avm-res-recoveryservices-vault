variable "site_recovery_plan" {
  type = object({
    name = string
    recovery_vault_id = string
    source_recovery_fabric_id = string
    target_recovery_fabric_id = string
    shutdown_recovery_group = optional(object({
      pre_action = optional(object({
        name = string
        type = string
        fail_over_directions = string
        fail_over_types = string
        fabric_location = string
      }), null)
      post_action = optional(object({
        name = string
        type = string
        fail_over_directions = string
        fail_over_types = string
        fabric_location = string
      }), null)
    }), null)
    failover_recovery_group = optional(object({
      pre_action = optional(object({
        name = string
        type = string
        fail_over_directions = string
        fail_over_types = string
        fabric_location = string
      }), null)
      post_action = optional(object({
        name = string
        type = string
        fail_over_directions = string
        fail_over_types = string
        fabric_location = string
      }), null)
    }), null)
    boot_recovery_group = optional(object({
      pre_action = optional(object({
        name = string
        type = string
        fail_over_directions = string
        fail_over_types = string
        fabric_location = string
      }), null)
      post_action = optional(object({
        name = string
        type = string
        fail_over_directions = string
        fail_over_types = string
        fabric_location = string
      }), null)
    }), null)
    azure_to_azure_settings = optional(object({
      primary_recovery_zones = optional(object({
        primary_zone = string
        recovery_zone = string
      }), null)
      primary_recovery_edge = optional(object({
        primary_edge_zone = string
        recovery_edge_zone = string
      }), null)
    }), null)
    replicated_protected_items = list(string)
  })
  default = null
}
