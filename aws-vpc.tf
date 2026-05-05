# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for license information.

# ==============================================================================
# AWS VPC Resources (greenfield scenario only)
# ==============================================================================

# Create a VPC (greenfield only)
resource "aws_vpc" "this" {
  count = local.create_vpc ? 1 : 0

  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    {
      Name = local.aws_vpc_name
    }
  )
}

# Elastic IP for NAT Gateway (greenfield only)
resource "aws_eip" "nat" {
  count = local.create_vpc ? 1 : 0

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.aws_vpc_name}-nat-eip"
    }
  )

  depends_on = [aws_vpc.this]
}

# NAT Gateway (greenfield only)
resource "aws_nat_gateway" "main" {
  count = local.create_vpc ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.subnet1[0].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.aws_vpc_name}-nat-gw"
    }
  )

  depends_on = [aws_eip.nat]
}

# Create subnet 1 (greenfield only)
resource "aws_subnet" "subnet1" {
  count = local.create_vpc ? 1 : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = cidrsubnet(var.aws_vpc_cidr, 8, 1)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.aws_vpc_name}-subnet-1"
    }
  )
}

# Create subnet 2 (greenfield only)
resource "aws_subnet" "subnet2" {
  count = local.create_vpc ? 1 : 0

  vpc_id            = aws_vpc.this[0].id
  cidr_block        = cidrsubnet(var.aws_vpc_cidr, 8, 2)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.aws_vpc_name}-subnet-2"
    }
  )
}

# Create a route table (greenfield only)
resource "aws_route_table" "main" {
  count = local.create_vpc ? 1 : 0

  vpc_id = aws_vpc.this[0].id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${local.aws_vpc_name}-rt"
    }
  )
}

# Associate subnet 1 with the route table (greenfield only)
resource "aws_route_table_association" "subnet1" {
  count = local.create_vpc ? 1 : 0

  subnet_id      = aws_subnet.subnet1[0].id
  route_table_id = aws_route_table.main[0].id
}

# Associate subnet 2 with the route table (greenfield only)
resource "aws_route_table_association" "subnet2" {
  count = local.create_vpc ? 1 : 0

  subnet_id      = aws_subnet.subnet2[0].id
  route_table_id = aws_route_table.main[0].id
}

# ==============================================================================
# AWS Virtual Private Gateway (greenfield + existing_vpc scenarios)
# ==============================================================================

resource "aws_vpn_gateway" "this" {
  count = local.create_vpg ? 1 : 0

  vpc_id          = local.vpc_id
  amazon_side_asn = var.aws_vpn_gateway_asn

  tags = merge(
    local.common_tags,
    {
      Name = local.aws_vpn_gateway_name
    }
  )
}

# Enable route propagation for the VPN gateway
resource "aws_vpn_gateway_route_propagation" "main" {
  count = local.create_vpg && local.route_table_id != "" ? 1 : 0

  vpn_gateway_id = aws_vpn_gateway.this[0].id
  route_table_id = local.route_table_id
}

# ==============================================================================
# AWS Security Group (greenfield only — existing VPC users manage their own SGs)
# ==============================================================================

resource "aws_security_group" "vpn_traffic" {
  count = local.create_vpc ? 1 : 0

  name        = "${local.aws_vpc_name}-vpn-sg"
  description = "Allow traffic between AWS VPC and Azure VNet"
  vpc_id      = aws_vpc.this[0].id

  ingress {
    description = "Allow all traffic from AWS VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.aws_vpc_cidr]
  }

  ingress {
    description = "Allow all traffic from Azure VNet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.azure_vnet_address_space
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.aws_vpc_name}-vpn-sg"
    }
  )
}