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

  INFRA_CONFIG = {
    cloud : "azure",
    container_registry : azurerm_container_registry.acr.login_server,
    storage_account : data.azurerm_storage_account.storage.name
  }
  INFRA_CONFIG_FIELDS_JSON = [for k, v in local.INFRA_CONFIG : "\"${k}\": \"${v}\""]
  INFRA_CONFIG_FIELDS_TOML = [for k, v in local.INFRA_CONFIG : "${k} = \"${v}\""]
}

resource "azurerm_storage_container" "containers" {
  for_each              = toset(local.container_names)
  name                  = each.key
  storage_account_name  = data.azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Identity used for Github Action-based deployment of app services.
module "ci_cd_sp" {
  source = "./modules/sp"

  display_name = "${var.deployment_name}-gh-deploy"
  role_assignments = [
    { role = "AcrPush", scope = azurerm_container_registry.acr.id },
    { role = "Storage Blob Data Contributor", scope = data.azurerm_storage_account.storage.id }
  ]
}

# module "datasets" {
#   source     = "./dataset"
#   for_each   = var.datasets
#   definition = each.value
#   name       = each.key
# }

