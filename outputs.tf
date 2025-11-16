# ============================================================================
# Azure Outputs
# ============================================================================

output "azure_resource_group_name" {
  description = "Name of the Azure resource group"
  value       = azurerm_resource_group.this.name
}

output "azure_vnet_name" {
  description = "Name of the Azure virtual network"
  value       = azurerm_virtual_network.this.name
}

output "azure_vnet_address_space" {
  description = "Address space of the Azure virtual network"
  value       = azurerm_virtual_network.this.address_space
}

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

output "azure_bgp_peering_addresses" {
  description = "BGP peering addresses configured on Azure VPN Gateway"
  value = {
    instance_0 = local.azure_instance0_bgp_ips
    instance_1 = local.azure_instance1_bgp_ips
  }
}

# ============================================================================
# AWS Outputs
# ============================================================================

output "aws_vpc_id" {
  description = "ID of the AWS VPC"
  value       = aws_vpc.vpc1.id
}

output "aws_vpc_cidr" {
  description = "CIDR block of the AWS VPC"
  value       = aws_vpc.vpc1.cidr_block
}

output "aws_vpn_gateway_id" {
  description = "ID of the AWS Virtual Private Gateway"
  value       = aws_vpn_gateway.azure_gw.id
}

output "aws_vpn_gateway_asn" {
  description = "BGP ASN of AWS Virtual Private Gateway"
  value       = aws_vpn_gateway.azure_gw.amazon_side_asn
}

# ============================================================================
# AWS Tunnel Information - Connection to Azure Instance 0
# ============================================================================

output "aws_tunnel1_instance0_outside_ip" {
  description = "Outside IP address for AWS Tunnel 1 to Azure Instance 0"
  value       = aws_vpn_connection.to_azure_instance0.tunnel1_address
}

output "aws_tunnel1_instance0_bgp_ip" {
  description = "BGP IP address (inside) for AWS Tunnel 1 to Azure Instance 0"
  value       = aws_vpn_connection.to_azure_instance0.tunnel1_vgw_inside_address
}

output "aws_tunnel1_instance0_bgp_asn" {
  description = "BGP ASN for AWS Tunnel 1 to Azure Instance 0"
  value       = aws_vpn_connection.to_azure_instance0.tunnel1_bgp_asn
}

output "aws_tunnel2_instance0_outside_ip" {
  description = "Outside IP address for AWS Tunnel 2 to Azure Instance 0"
  value       = aws_vpn_connection.to_azure_instance0.tunnel2_address
}

output "aws_tunnel2_instance0_bgp_ip" {
  description = "BGP IP address (inside) for AWS Tunnel 2 to Azure Instance 0"
  value       = aws_vpn_connection.to_azure_instance0.tunnel2_vgw_inside_address
}

# ============================================================================
# AWS Tunnel Information - Connection to Azure Instance 1
# ============================================================================

output "aws_tunnel1_instance1_outside_ip" {
  description = "Outside IP address for AWS Tunnel 1 to Azure Instance 1"
  value       = aws_vpn_connection.to_azure_instance1.tunnel1_address
}

output "aws_tunnel1_instance1_bgp_ip" {
  description = "BGP IP address (inside) for AWS Tunnel 1 to Azure Instance 1"
  value       = aws_vpn_connection.to_azure_instance1.tunnel1_vgw_inside_address
}

output "aws_tunnel2_instance1_outside_ip" {
  description = "Outside IP address for AWS Tunnel 2 to Azure Instance 1"
  value       = aws_vpn_connection.to_azure_instance1.tunnel2_address
}

output "aws_tunnel2_instance1_bgp_ip" {
  description = "BGP IP address (inside) for AWS Tunnel 2 to Azure Instance 1"
  value       = aws_vpn_connection.to_azure_instance1.tunnel2_vgw_inside_address
}

# ============================================================================
# BGP APIPA Configuration Summary
# ============================================================================

output "bgp_apipa_configuration" {
  description = "Complete BGP APIPA addressing configuration for all tunnels"
  value = {
    tunnel1_instance0 = {
      cidr         = local.bgp_apipa.tunnel1_instance0.cidr
      aws_bgp_ip   = local.bgp_apipa.tunnel1_instance0.aws_bgp_ip
      azure_bgp_ip = local.bgp_apipa.tunnel1_instance0.azure_bgp_ip
      outside_ip   = aws_vpn_connection.to_azure_instance0.tunnel1_address
    }
    tunnel2_instance0 = {
      cidr         = local.bgp_apipa.tunnel2_instance0.cidr
      aws_bgp_ip   = local.bgp_apipa.tunnel2_instance0.aws_bgp_ip
      azure_bgp_ip = local.bgp_apipa.tunnel2_instance0.azure_bgp_ip
      outside_ip   = aws_vpn_connection.to_azure_instance0.tunnel2_address
    }
    tunnel1_instance1 = {
      cidr         = local.bgp_apipa.tunnel1_instance1.cidr
      aws_bgp_ip   = local.bgp_apipa.tunnel1_instance1.aws_bgp_ip
      azure_bgp_ip = local.bgp_apipa.tunnel1_instance1.azure_bgp_ip
      outside_ip   = aws_vpn_connection.to_azure_instance1.tunnel1_address
    }
    tunnel2_instance1 = {
      cidr         = local.bgp_apipa.tunnel2_instance1.cidr
      aws_bgp_ip   = local.bgp_apipa.tunnel2_instance1.aws_bgp_ip
      azure_bgp_ip = local.bgp_apipa.tunnel2_instance1.azure_bgp_ip
      outside_ip   = aws_vpn_connection.to_azure_instance1.tunnel2_address
    }
  }
}

# ============================================================================
# Connection Summary
# ============================================================================

output "connection_summary" {
  description = "Summary of all VPN connections"
  value = {
    total_tunnels   = 4
    azure_gateway   = azurerm_virtual_network_gateway.vpn_gateway.name
    azure_instances = 2
    aws_connections = 2
    aws_vpn_gateway = aws_vpn_gateway.azure_gw.id
  }
}