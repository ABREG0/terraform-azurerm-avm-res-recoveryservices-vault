
variable "site_recovery_fabric" {
  type = object({
    name                      = string
    location                  = string
    vault_name                = string
    vault_resource_group_name = string
    sleep_timer = optional(string, "60s")

  })
  default = null
}