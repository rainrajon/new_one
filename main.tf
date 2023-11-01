resource "azurerm_resource_group" "rg" {
 name     = var.resource_group_name
 location = var.resource_group_location
}
resource "azurerm_virtual_network" "vnet" {
 name                = var.virtual_network_name
 location            = azurerm_resource_group.rg.location
 resource_group_name = azurerm_resource_group.rg.name
 address_space       = [var.address_space]
}
resource "azurerm_subnet" "subnet_storage" {
 name                 = var.subnet_storage_name
 resource_group_name  = azurerm_resource_group.rg.name
 virtual_network_name = azurerm_virtual_network.vnet.name
 address_prefixes     = [var.subnet_storage_cidr]
 service_endpoints    = ["Microsoft.Storage"]
}
resource "azurerm_subnet" "subnet_computer_vision" {
 name                 = var.subnet_computer_vision_name
 resource_group_name  = azurerm_resource_group.rg.name
 virtual_network_name = azurerm_virtual_network.vnet.name
 address_prefixes     = [var.subnet_computer_vision_cidr]
 service_endpoints    = ["Microsoft.CognitiveServices"]
 }
resource "azurerm_subnet" "subnet_openai" {
 name                 = var.subnet_openai_name
 resource_group_name  = azurerm_resource_group.rg.name
 virtual_network_name = azurerm_virtual_network.vnet.name
 address_prefixes     = [var.subnet_openai_cidr]
 service_endpoints    = ["Microsoft.CognitiveServices"]
}
resource "azurerm_subnet" "subnet_container_registry" {
 name                 = var.subnet_container_registry_name
 resource_group_name  = azurerm_resource_group.rg.name
 virtual_network_name = azurerm_virtual_network.vnet.name
 address_prefixes     = [var.subnet_container_registry_cidr]
 service_endpoints    = ["Microsoft.ContainerRegistry"]
}
resource "azurerm_subnet" "subnet_container_instance" {
 name                 = var.subnet_container_instance_name
 resource_group_name  = azurerm_resource_group.rg.name
 virtual_network_name = azurerm_virtual_network.vnet.name
 address_prefixes     = [var.subnet_container_instance_cidr]
 service_endpoints    = ["Microsoft.CognitiveServices","Microsoft.Storage"]
}
resource "azurerm_storage_account" "adls_storage_account" {
  name                = var.adls_account_name
  resource_group_name = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["136.226.0.0/16","165.225.0.0/16"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet_storage.id]
  }

  tags = {
    environment = "NonProd",
    product = "Storage Conditions"
  }
}
resource "azurerm_cognitive_account" "computer_vision" {
  name                = var.computer_vision_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "ComputerVision"
  
  sku_name = "S0"
  custom_subdomain_name = var.computer_vision_name
  network_acls {
    default_action             = "Deny"
    ip_rules                   = ["136.226.0.0/16","165.225.0.0/16"]
    virtual_network_rules {
      subnet_id = azurerm_subnet.subnet_computer_vision.id
      ignore_missing_vnet_service_endpoint = false
    }
  }
  tags = {
    enviroment = "NonProd"
  }
}
resource "azurerm_cognitive_account" "openai" {
  name                = var.openai_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"

  sku_name = "S0"
  custom_subdomain_name = var.openai_name
  network_acls {
    default_action             = "Deny"
    ip_rules                   = ["136.226.0.0/16","165.225.0.0/16"]
    virtual_network_rules {
      subnet_id = azurerm_subnet.subnet_openai.id
      ignore_missing_vnet_service_endpoint = false
    }
  }
  tags = {
    enviroment = "NonProd"
  }
}
