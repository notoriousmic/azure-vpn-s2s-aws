# ============================================================================
# Azure Network Resources
# ============================================================================

# Create a resource group
resource "azurerm_resource_group" "this" {
  name     = local.azure_resource_group_name
  location = var.azure_location

  tags = local.common_tags
}

# Create a virtual network
resource "azurerm_virtual_network" "this" {
  name                = local.azure_vnet_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = var.azure_vnet_address_space

  tags = local.common_tags
}

# Create gateway subnet (name must be exactly "GatewaySubnet")
resource "azurerm_subnet" "gateway" {
  name                 = local.azure_gateway_subnet_name
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = var.azure_gateway_subnet_prefix
}

# Network Security Group - Allow traffic from Azure VNet and AWS VPC
resource "azurerm_network_security_group" "vpn_traffic" {
  name                = "${local.azure_vnet_name}-vpn-nsg"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  # Allow all inbound traffic from Azure VNet
  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = var.azure_vnet_address_space
    destination_address_prefix = "*"
  }

  # Allow all inbound traffic from AWS VPC
  security_rule {
    name                       = "AllowAWSVPCInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = var.aws_vpc_cidr
    destination_address_prefix = "*"
  }

  # Allow all outbound traffic
  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.common_tags
}
