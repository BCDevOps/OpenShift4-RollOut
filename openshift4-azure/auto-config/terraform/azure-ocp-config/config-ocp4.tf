provider "azurerm" {
  version = "=2.0.0"
  features {}
}


data "azurerm_subnet" "master_subnet" {
  name                 = "ocp4lab-mbtr9-master-subnet"
  virtual_network_name = "ocp4lab-mbtr9-vnet"
  resource_group_name  = var.rg_name
}

data "azurerm_subnet" "worker_subnet" {
  name                 = "ocp4lab-mbtr9-worker-subnet"
  virtual_network_name = "ocp4lab-mbtr9-vnet"
  resource_group_name  = var.rg_name
}

resource "azurerm_storage_account" "ocp4labpv" {
  name                      = var.stor_account_name
  resource_group_name       = var.rg_name
  location                  = var.location
  account_tier              = var.account_tier
  account_replication_type  = var.replication_teir
  enable_https_traffic_only = var.https_traffic

  # network_rules {
  #   default_action             = "Deny"
  #   bypass                     = ["AzureServices"]
  #   virtual_network_subnet_ids = [
  #     data.azurerm_subnet.master_subnet.id,
  #     data.azurerm_subnet.worker_subnet.id,
  #   ]
  # }

  tags = {
    environment = var.tag
  }
}

resource "azurerm_storage_container" "metering" {
 name                  = "metering-data"
 storage_account_name  = azurerm_storage_account.ocp4labpv.name
 container_access_type = "private"
}

output "storage_access_key" {
  value = azurerm_storage_account.ocp4labpv.primary_access_key
}
