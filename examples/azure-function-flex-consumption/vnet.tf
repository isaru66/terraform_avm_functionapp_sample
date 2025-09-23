# -- VNET
resource "azurerm_virtual_network" "example" {
  location            = azurerm_resource_group.example.location
  name                = module.naming.virtual_network.name_unique
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "snet_operation" {
  address_prefixes     = ["10.10.1.0/28"]
  name                 = "snet-operation"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
}


resource "azurerm_subnet" "snet_internal_load_balancer" {
  address_prefixes     = ["10.10.1.16/28"]
  name                 = "snet-internal-load-balancer"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
}


resource "azurerm_subnet" "snet_vnet_integration" {
  address_prefixes     = ["10.10.1.32/27"]
  name                 = "snet-vnet-integration"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name

  delegation {
    name = "appservice-delegation"

    service_delegation {
      # for app service plan , use "Microsoft.Web/serverFarms"
      name    = "Microsoft.App/environments" # for Flex consumption, use "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "snet_private_endpoint" {
  address_prefixes     = ["10.10.1.64/28"]
  name                 = "snet-private-endpoint"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
}