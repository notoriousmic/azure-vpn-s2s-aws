# Local values for common configurations and computed names
locals {
  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "Azure-S2S-VPN"
    }
  )

  # Azure naming
  azure_resource_group_name = "${var.project_name}-${var.environment}-rg"
  azure_vnet_name           = "${var.project_name}-${var.environment}-vnet"
  azure_gateway_subnet_name = "GatewaySubnet" # Must be this exact name

  # Azure VPN Gateway naming
  azure_vpn_gateway_name = "${var.azure_vpn_gateway_name_prefix}-${var.environment}"
  azure_pip1_name        = "${var.azure_vpn_gateway_name_prefix}pip1-${var.environment}"
  azure_pip2_name        = "${var.azure_vpn_gateway_name_prefix}pip2-${var.environment}"

  # AWS naming
  aws_vpc_name           = "${var.project_name}-${var.environment}-vpc"
  aws_vpn_gateway_name   = "AzureGW-${var.environment}"
  aws_customer_gateway_0 = "ToAzureInstance0-${var.environment}"
  aws_customer_gateway_1 = "ToAzureInstance1-${var.environment}"
  aws_vpn_connection_0   = "ToAzureInstance0-${var.environment}"
  aws_vpn_connection_1   = "ToAzureInstance1-${var.environment}"

  # BGP APIPA addresses based on the Azure-AWS VPN tutorial
  # AWS uses the first IP (.1, .5), Azure uses the second IP (.2, .6)
  bgp_apipa = {
    # AWS Tunnel 1 to Azure Instance 0
    tunnel1_instance0 = {
      cidr         = "169.254.21.0/30"
      aws_bgp_ip   = "169.254.21.1"
      azure_bgp_ip = "169.254.21.2"
    }
    # AWS Tunnel 2 to Azure Instance 0
    tunnel2_instance0 = {
      cidr         = "169.254.22.0/30"
      aws_bgp_ip   = "169.254.22.1"
      azure_bgp_ip = "169.254.22.2"
    }
    # AWS Tunnel 1 to Azure Instance 1
    tunnel1_instance1 = {
      cidr         = "169.254.21.4/30"
      aws_bgp_ip   = "169.254.21.5"
      azure_bgp_ip = "169.254.21.6"
    }
    # AWS Tunnel 2 to Azure Instance 1
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
