# ============================================================================
# AWS Customer Gateways (one for each Azure VPN Gateway instance)
# ============================================================================

# Customer Gateway 1 - Points to Azure VPN Gateway Instance 0
resource "aws_customer_gateway" "to_azure_instance0" {
  bgp_asn    = var.azure_bgp_asn
  ip_address = azurerm_public_ip.vpn_gateway_pip1.ip_address
  type       = "ipsec.1"

  tags = merge(
    local.common_tags,
    {
      Name = local.aws_customer_gateway_0
    }
  )

  # Ensure Azure VPN Gateway is fully created before creating customer gateway
  depends_on = [azurerm_virtual_network_gateway.vpn_gateway]
}

# Customer Gateway 2 - Points to Azure VPN Gateway Instance 1
resource "aws_customer_gateway" "to_azure_instance1" {
  bgp_asn    = var.azure_bgp_asn
  ip_address = azurerm_public_ip.vpn_gateway_pip2.ip_address
  type       = "ipsec.1"

  tags = merge(
    local.common_tags,
    {
      Name = local.aws_customer_gateway_1
    }
  )

  # Ensure Azure VPN Gateway is fully created before creating customer gateway
  depends_on = [azurerm_virtual_network_gateway.vpn_gateway]
}

# ============================================================================
# AWS Site-to-Site VPN Connections (each with 2 tunnels)
# ============================================================================

# Site-to-Site VPN Connection 1 - To Azure Instance 0 (2 tunnels)
resource "aws_vpn_connection" "to_azure_instance0" {
  vpn_gateway_id      = aws_vpn_gateway.azure_gw.id
  customer_gateway_id = aws_customer_gateway.to_azure_instance0.id
  type                = "ipsec.1"
  static_routes_only  = false

  local_ipv4_network_cidr  = "0.0.0.0/0"
  remote_ipv4_network_cidr = "0.0.0.0/0"

  # Tunnel 1 configuration
  tunnel1_inside_cidr   = local.bgp_apipa.tunnel1_instance0.cidr
  tunnel1_preshared_key = var.tunnel1_instance0_psk

  # Tunnel 2 configuration
  tunnel2_inside_cidr   = local.bgp_apipa.tunnel2_instance0.cidr
  tunnel2_preshared_key = var.tunnel2_instance0_psk

  tags = merge(
    local.common_tags,
    {
      Name = local.aws_vpn_connection_0
    }
  )
}

# Site-to-Site VPN Connection 2 - To Azure Instance 1 (2 tunnels)
resource "aws_vpn_connection" "to_azure_instance1" {
  vpn_gateway_id      = aws_vpn_gateway.azure_gw.id
  customer_gateway_id = aws_customer_gateway.to_azure_instance1.id
  type                = "ipsec.1"
  static_routes_only  = false

  local_ipv4_network_cidr  = "0.0.0.0/0"
  remote_ipv4_network_cidr = "0.0.0.0/0"

  # Tunnel 1 configuration
  tunnel1_inside_cidr   = local.bgp_apipa.tunnel1_instance1.cidr
  tunnel1_preshared_key = var.tunnel1_instance1_psk

  # Tunnel 2 configuration
  tunnel2_inside_cidr   = local.bgp_apipa.tunnel2_instance1.cidr
  tunnel2_preshared_key = var.tunnel2_instance1_psk

  tags = merge(
    local.common_tags,
    {
      Name = local.aws_vpn_connection_1
    }
  )
}
