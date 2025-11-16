# ============================================================================
# General Variables
# ============================================================================

variable "project_name" {
  description = "Name of the project, used as prefix for resource names"
  type        = string
  default     = "azure-aws-vpn"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# Azure Variables
# ============================================================================

variable "azure_location" {
  description = "Azure region for resources"
  type        = string
  default     = "West Europe"
}

variable "azure_vnet_address_space" {
  description = "Address space for Azure Virtual Network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "azure_gateway_subnet_prefix" {
  description = "Address prefix for Azure Gateway Subnet (minimum /27 recommended)"
  type        = list(string)
  default     = ["10.1.255.0/27"]
}

variable "azure_vpn_gateway_name_prefix" {
  description = "Name prefix for Azure VPN Gateway"
  type        = string
  default     = "VNet1GW"
}

variable "azure_vpn_gateway_sku" {
  description = "SKU for Azure VPN Gateway"
  type        = string
  default     = "VpnGw2AZ"
  validation {
    condition     = can(regex("^VpnGw[1-5]A?Z?$", var.azure_vpn_gateway_sku))
    error_message = "Must be a valid VPN Gateway SKU (e.g., VpnGw1, VpnGw2AZ)."
  }
}

variable "azure_vpn_gateway_generation" {
  description = "Generation for Azure VPN Gateway"
  type        = string
  default     = "Generation2"
  validation {
    condition     = contains(["Generation1", "Generation2"], var.azure_vpn_gateway_generation)
    error_message = "Must be either Generation1 or Generation2."
  }
}

variable "azure_bgp_asn" {
  description = "BGP ASN for Azure VPN Gateway"
  type        = number
  default     = 65000
  validation {
    condition     = var.azure_bgp_asn >= 64512 && var.azure_bgp_asn <= 65534
    error_message = "BGP ASN must be in the private ASN range (64512-65534)."
  }
}

variable "azure_availability_zones" {
  description = "Availability zones for Azure public IPs"
  type        = list(string)
  default     = ["1", "2", "3"]
}

# ============================================================================
# AWS Variables
# ============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "aws_vpn_gateway_asn" {
  description = "BGP ASN for AWS Virtual Private Gateway (use 64512 for Amazon default)"
  type        = number
  default     = 64512
}

# ============================================================================
# VPN Tunnel Pre-Shared Keys
# ============================================================================
# These should be secure random strings that match between AWS and Azure configurations

variable "tunnel1_instance0_psk" {
  description = "Pre-shared key for AWS Tunnel 1 to Azure Instance 0"
  type        = string
  sensitive   = true
}

variable "tunnel2_instance0_psk" {
  description = "Pre-shared key for AWS Tunnel 2 to Azure Instance 0"
  type        = string
  sensitive   = true
}

variable "tunnel1_instance1_psk" {
  description = "Pre-shared key for AWS Tunnel 1 to Azure Instance 1"
  type        = string
  sensitive   = true
}

variable "tunnel2_instance1_psk" {
  description = "Pre-shared key for AWS Tunnel 2 to Azure Instance 1"
  type        = string
  sensitive   = true
}
