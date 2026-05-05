# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for license information.

# Default Example — Greenfield S2S VPN
#
# Creates a new AWS VPC + VPG and connects to a new Azure VNet via
# active-active VPN Gateway with BGP and 4 IPsec tunnels.

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

  azure_location   = "West Europe"
  aws_scenario     = "greenfield"
  enable_telemetry = var.enable_telemetry

  tunnel1_instance0_psk = random_password.tunnel_psks[0].result
  tunnel2_instance0_psk = random_password.tunnel_psks[1].result
  tunnel1_instance1_psk = random_password.tunnel_psks[2].result
  tunnel2_instance1_psk = random_password.tunnel_psks[3].result

  tags = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Example     = "default"
  }
}
