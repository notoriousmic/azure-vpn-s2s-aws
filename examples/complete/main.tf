# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for license information.

# Complete Example — Greenfield S2S VPN with All Options
#
# Creates a new AWS VPC + VPG and connects to Azure with all
# optional variables explicitly configured.

terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6, < 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "aws" {
  region = "eu-west-1"
}

# Generate random pre-shared keys for VPN tunnels
resource "random_password" "tunnel_psks" {
  count   = 4
  length  = 32
  special = false
}

module "azure_aws_vpn" {
  source = "../../"

  # General
  aws_scenario     = "greenfield"
  name_prefix      = "myproject"
  environment      = "staging"
  enable_telemetry = var.enable_telemetry

  # Azure networking
  azure_location              = "West Europe"
  azure_vnet_address_space    = ["10.10.0.0/16"]
  azure_gateway_subnet_prefix = ["10.10.255.0/27"]

  # Azure VPN Gateway
  azure_vpn_gateway_sku        = "VpnGw2AZ"
  azure_vpn_gateway_generation = "Generation2"
  azure_bgp_asn                = 65010
  azure_availability_zones     = ["1", "2", "3"]

  # AWS networking
  aws_region          = "eu-west-1"
  aws_vpc_cidr        = "10.20.0.0/16"
  aws_vpn_gateway_asn = 64600

  # VPN tunnel pre-shared keys
  tunnel1_instance0_psk = random_password.tunnel_psks[0].result
  tunnel2_instance0_psk = random_password.tunnel_psks[1].result
  tunnel1_instance1_psk = random_password.tunnel_psks[2].result
  tunnel2_instance1_psk = random_password.tunnel_psks[3].result

  tags = {
    Environment = "staging"
    ManagedBy   = "Terraform"
    Example     = "complete"
    CostCenter  = "engineering"
  }
}
