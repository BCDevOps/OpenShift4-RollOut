provider "azurerm" {
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
  tags     = { 
    environment = var.env_tag
  }
}

resource "azurerm_dns_zone" "dns" {
  name                = var.dns_name
  resource_group_name = "${azurerm_resource_group.rg.name}"
  tags                = { 
    environment = var.env_tag
  }
}

resource "azurerm_key_vault" "keyvault" {
  name                        = var.kv_name
  location                    = var.location
  resource_group_name         = var.rg_name
  tenant_id                   = var.tenant_id

  sku_name = "standard"

  tags = {
    environment = var.env_tag
  }
}