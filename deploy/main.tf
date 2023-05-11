# Master resource group and storage account for 
# deployment (unmanaged, created by terraform_init.sh)
data "azurerm_resource_group" "rg" {
  name = "${var.deployment_name}-rg"
}
data "azurerm_storage_account" "storage" {
  name                = "${var.deployment_name}sa"
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.deployment_name}acr"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  admin_enabled       = true
  sku                 = "Premium"
}

locals {
  container_names = ["reference", "main", "main-tmp", "main-analysis"]
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(local.container_names)
  name                  = each.key
  storage_account_name  = data.azurerm_storage_account.storage.name
  container_access_type = "private"
}

# module "datasets" {
#   source     = "./dataset"
#   for_each   = var.datasets
#   definition = each.value
#   name       = each.key
# }

