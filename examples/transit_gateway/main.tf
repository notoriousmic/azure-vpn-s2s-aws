# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for license information.

# Transit Gateway Example — Multi-VPC Hub
#
# Connects Azure to an existing AWS Transit Gateway.
# No VPC or VPG is created; VPN connections attach directly to the TGW.

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
  region = "us-east-1"
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
  aws_scenario     = "transit_gateway"
  name_prefix      = "hub-vpn"
  environment      = "prod"
  enable_telemetry = var.enable_telemetry

  # Azure networking
  azure_location              = "East US"
  azure_vnet_address_space    = ["10.1.0.0/16"]
  azure_gateway_subnet_prefix = ["10.1.255.0/27"]

  # AWS — existing Transit Gateway
  aws_region             = "us-east-1"
  aws_transit_gateway_id = var.aws_transit_gateway_id
  aws_vpc_id             = var.aws_vpc_id
  aws_vpn_gateway_asn    = 64512

  # VPN tunnel pre-shared keys
  tunnel1_instance0_psk = random_password.tunnel_psks[0].result
  tunnel2_instance0_psk = random_password.tunnel_psks[1].result
  tunnel1_instance1_psk = random_password.tunnel_psks[2].result
  tunnel2_instance1_psk = random_password.tunnel_psks[3].result

  tags = {
    Environment = "prod"
    ManagedBy   = "Terraform"
    Example     = "transit_gateway"
  }
}
