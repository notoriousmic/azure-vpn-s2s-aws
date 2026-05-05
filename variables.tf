# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for license information.

# ==============================================================================
# Required Variables
# ==============================================================================

variable "azure_location" {
  description = "Azure region for resources"
  type        = string
}

# ==============================================================================
# AVM Required Variables
# ==============================================================================

variable "enable_telemetry" {
  type        = bool
  default     = true
  nullable    = false
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

# ==============================================================================
# General Variables
# ==============================================================================

variable "aws_scenario" {
  description = <<DESCRIPTION
AWS-side deployment scenario:
  - greenfield:      Create new VPC + new Virtual Private Gateway + subnets + NAT
  - transit_gateway:  Attach VPN to an existing AWS Transit Gateway (multi-VPC hub)
  - existing_vpc:    Bring your own VPC, create a new Virtual Private Gateway
  - existing_vpg:    Bring your own VPC + VPG, only create Customer Gateways and VPN connections
DESCRIPTION
  type        = string
  default     = "greenfield"
  validation {
    condition     = contains(["greenfield", "transit_gateway", "existing_vpc", "existing_vpg"], var.aws_scenario)
    error_message = "Must be one of: greenfield, transit_gateway, existing_vpc, existing_vpg."
  }
}

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "azure-aws-vpn"
  validation {
    condition     = length(var.name_prefix) >= 1 && length(var.name_prefix) <= 24 && can(regex("^[a-z0-9][a-z0-9-]*$", var.name_prefix))
    error_message = "Must be 1-24 characters, lowercase alphanumeric and hyphens, starting with a letter or number."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be one of: dev, staging, prod."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# Azure Networking Variables
# ==============================================================================

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

# ==============================================================================
# Azure VPN Gateway Variables
# ==============================================================================

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

# ==============================================================================
# AWS Variables — VPC
# ==============================================================================

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_vpc_cidr" {
  description = "CIDR block for AWS VPC (used for greenfield scenario; ignored when using existing VPC)"
  type        = string
  default     = "10.2.0.0/16"
  validation {
    condition     = can(cidrhost(var.aws_vpc_cidr, 0))
    error_message = "Must be a valid CIDR block (e.g., 10.2.0.0/16)."
  }
}

variable "aws_vpc_id" {
  description = "ID of an existing AWS VPC (required for existing_vpc, existing_vpg, and transit_gateway scenarios)"
  type        = string
  default     = ""
}

variable "aws_route_table_id" {
  description = "ID of an existing AWS route table for VPN route propagation (required for existing_vpc, existing_vpg scenarios; optional for transit_gateway)"
  type        = string
  default     = ""
}

# ==============================================================================
# AWS Variables — Virtual Private Gateway
# ==============================================================================

variable "aws_vpn_gateway_asn" {
  description = "BGP ASN for AWS-side gateway (VPG or TGW)"
  type        = number
  default     = 64512
  validation {
    condition     = var.aws_vpn_gateway_asn >= 64512 && var.aws_vpn_gateway_asn <= 65534
    error_message = "BGP ASN must be in the private ASN range (64512-65534)."
  }
}

variable "aws_vpn_gateway_id" {
  description = "ID of an existing AWS Virtual Private Gateway (required for existing_vpg scenario)"
  type        = string
  default     = ""
}

# ==============================================================================
# AWS Variables — Transit Gateway (transit_gateway scenario)
# ==============================================================================

variable "aws_transit_gateway_id" {
  description = "ID of an existing AWS Transit Gateway (required for transit_gateway scenario)"
  type        = string
  default     = ""
}

# ==============================================================================
# VPN Tunnel Pre-Shared Keys
# ==============================================================================

variable "tunnel1_instance0_psk" {
  description = "Pre-shared key for AWS Tunnel 1 to Azure Instance 0"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tunnel2_instance0_psk" {
  description = "Pre-shared key for AWS Tunnel 2 to Azure Instance 0"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tunnel1_instance1_psk" {
  description = "Pre-shared key for AWS Tunnel 1 to Azure Instance 1"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tunnel2_instance1_psk" {
  description = "Pre-shared key for AWS Tunnel 2 to Azure Instance 1"
  type        = string
  sensitive   = true
  default     = ""
}
