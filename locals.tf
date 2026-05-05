# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for license information.

# Local values for common configurations and computed names
locals {
  # Scenario flags
  create_vpc = var.aws_scenario == "greenfield"
  create_vpg = contains(["greenfield", "existing_vpc"], var.aws_scenario)
  use_tgw    = var.aws_scenario == "transit_gateway"

  # Resolved VPC ID — either created or provided
  vpc_id = local.create_vpc ? aws_vpc.this[0].id : var.aws_vpc_id

  # Resolved VPN attachment target — VPG ID or TGW ID
  vpg_id = local.create_vpg ? aws_vpn_gateway.this[0].id : (var.aws_scenario == "existing_vpg" ? var.aws_vpn_gateway_id : null)

  # Resolved route table for VPN route propagation
  route_table_id = local.create_vpc ? aws_route_table.main[0].id : var.aws_route_table_id

  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "Azure-AWS-S2S-VPN"
      AWSScenario = var.aws_scenario
    }
  )

  # Azure naming
  azure_resource_group_name = "${var.name_prefix}-${var.environment}-rg"
  azure_vnet_name           = "${var.name_prefix}-${var.environment}-vnet"
  azure_gateway_subnet_name = "GatewaySubnet"

  # Azure VPN Gateway naming
  azure_vpn_gateway_name = "${var.name_prefix}-vpngw-${var.environment}"
  azure_pip1_name        = "${var.name_prefix}-vpngw-pip1-${var.environment}"
  azure_pip2_name        = "${var.name_prefix}-vpngw-pip2-${var.environment}"

  # AWS naming
  aws_vpc_name           = "${var.name_prefix}-${var.environment}-vpc"
  aws_vpn_gateway_name   = "${var.name_prefix}-vpngw-${var.environment}"
  aws_customer_gateway_0 = "${var.name_prefix}-cgw-az0-${var.environment}"
  aws_customer_gateway_1 = "${var.name_prefix}-cgw-az1-${var.environment}"
  aws_vpn_connection_0   = "${var.name_prefix}-vpn-az0-${var.environment}"
  aws_vpn_connection_1   = "${var.name_prefix}-vpn-az1-${var.environment}"

  # BGP APIPA addresses
  # AWS uses the first IP (.1, .5), Azure uses the second IP (.2, .6)
  bgp_apipa = {
    tunnel1_instance0 = {
      cidr         = "169.254.21.0/30"
      aws_bgp_ip   = "169.254.21.1"
      azure_bgp_ip = "169.254.21.2"
    }
    tunnel2_instance0 = {
      cidr         = "169.254.22.0/30"
      aws_bgp_ip   = "169.254.22.1"
      azure_bgp_ip = "169.254.22.2"
    }
    tunnel1_instance1 = {
      cidr         = "169.254.21.4/30"
      aws_bgp_ip   = "169.254.21.5"
      azure_bgp_ip = "169.254.21.6"
    }
    tunnel2_instance1 = {
      cidr         = "169.254.22.4/30"
      aws_bgp_ip   = "169.254.22.5"
      azure_bgp_ip = "169.254.22.6"
    }
  }

  # Azure custom BGP addresses for VPN Gateway instances
  azure_instance0_bgp_ips = [
    local.bgp_apipa.tunnel1_instance0.azure_bgp_ip,
    local.bgp_apipa.tunnel2_instance0.azure_bgp_ip
  ]

  azure_instance1_bgp_ips = [
    local.bgp_apipa.tunnel1_instance1.azure_bgp_ip,
    local.bgp_apipa.tunnel2_instance1.azure_bgp_ip
  ]
}
