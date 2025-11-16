# ============================================================================
# AWS VPC Resources
# ============================================================================

# Create a VPC
resource "aws_vpc" "vpc1" {
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

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.aws_vpc_name}-nat-eip"
    }
  )

  depends_on = [aws_vpc.vpc1]
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet1.id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.aws_vpc_name}-nat-gw"
    }
  )

  depends_on = [aws_eip.nat]
}

# Create subnet 1
resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = cidrsubnet(var.aws_vpc_cidr, 8, 1)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.aws_vpc_name}-subnet-1"
    }
  )
}

# Create subnet 2
resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = cidrsubnet(var.aws_vpc_cidr, 8, 2)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.aws_vpc_name}-subnet-2"
    }
  )
}

# Create a route table
resource "aws_route_table" "main" {
  vpc_id = aws_vpc.vpc1.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${local.aws_vpc_name}-rt"
    }
  )
}

# Associate subnet 1 with the route table
resource "aws_route_table_association" "subnet1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.main.id
}

# Associate subnet 2 with the route table
resource "aws_route_table_association" "subnet2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.main.id
}

# Create a virtual private gateway
resource "aws_vpn_gateway" "azure_gw" {
  vpc_id          = aws_vpc.vpc1.id
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
  vpn_gateway_id = aws_vpn_gateway.azure_gw.id
  route_table_id = aws_route_table.main.id
}

# Security Group - Allow traffic from AWS VPC and Azure VNet
resource "aws_security_group" "vpn_traffic" {
  name        = "${local.aws_vpc_name}-vpn-sg"
  description = "Allow traffic between AWS VPC and Azure VNet"
  vpc_id      = aws_vpc.vpc1.id

  # Allow all inbound traffic from AWS VPC
  ingress {
    description = "Allow all traffic from AWS VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.aws_vpc_cidr]
  }

  # Allow all inbound traffic from Azure VNet
  ingress {
    description = "Allow all traffic from Azure VNet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.azure_vnet_address_space
  }

  # Allow all outbound traffic
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