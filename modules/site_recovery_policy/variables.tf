variable "site_recovery_policy" {
  type = object({
    name                                                 = string
    recovery_vault_name                                  = string
    resource_group_name                                  = string
    recovery_point_retention_in_minutes                  = number
    application_consistent_snapshot_frequency_in_minutes = number
    sleep_timer = optional(string, "60s")
  })
}
