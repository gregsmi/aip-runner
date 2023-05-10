terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.55.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.38.0"
    }
  }
}

# Use Azure blob store to manage Terraform state - fill in 
# required fields via -backend-config on terraform init.
terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}
