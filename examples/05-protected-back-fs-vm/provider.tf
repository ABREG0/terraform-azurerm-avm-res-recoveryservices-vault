
provider "azurerm" {
  features {
     resource_group {
       prevent_deletion_if_contains_resources = false
     }
  }
    subscription_id = "c5c1228d-b650-4f0a-97ea-1f8cfdc417c5" # abrego-4 # "ee5d2fa3-deed-4b33-bc7c-b5fbe997bc65" abrego-1
}