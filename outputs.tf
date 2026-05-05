# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for license information.

# ==============================================================================
# Common Outputs
# ==============================================================================

output "resource_group_name" {
  description = "Name of the Azure resource group"
  value       = azurerm_resource_group.this.name
}

output "aws_scenario" {
  description = "The AWS-side deployment scenario used"
  value       = var.aws_scenario
}

output "azure_vnet_name" {
  description = "Name of the Azure virtual network"
  value       = azurerm_virtual_network.this.name
}

output "azure_vnet_address_space" {
  description = "Address space of the Azure virtual network"
  value       = azurerm_virtual_network.this.address_space
}

# ==============================================================================
# Azure VPN Gateway Outputs
# ==============================================================================

output "azure_vpn_gateway_name" {
  description = "Name of the Azure VPN Gateway"
  value       = azurerm_virtual_network_gateway.vpn_gateway.name
}

output "azure_vpn_gateway_id" {
  description = "ID of the Azure VPN Gateway"
  value       = azurerm_virtual_network_gateway.vpn_gateway.id
}

output "azure_vpn_gateway_public_ip_1" {
  description = "First public IP address of Azure VPN Gateway (Instance 0)"
  value       = azurerm_public_ip.vpn_gateway_pip1.ip_address
}

output "azure_vpn_gateway_public_ip_2" {
  description = "Second public IP address of Azure VPN Gateway (Instance 1)"
  value       = azurerm_public_ip.vpn_gateway_pip2.ip_address
}

output "azure_bgp_asn" {
  description = "BGP ASN of Azure VPN Gateway"
  value       = azurerm_virtual_network_gateway.vpn_gateway.bgp_settings[0].asn
}

# ==============================================================================
# AWS Outputs
# ==============================================================================

output "aws_vpc_id" {
  description = "ID of the AWS VPC (created or provided)"
  value       = local.vpc_id
}

output "aws_vpn_gateway_id" {
  description = "ID of the AWS Virtual Private Gateway (null for transit_gateway scenario)"
  value       = local.vpg_id
}

output "aws_vpn_gateway_asn" {
  description = "BGP ASN of AWS-side gateway"
  value       = var.aws_vpn_gateway_asn
}

# ==============================================================================
# BGP APIPA Configuration
# ==============================================================================

output "bgp_apipa_configuration" {
  description = "Complete BGP APIPA addressing configuration for all tunnels"
  value = {
    tunnel1_instance0 = {
      cidr         = local.bgp_apipa.tunnel1_instance0.cidr
      aws_bgp_ip   = local.bgp_apipa.tunnel1_instance0.aws_bgp_ip
      azure_bgp_ip = local.bgp_apipa.tunnel1_instance0.azure_bgp_ip
      outside_ip   = local.vpn_connection_0.tunnel1_address
    }
    tunnel2_instance0 = {
      cidr         = local.bgp_apipa.tunnel2_instance0.cidr
      aws_bgp_ip   = local.bgp_apipa.tunnel2_instance0.aws_bgp_ip
      azure_bgp_ip = local.bgp_apipa.tunnel2_instance0.azure_bgp_ip
      outside_ip   = local.vpn_connection_0.tunnel2_address
    }
    tunnel1_instance1 = {
      cidr         = local.bgp_apipa.tunnel1_instance1.cidr
      aws_bgp_ip   = local.bgp_apipa.tunnel1_instance1.aws_bgp_ip
      azure_bgp_ip = local.bgp_apipa.tunnel1_instance1.azure_bgp_ip
      outside_ip   = local.vpn_connection_1.tunnel1_address
    }
    tunnel2_instance1 = {
      cidr         = local.bgp_apipa.tunnel2_instance1.cidr
      aws_bgp_ip   = local.bgp_apipa.tunnel2_instance1.aws_bgp_ip
      azure_bgp_ip = local.bgp_apipa.tunnel2_instance1.azure_bgp_ip
      outside_ip   = local.vpn_connection_1.tunnel2_address
    }
  }
}