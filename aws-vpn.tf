# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for license information.

# ==============================================================================
# AWS Customer Gateways (one for each Azure VPN Gateway instance)
# ==============================================================================

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

  depends_on = [azurerm_virtual_network_gateway.vpn_gateway]
}

# ==============================================================================
# AWS Site-to-Site VPN Connections — VPG-based (greenfield, existing_vpc, existing_vpg)
# ==============================================================================

# VPN Connection 1 via Virtual Private Gateway
resource "aws_vpn_connection" "vpg_to_azure_instance0" {
  count = local.use_tgw ? 0 : 1

  vpn_gateway_id      = local.vpg_id
  customer_gateway_id = aws_customer_gateway.to_azure_instance0.id
  type                = "ipsec.1"
  static_routes_only  = false

  local_ipv4_network_cidr  = "0.0.0.0/0"
  remote_ipv4_network_cidr = "0.0.0.0/0"

  tunnel1_inside_cidr   = local.bgp_apipa.tunnel1_instance0.cidr
  tunnel1_preshared_key = var.tunnel1_instance0_psk

  tunnel2_inside_cidr   = local.bgp_apipa.tunnel2_instance0.cidr
  tunnel2_preshared_key = var.tunnel2_instance0_psk

  tags = merge(
    local.common_tags,
    {
      Name = local.aws_vpn_connection_0
    }
  )
}

# VPN Connection 2 via Virtual Private Gateway
resource "aws_vpn_connection" "vpg_to_azure_instance1" {
  count = local.use_tgw ? 0 : 1

  vpn_gateway_id      = local.vpg_id
  customer_gateway_id = aws_customer_gateway.to_azure_instance1.id
  type                = "ipsec.1"
  static_routes_only  = false

  local_ipv4_network_cidr  = "0.0.0.0/0"
  remote_ipv4_network_cidr = "0.0.0.0/0"

  tunnel1_inside_cidr   = local.bgp_apipa.tunnel1_instance1.cidr
  tunnel1_preshared_key = var.tunnel1_instance1_psk

  tunnel2_inside_cidr   = local.bgp_apipa.tunnel2_instance1.cidr
  tunnel2_preshared_key = var.tunnel2_instance1_psk

  tags = merge(
    local.common_tags,
    {
      Name = local.aws_vpn_connection_1
    }
  )
}

# ==============================================================================
# AWS Site-to-Site VPN Connections — TGW-based (transit_gateway scenario)
# ==============================================================================

# VPN Connection 1 via Transit Gateway
resource "aws_vpn_connection" "tgw_to_azure_instance0" {
  count = local.use_tgw ? 1 : 0

  transit_gateway_id  = var.aws_transit_gateway_id
  customer_gateway_id = aws_customer_gateway.to_azure_instance0.id
  type                = "ipsec.1"
  static_routes_only  = false

  local_ipv4_network_cidr  = "0.0.0.0/0"
  remote_ipv4_network_cidr = "0.0.0.0/0"

  tunnel1_inside_cidr   = local.bgp_apipa.tunnel1_instance0.cidr
  tunnel1_preshared_key = var.tunnel1_instance0_psk

  tunnel2_inside_cidr   = local.bgp_apipa.tunnel2_instance0.cidr
  tunnel2_preshared_key = var.tunnel2_instance0_psk

  tags = merge(
    local.common_tags,
    {
      Name = local.aws_vpn_connection_0
    }
  )
}

# VPN Connection 2 via Transit Gateway
resource "aws_vpn_connection" "tgw_to_azure_instance1" {
  count = local.use_tgw ? 1 : 0

  transit_gateway_id  = var.aws_transit_gateway_id
  customer_gateway_id = aws_customer_gateway.to_azure_instance1.id
  type                = "ipsec.1"
  static_routes_only  = false

  local_ipv4_network_cidr  = "0.0.0.0/0"
  remote_ipv4_network_cidr = "0.0.0.0/0"

  tunnel1_inside_cidr   = local.bgp_apipa.tunnel1_instance1.cidr
  tunnel1_preshared_key = var.tunnel1_instance1_psk

  tunnel2_inside_cidr   = local.bgp_apipa.tunnel2_instance1.cidr
  tunnel2_preshared_key = var.tunnel2_instance1_psk

  tags = merge(
    local.common_tags,
    {
      Name = local.aws_vpn_connection_1
    }
  )
}

# ==============================================================================
# Locals — Resolved VPN connection outputs (unified regardless of VPG/TGW)
# ==============================================================================

locals {
  vpn_connection_0 = local.use_tgw ? aws_vpn_connection.tgw_to_azure_instance0[0] : aws_vpn_connection.vpg_to_azure_instance0[0]
  vpn_connection_1 = local.use_tgw ? aws_vpn_connection.tgw_to_azure_instance1[0] : aws_vpn_connection.vpg_to_azure_instance1[0]
}
