# Azure-AWS Site-to-Site VPN — AVM Pattern Module

This Terraform module deploys a Site-to-Site VPN between Azure and AWS with BGP and active-active redundancy. It supports four AWS-side deployment scenarios based on the [AWS blog post](https://aws.amazon.com/blogs/modernizing-with-aws/designing-private-network-connectivity-aws-azure/).

## Supported Scenarios

| Scenario | `aws_scenario` | Creates on AWS | Use Case |
|---|---|---|---|
| **Greenfield** | `greenfield` | VPC + VPG + Subnets + NAT | Start from scratch |
| **Transit Gateway** | `transit_gateway` | VPN attachment to existing TGW | Multi-VPC hub connectivity |
| **Existing VPC** | `existing_vpc` | VPG on existing VPC | Add Azure VPN to existing VPC |
| **Existing VPG** | `existing_vpg` | CGWs + VPN connections only | BYO VPC + VPG |

Azure side always creates: VNet + active-active VPN Gateway (2 PIPs) + 4 Local Network Gateways + 4 IPsec connections with BGP.

## Architecture — Greenfield (Single VPC + VPG)

```
┌──────────────────────────────────────┐       ┌──────────────────────────────────────┐
│            Azure                     │       │              AWS                     │
│                                      │       │                                      │
│  ┌──────────────────────────────┐    │       │    ┌──────────────────────────────┐  │
│  │  VNet (10.1.0.0/16)         │    │       │    │  VPC (10.2.0.0/16)           │  │
│  │  ┌────────────────────────┐ │    │       │    │  ┌──────────┐ ┌──────────┐   │  │
│  │  │ GatewaySubnet          │ │    │       │    │  │ Subnet 1 │ │ Subnet 2 │   │  │
│  │  │ 10.1.255.0/27          │ │    │       │    │  └──────────┘ └──────────┘   │  │
│  │  └────────────────────────┘ │    │       │    └──────────────────────────────┘  │
│  └──────────────────────────────┘    │       │                                      │
│                                      │       │                                      │
│  ┌──────────┐  ┌──────────┐          │       │    ┌───────────────────────────┐     │
│  │ Public   │  │ Public   │          │       │    │ Virtual Private Gateway   │     │
│  │ IP 1     │  │ IP 2     │          │       │    │ (BGP ASN: 64512)          │     │
│  └────┬─────┘  └────┬─────┘          │       │    └─────────┬─────────────────┘     │
│       │              │               │       │              │                       │
│  ┌────┴──────────────┴────┐          │       │    ┌─────────┴───────────┐           │
│  │ VPN Gateway            │          │       │    │ Customer Gateways   │           │
│  │ (Active-Active, BGP)   │◄────IPsec Tunnels────►│ (×2, to Azure PIPs) │           │
│  │ ASN: 65000             │   (×4 with APIPA)│    └─────────────────────┘           │
│  └────────────────────────┘          │       │                                      │
└──────────────────────────────────────┘       └──────────────────────────────────────┘
```

## Architecture — Transit Gateway (Multi-VPC Hub)

```
┌───────────────────────┐                          ┌─────────────────────────────────┐
│        Azure          │                          │              AWS                │
│                       │                          │                                 │
│  ┌─────────────────┐  │                          │  ┌───────┐ ┌───────┐ ┌───────┐ │
│  │ VNet            │  │                          │  │ VPC A │ │ VPC B │ │ VPC C │ │
│  └────────┬────────┘  │                          │  └───┬───┘ └───┬───┘ └───┬───┘ │
│           │           │                          │      └────┬────┘────┬────┘     │
│  ┌────────┴────────┐  │    4 IPsec Tunnels       │  ┌────────┴────────┐           │
│  │ VPN Gateway     │  │◄─────────────────────────┤  │ Transit Gateway │           │
│  │ (Active-Active) │  │    (BGP over APIPA)      │  │ (Hub Router)    │           │
│  └─────────────────┘  │                          │  └─────────────────┘           │
└───────────────────────┘                          └─────────────────────────────────┘
```

---

## Usage Guide

### Which scenario should I pick?

```
Do you have an existing AWS VPC?
├── No  → use "greenfield"
└── Yes
    ├── Do you want to connect multiple VPCs through a Transit Gateway?
    │   └── Yes → use "transit_gateway"
    │
    └── Single VPC only
        ├── Do you already have a Virtual Private Gateway on that VPC?
        │   ├── No  → use "existing_vpc"
        │   └── Yes → use "existing_vpg"
```

---

### Scenario A: Greenfield — "I'm starting from scratch"

This is the simplest option. The module creates **everything** on both the Azure and AWS sides.

**What you need:** Just your PSKs (pre-shared keys) and optionally custom CIDR ranges.

```hcl
module "vpn" {
  source = "Azure/avm-ptn-azure-aws-s2s-vpn/azurerm"

  azure_location = "West Europe"
  aws_scenario   = "greenfield"     # ← this is the default, you can omit it

  # Optional: customize the IP ranges (defaults shown)
  # aws_vpc_cidr             = "10.2.0.0/16"
  # azure_vnet_address_space = ["10.1.0.0/16"]

  # Required: VPN tunnel secrets (use random_password or openssl rand -base64 32)
  tunnel1_instance0_psk = "YourSecretKey1"
  tunnel2_instance0_psk = "YourSecretKey2"
  tunnel1_instance1_psk = "YourSecretKey3"
  tunnel2_instance1_psk = "YourSecretKey4"
}
```

**What gets created:**

| Azure | AWS |
|---|---|
| Resource Group | VPC with 2 subnets |
| VNet + GatewaySubnet | NAT Gateway + Elastic IP |
| VPN Gateway (active-active) | Virtual Private Gateway |
| 2 Public IPs | 2 Customer Gateways |
| 4 Local Network Gateways | 2 VPN Connections (4 tunnels) |
| 4 IPsec Connections | Route Table + Security Group |
| NSG | |

---

### Scenario B: Transit Gateway — "I have a multi-VPC setup with a Transit Gateway"

Use this when your AWS account already has a [Transit Gateway](https://aws.amazon.com/transit-gateway/) acting as a hub for multiple VPCs, and you want Azure to be reachable from all of them.

**What you need:** Your existing Transit Gateway ID.

```hcl
module "vpn" {
  source = "Azure/avm-ptn-azure-aws-s2s-vpn/azurerm"

  azure_location = "East US"
  aws_scenario   = "transit_gateway"

  # Point to your existing Transit Gateway
  aws_transit_gateway_id = "tgw-0abc123def456789"
  aws_vpc_id             = "vpc-0abc123def456789"   # any VPC for tagging context

  # Required: VPN tunnel secrets
  tunnel1_instance0_psk = "YourSecretKey1"
  tunnel2_instance0_psk = "YourSecretKey2"
  tunnel1_instance1_psk = "YourSecretKey3"
  tunnel2_instance1_psk = "YourSecretKey4"
}
```

> **Tip:** After deployment, the VPN connection will appear as a VPN attachment on your Transit Gateway. Make sure your TGW route tables propagate the Azure routes to the VPCs that need access.

**What gets created:**

| Azure | AWS |
|---|---|
| Resource Group | 2 Customer Gateways |
| VNet + GatewaySubnet | 2 VPN Connections → TGW |
| VPN Gateway (active-active) | *(TGW attachment auto-created)* |
| 2 Public IPs | |
| 4 Local Network Gateways | |
| 4 IPsec Connections | |
| NSG | |

---

### Scenario C: Existing VPC — "I have a VPC but no VPN Gateway yet"

Use this when you already have a VPC (with workloads running) and want to add Azure connectivity to it.

**What you need:** Your VPC ID and the route table ID where VPN routes should be propagated.

```hcl
module "vpn" {
  source = "Azure/avm-ptn-azure-aws-s2s-vpn/azurerm"

  azure_location = "West Europe"
  aws_scenario   = "existing_vpc"

  # Point to your existing VPC
  aws_vpc_id         = "vpc-0abc123def456789"
  aws_route_table_id = "rtb-0abc123def456789"   # routes to Azure will be auto-propagated

  # Required: VPN tunnel secrets
  tunnel1_instance0_psk = "YourSecretKey1"
  tunnel2_instance0_psk = "YourSecretKey2"
  tunnel1_instance1_psk = "YourSecretKey3"
  tunnel2_instance1_psk = "YourSecretKey4"
}
```

**What gets created:**

| Azure | AWS |
|---|---|
| Resource Group | Virtual Private Gateway (on your VPC) |
| VNet + GatewaySubnet | Route propagation to your route table |
| VPN Gateway (active-active) | 2 Customer Gateways |
| 2 Public IPs | 2 VPN Connections (4 tunnels) |
| 4 Local Network Gateways | |
| 4 IPsec Connections | |
| NSG | |

---

### Scenario D: Existing VPG — "I already have a VPC and a Virtual Private Gateway"

The lightest option. The module only creates the VPN tunnel infrastructure — Customer Gateways and VPN connections on AWS, plus the full Azure side.

**What you need:** Your VPC ID, VPG ID, and route table ID.

```hcl
module "vpn" {
  source = "Azure/avm-ptn-azure-aws-s2s-vpn/azurerm"

  azure_location = "West Europe"
  aws_scenario   = "existing_vpg"

  # Point to your existing resources
  aws_vpc_id          = "vpc-0abc123def456789"
  aws_vpn_gateway_id  = "vgw-0abc123def456789"
  aws_route_table_id  = "rtb-0abc123def456789"

  # Match the ASN of your existing VPG
  aws_vpn_gateway_asn = 64512

  # Required: VPN tunnel secrets
  tunnel1_instance0_psk = "YourSecretKey1"
  tunnel2_instance0_psk = "YourSecretKey2"
  tunnel1_instance1_psk = "YourSecretKey3"
  tunnel2_instance1_psk = "YourSecretKey4"
}
```

**What gets created:**

| Azure | AWS |
|---|---|
| Resource Group | 2 Customer Gateways |
| VNet + GatewaySubnet | 2 VPN Connections (4 tunnels) |
| VPN Gateway (active-active) | |
| 2 Public IPs | |
| 4 Local Network Gateways | |
| 4 IPsec Connections | |
| NSG | |

---

### Generating secure pre-shared keys

The PSKs are shared secrets used to encrypt the VPN tunnels. Generate them with:

```bash
# Option 1: OpenSSL (recommended)
openssl rand -base64 32

# Option 2: In Terraform itself (see examples/default/)
resource "random_password" "tunnel_psks" {
  count   = 4
  length  = 32
  special = false
}
```

> **Important:** Never commit PSKs to version control. Use `terraform.tfvars` (git-ignored), environment variables, or a secrets manager.
