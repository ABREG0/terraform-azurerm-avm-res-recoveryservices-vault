variable "subscription_id" {
  type        = string
  description = "Target Azure subscription ID for this deployment."
}

variable "location" {
  type        = string
  description = "Azure region for this single deployment instance."
  default     = "centralus"
}

variable "bypass_ip_cidr" {
  type        = string
  default     = null
  description = "value to bypass the IP CIDR on firewall rules"
}
