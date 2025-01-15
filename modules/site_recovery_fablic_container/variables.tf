
variable "site_recovery_fabric_container" {
  type = object({
    name = string
    fabric_name = optional(string, null)
    location = string
    vault_name = string
    vault_resource_group_name = string

  })
  default = null
}