# PRD: Azure-AWS Site-to-Site VPN — AVM Pattern Module

| Field            | Value                                                  |
|------------------|--------------------------------------------------------|
| **Module Name**  | `terraform-azurerm-avm-ptn-azure-aws-s2s-vpn`         |
| **Type**         | AVM Pattern Module                                     |
| **Status**       | Implementation Complete                                |
| **Created**      | 2026-05-05                                             |
| **Last Updated** | 2026-05-05                                             |

---

## 1. Objective

Deploy a Site-to-Site VPN between Azure and AWS with BGP, active-active redundancy, and support for four AWS-side deployment scenarios as described in the [AWS blog post](https://aws.amazon.com/blogs/modernizing-with-aws/designing-private-network-connectivity-aws-azure/).

---

## 2. Supported Scenarios

| # | Scenario | `aws_scenario` | AWS Resources Created | Use Case |
|---|---|---|---|---|
| A | **Greenfield** | `greenfield` | VPC + VPG + Subnets + NAT + SG + Route Table | Start from scratch — single VPC to Azure |
| B | **Transit Gateway** | `transit_gateway` | CGWs + TGW VPN attachments only | Multi-VPC hub — connect Azure to existing AWS backbone |
| C | **Existing VPC** | `existing_vpc` | VPG + CGWs + VPN connections | Customer has VPC, add Azure VPN connectivity |
| D | **Existing VPG** | `existing_vpg` | CGWs + VPN connections only | Customer has VPC + VPG, only create VPN tunnels |

**Azure side is identical for all scenarios:** VNet + GatewaySubnet + active-active VPN Gateway (2 PIPs) + 4 Local Network Gateways + 4 IPsec connections with BGP over APIPA.

---

## 3. Architecture

### Conditional Resource Creation Matrix

| Resource | greenfield | transit_gateway | existing_vpc | existing_vpg |
|---|:---:|:---:|:---:|:---:|
| AWS VPC | ✅ | ❌ | ❌ | ❌ |
| AWS Subnets + NAT + RT | ✅ | ❌ | ❌ | ❌ |
| AWS Security Group | ✅ | ❌ | ❌ | ❌ |
| AWS Virtual Private Gateway | ✅ | ❌ | ✅ | ❌ |
| AWS VPG Route Propagation | ✅ | ❌ | ✅ | ❌ |
| AWS Customer Gateways (×2) | ✅ | ✅ | ✅ | ✅ |
| AWS VPN Connections (VPG) | ✅ | ❌ | ✅ | ✅ |
| AWS VPN Connections (TGW) | ❌ | ✅ | ❌ | ❌ |
| Azure Resource Group | ✅ | ✅ | ✅ | ✅ |
| Azure VNet + GatewaySubnet | ✅ | ✅ | ✅ | ✅ |
| Azure NSG | ✅ | ✅ | ✅ | ✅ |
| Azure VPN Gateway (active-active) | ✅ | ✅ | ✅ | ✅ |
| Azure Local Network Gateways (×4) | ✅ | ✅ | ✅ | ✅ |
| Azure VPN Connections (×4) | ✅ | ✅ | ✅ | ✅ |

---

## 4. Key Variables

| Variable | Required For | Description |
|---|---|---|
| `azure_location` | All | Azure region |
| `aws_scenario` | All | `greenfield`, `transit_gateway`, `existing_vpc`, `existing_vpg` |
| `aws_vpc_cidr` | greenfield | CIDR for new VPC |
| `aws_vpc_id` | transit_gateway, existing_vpc, existing_vpg | Existing VPC ID |
| `aws_route_table_id` | existing_vpc, existing_vpg | Existing route table for propagation |
| `aws_vpn_gateway_id` | existing_vpg | Existing VPG ID |
| `aws_transit_gateway_id` | transit_gateway | Existing TGW ID |
| `tunnel*_instance*_psk` | All | Pre-shared keys for IPsec tunnels |

---

## 5. Implementation Progress

### Phase 1: AVM Scaffolding
| # | Task | Status |
|---|---|---|
| 1.1 | AVM boilerplate (`telemetry.tf`, `_header.md`, `_footer.md`, `.terraform-docs.yml`) | ✅ Done |
| 1.2 | Copyright headers on all `.tf` files | ✅ Done |
| 1.3 | `terraform.tf` with AVM version constraints | ✅ Done |
| 1.4 | `enable_telemetry` variable | ✅ Done |
| 1.5 | `main.tf` with resource group only | ✅ Done |
| 1.6 | `modules/` directory | ✅ Done |
| 1.7 | Community files (CODE_OF_CONDUCT, CONTRIBUTING, SECURITY, SUPPORT) | ✅ Done |

### Phase 2: Core Module — 4 Scenarios
| # | Task | Status |
|---|---|---|
| 2.1 | `variables.tf` — `aws_scenario`, BYO IDs, validations | ✅ Done |
| 2.2 | `locals.tf` — `create_vpc`, `create_vpg`, `use_tgw` flags, unified `vpc_id`/`vpg_id` | ✅ Done |
| 2.3 | `aws-vpc.tf` — conditional VPC, subnets, NAT, VPG, SG | ✅ Done |
| 2.4 | `aws-vpn.tf` — CGWs (always), VPG VPN connections, TGW VPN connections, unified locals | ✅ Done |
| 2.5 | `azure-vpn-gateway.tf` — always-on VPN Gateway (no count) | ✅ Done |
| 2.6 | `azure-connections.tf` — LNGs + connections using unified `local.vpn_connection_*` | ✅ Done |
| 2.7 | `outputs.tf` — scenario-aware outputs | ✅ Done |

### Phase 3: Examples
| # | Task | Status |
|---|---|---|
| 3.1 | `examples/default/` — greenfield with auto PSKs | ✅ Done |
| 3.2 | `examples/complete/` — greenfield with all options | ✅ Done |
| 3.3 | `examples/transit_gateway/` — TGW with BYO IDs | ✅ Done |

### Phase 4: Tests
| # | Task | Status |
|---|---|---|
| 4.1 | `tests/default.tftest.hcl` | ✅ Done |
| 4.2 | `tests/complete.tftest.hcl` | ✅ Done |
| 4.3 | `tests/transit_gateway.tftest.hcl` | ✅ Done |

### Phase 5: Documentation
| # | Task | Status |
|---|---|---|
| 5.1 | `_header.md` with architecture diagrams | ✅ Done |
| 5.2 | `_footer.md` with data collection notice | ✅ Done |
| 5.3 | `.terraform-docs.yml` | ✅ Done |
| 5.4 | `terraform.tfvars.example` for all scenarios | ✅ Done |
| 5.5 | Generate README.md | ⬜ Pending (run `terraform-docs`) |

---

## 6. Out of Scope

- **ExpressRoute / Direct Connect** patterns — removed; may be a separate module
- **Multi-VPC creation** — module connects to one TGW; VPC creation is user's responsibility
- **Azure Virtual WAN** — separate module candidate
- **Automated PSK generation** — left to consumer (examples use `random_password`)

---

## 7. Success Criteria

- [x] Module supports all 4 AWS scenarios via `aws_scenario` variable
- [x] All `.tf` files have copyright headers
- [x] `enable_telemetry` and `telemetry.tf` present
- [x] 3 examples with proper AVM structure
- [x] 3 test files with plan-only smoke tests
- [x] Variables have validation blocks
- [x] Sensitive values marked `sensitive = true`
- [ ] `terraform validate` passes for all scenarios
- [ ] README auto-generated via terraform-docs

