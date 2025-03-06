
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "ee5d2fa3-deed-4b33-bc7c-b5fbe997bc65"
}