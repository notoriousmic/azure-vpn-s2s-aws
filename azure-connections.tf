# ============================================================================
# Azure Local Network Gateways (one for each AWS tunnel)
# ============================================================================

# Local Network Gateway 1 - AWS Tunnel 1 to Azure Instance 0
resource "azurerm_local_network_gateway" "aws_tunnel1_instance0" {
  name                = "AWSTunnel1toAzureInstance0"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  gateway_address     = aws_vpn_connection.to_azure_instance0.tunnel1_address

  bgp_settings {
    asn                 = var.aws_vpn_gateway_asn
    bgp_peering_address = local.bgp_apipa.tunnel1_instance0.aws_bgp_ip
  }

  tags = local.common_tags

  # Ensure AWS VPN connection is created before local network gateway
  depends_on = [
    aws_vpn_connection.to_azure_instance0,
    azurerm_virtual_network_gateway.vpn_gateway
  ]
}

# Local Network Gateway 2 - AWS Tunnel 2 to Azure Instance 0
resource "azurerm_local_network_gateway" "aws_tunnel2_instance0" {
  name                = "AWSTunnel2toAzureInstance0"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  gateway_address     = aws_vpn_connection.to_azure_instance0.tunnel2_address

  bgp_settings {
    asn                 = var.aws_vpn_gateway_asn
    bgp_peering_address = local.bgp_apipa.tunnel2_instance0.aws_bgp_ip
  }

  tags = local.common_tags

  # Ensure AWS VPN connection is created before local network gateway
  depends_on = [
    aws_vpn_connection.to_azure_instance0,
    azurerm_virtual_network_gateway.vpn_gateway
  ]
}

# Local Network Gateway 3 - AWS Tunnel 1 to Azure Instance 1
resource "azurerm_local_network_gateway" "aws_tunnel1_instance1" {
  name                = "AWSTunnel1toAzureInstance1"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  gateway_address     = aws_vpn_connection.to_azure_instance1.tunnel1_address

  bgp_settings {
    asn                 = var.aws_vpn_gateway_asn
    bgp_peering_address = local.bgp_apipa.tunnel1_instance1.aws_bgp_ip
  }

  tags = local.common_tags

  # Ensure AWS VPN connection is created before local network gateway
  depends_on = [
    aws_vpn_connection.to_azure_instance1,
    azurerm_virtual_network_gateway.vpn_gateway
  ]
}

# Local Network Gateway 4 - AWS Tunnel 2 to Azure Instance 1
resource "azurerm_local_network_gateway" "aws_tunnel2_instance1" {
  name                = "AWSTunnel2toAzureInstance1"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  gateway_address     = aws_vpn_connection.to_azure_instance1.tunnel2_address

  bgp_settings {
    asn                 = var.aws_vpn_gateway_asn
    bgp_peering_address = local.bgp_apipa.tunnel2_instance1.aws_bgp_ip
  }

  tags = local.common_tags

  # Ensure AWS VPN connection is created before local network gateway
  depends_on = [
    aws_vpn_connection.to_azure_instance1,
    azurerm_virtual_network_gateway.vpn_gateway
  ]
}

# ============================================================================
# Azure VPN Connections (one for each AWS tunnel)
# ============================================================================

# Connection 1 - AWS Tunnel 1 to Azure Instance 0
resource "azurerm_virtual_network_gateway_connection" "aws_tunnel1_instance0" {
  name                = "AWSTunnel1toAzureInstance0"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_tunnel1_instance0.id

  shared_key = var.tunnel1_instance0_psk
  enable_bgp = true

  custom_bgp_addresses {
    primary   = local.bgp_apipa.tunnel1_instance0.azure_bgp_ip
    secondary = local.bgp_apipa.tunnel1_instance1.azure_bgp_ip # Not used but required
  }

  tags = local.common_tags
}

# Connection 2 - AWS Tunnel 2 to Azure Instance 0
resource "azurerm_virtual_network_gateway_connection" "aws_tunnel2_instance0" {
  name                = "AWSTunnel2toAzureInstance0"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_tunnel2_instance0.id

  shared_key = var.tunnel2_instance0_psk
  enable_bgp = true

  custom_bgp_addresses {
    primary   = local.bgp_apipa.tunnel2_instance0.azure_bgp_ip
    secondary = local.bgp_apipa.tunnel1_instance1.azure_bgp_ip # Not used but required
  }

  tags = local.common_tags
}

# Connection 3 - AWS Tunnel 1 to Azure Instance 1
resource "azurerm_virtual_network_gateway_connection" "aws_tunnel1_instance1" {
  name                = "AWSTunnel1toAzureInstance1"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_tunnel1_instance1.id

  shared_key = var.tunnel1_instance1_psk
  enable_bgp = true

  custom_bgp_addresses {
    primary   = local.bgp_apipa.tunnel1_instance0.azure_bgp_ip # Not used but required
    secondary = local.bgp_apipa.tunnel1_instance1.azure_bgp_ip
  }

  tags = local.common_tags
}

# Connection 4 - AWS Tunnel 2 to Azure Instance 1
resource "azurerm_virtual_network_gateway_connection" "aws_tunnel2_instance1" {
  name                = "AWSTunnel2toAzureInstance1"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws_tunnel2_instance1.id

  shared_key = var.tunnel2_instance1_psk
  enable_bgp = true

  custom_bgp_addresses {
    primary   = local.bgp_apipa.tunnel1_instance0.azure_bgp_ip # Not used but required
    secondary = local.bgp_apipa.tunnel2_instance1.azure_bgp_ip
  }

  tags = local.common_tags
}
