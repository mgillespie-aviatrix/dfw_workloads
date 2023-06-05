terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.53.0"
  
    }
  }
}

provider "azurerm" {
  alias = "shared_services"
  subscription_id = ""
  tenant_id = ""
  client_id = ""
  client_secret = ""

  features {
     resource_group {
       prevent_deletion_if_contains_resources = false
     }
  }
}

provider "azurerm" {
  alias = "workload_1"
  subscription_id = ""
  tenant_id = ""
  client_id = ""
  client_secret = ""

  features {
     resource_group {
       prevent_deletion_if_contains_resources = false
     }
  }
}