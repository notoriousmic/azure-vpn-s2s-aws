# ============================================================================
# Azure VPN Gateway Resources
# ============================================================================

# Create first public IP for VPN Gateway (Instance 0)
resource "azurerm_public_ip" "vpn_gateway_pip1" {
  name                = local.azure_pip1_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.azure_availability_zones

  tags = local.common_tags
}

# Create second public IP for VPN Gateway (Instance 1) - for active-active mode
resource "azurerm_public_ip" "vpn_gateway_pip2" {
  name                = local.azure_pip2_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.azure_availability_zones

  tags = local.common_tags
}

# Create Virtual Network Gateway (VPN Gateway) with active-active and BGP enabled
resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = local.azure_vpn_gateway_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = true
  enable_bgp    = true
  sku           = var.azure_vpn_gateway_sku
  generation    = var.azure_vpn_gateway_generation

  bgp_settings {
    asn = var.azure_bgp_asn

    # Instance 0 BGP APIPA addresses
    peering_addresses {
      ip_configuration_name = "vnetGatewayConfig1"
      apipa_addresses       = local.azure_instance0_bgp_ips
    }

    # Instance 1 BGP APIPA addresses
    peering_addresses {
      ip_configuration_name = "vnetGatewayConfig2"
      apipa_addresses       = local.azure_instance1_bgp_ips
    }
  }

  # IP configuration for Instance 0
  ip_configuration {
    name                          = "vnetGatewayConfig1"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }

  # IP configuration for Instance 1 (active-active mode)
  ip_configuration {
    name                          = "vnetGatewayConfig2"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }

  tags = local.common_tags

  # VPN Gateway creation typically takes 30-45 minutes
  timeouts {
    create = "90m"
    update = "90m"
    delete = "90m"
  }
}
