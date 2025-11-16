# Using This Project as a Terraform Module

This project can be used as a reusable Terraform module to create site-to-site VPN connections between Azure and AWS with BGP routing.

## Module Usage

### Basic Example

```hcl
module "azure_aws_vpn" {
  source = "github.com/notoriousmic/azure-vpn-s2s-aws"

  # General settings
  project_name = "my-vpn"
  environment  = "prod"

  # Azure configuration
  azure_location            = "West Europe"
  azure_vnet_address_space  = ["10.1.0.0/16"]
  azure_gateway_subnet_prefix = ["10.1.255.0/27"]

  # AWS configuration
  aws_region   = "us-east-1"
  aws_vpc_cidr = "10.2.0.0/16"

  # VPN Pre-Shared Keys (sensitive!)
  vpn_tunnel_1_psk = "YourSecureKey1"
  vpn_tunnel_2_psk = "YourSecureKey2"
  vpn_tunnel_3_psk = "YourSecureKey3"
  vpn_tunnel_4_psk = "YourSecureKey4"

  tags = {
    Owner       = "Platform Team"
    CostCenter  = "Infrastructure"
  }
}
```

### Advanced Example with Custom SKU

```hcl
module "azure_aws_vpn_ha" {
  source = "github.com/notoriousmic/azure-vpn-s2s-aws"

  project_name = "enterprise-vpn"
  environment  = "production"

  # Azure configuration - higher performance
  azure_location               = "North Europe"
  azure_vnet_address_space     = ["172.16.0.0/16"]
  azure_gateway_subnet_prefix  = ["172.16.255.0/27"]
  azure_vpn_gateway_sku        = "VpnGw3AZ"  # Higher performance tier
  azure_vpn_gateway_generation = "Generation2"
  azure_bgp_asn                = 65100

  # AWS configuration - different region
  aws_region          = "eu-west-1"
  aws_vpc_cidr        = "172.17.0.0/16"
  aws_vpn_gateway_asn = 64600

  # Pre-shared keys from secrets management
  vpn_tunnel_1_psk = var.vpn_psk_1
  vpn_tunnel_2_psk = var.vpn_psk_2
  vpn_tunnel_3_psk = var.vpn_psk_3
  vpn_tunnel_4_psk = var.vpn_psk_4

  tags = {
    Environment = "production"
    Compliance  = "PCI-DSS"
    Team        = "networking"
  }
}

# Access module outputs
output "vpn_public_ips" {
  value = {
    azure_ip_1 = module.azure_aws_vpn_ha.azure_vpn_gateway_public_ip_1
    azure_ip_2 = module.azure_aws_vpn_ha.azure_vpn_gateway_public_ip_2
  }
}

output "bgp_configuration" {
  value = module.azure_aws_vpn_ha.bgp_apipa_configuration
}
```

### Using with Terraform Registry (if published)

If you publish this module to the Terraform Registry:

```hcl
module "azure_aws_vpn" {
  source  = "notoriousmic/azure-aws-vpn/azurerm"
  version = "~> 1.0"

  # ... configuration ...
}
```

### Using with Git Reference

```hcl
# Specific branch
module "azure_aws_vpn" {
  source = "git::https://github.com/notoriousmic/azure-vpn-s2s-aws.git?ref=main"
  # ... configuration ...
}

# Specific tag/version
module "azure_aws_vpn" {
  source = "git::https://github.com/notoriousmic/azure-vpn-s2s-aws.git?ref=v1.0.0"
  # ... configuration ...
}

# Specific commit
module "azure_aws_vpn" {
  source = "git::https://github.com/notoriousmic/azure-vpn-s2s-aws.git?ref=abc123"
  # ... configuration ...
}
```

## Module Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project, used as prefix | `string` | `"azure-aws-vpn"` | no |
| environment | Environment name | `string` | `"prod"` | no |
| tags | Additional tags for all resources | `map(string)` | `{}` | no |
| azure_location | Azure region | `string` | `"West Europe"` | no |
| azure_vnet_address_space | Azure VNet address space | `list(string)` | `["10.1.0.0/16"]` | no |
| azure_gateway_subnet_prefix | Gateway subnet prefix | `list(string)` | `["10.1.255.0/27"]` | no |
| azure_vpn_gateway_sku | VPN Gateway SKU | `string` | `"VpnGw2AZ"` | no |
| azure_vpn_gateway_generation | Gateway generation | `string` | `"Generation2"` | no |
| azure_bgp_asn | Azure BGP ASN | `number` | `65000` | no |
| azure_availability_zones | Availability zones | `list(string)` | `["1", "2", "3"]` | no |
| aws_region | AWS region | `string` | `"us-east-1"` | no |
| aws_vpc_cidr | AWS VPC CIDR | `string` | `"10.2.0.0/16"` | no |
| aws_vpn_gateway_asn | AWS BGP ASN | `number` | `64512` | no |
| vpn_tunnel_1_psk | Pre-shared key for tunnel 1 | `string` | n/a | **yes** |
| vpn_tunnel_2_psk | Pre-shared key for tunnel 2 | `string` | n/a | **yes** |
| vpn_tunnel_3_psk | Pre-shared key for tunnel 3 | `string` | n/a | **yes** |
| vpn_tunnel_4_psk | Pre-shared key for tunnel 4 | `string` | n/a | **yes** |

## Module Outputs

| Name | Description |
|------|-------------|
| azure_resource_group_name | Azure resource group name |
| azure_vnet_name | Azure VNet name |
| azure_vnet_address_space | Azure VNet address space |
| azure_vpn_gateway_name | Azure VPN Gateway name |
| azure_vpn_gateway_id | Azure VPN Gateway ID |
| azure_vpn_gateway_public_ip_1 | First Azure VPN Gateway public IP |
| azure_vpn_gateway_public_ip_2 | Second Azure VPN Gateway public IP |
| azure_bgp_asn | Azure BGP ASN |
| azure_bgp_peering_addresses | Azure BGP peering addresses |
| azure_nsg_id | Azure Network Security Group ID |
| aws_vpc_id | AWS VPC ID |
| aws_vpc_cidr | AWS VPC CIDR block |
| aws_subnet_ids | AWS subnet IDs |
| aws_vpn_gateway_id | AWS Virtual Private Gateway ID |
| aws_vpn_connection_ids | AWS VPN connection IDs |
| aws_nat_gateway_id | AWS NAT Gateway ID |
| aws_security_group_id | AWS Security Group ID |
| bgp_apipa_configuration | Complete BGP APIPA configuration |
| connection_summary | Summary of all VPN connections |

## Provider Configuration

When using this module, you need to configure both Azure and AWS providers in your root module:

```hcl
provider "azurerm" {
  features {}
  # subscription_id = "your-subscription-id"  # Optional
}

provider "aws" {
  region = "us-east-1"  # Should match module's aws_region
  # profile = "your-aws-profile"  # Optional
}

module "azure_aws_vpn" {
  source = "github.com/notoriousmic/azure-vpn-s2s-aws"
  # ... configuration ...
}
```

## Security Considerations

1. **Pre-Shared Keys**: Never commit PSKs to version control. Use:
   - Environment variables
   - Terraform Cloud/Enterprise workspace variables
   - AWS Secrets Manager / Azure Key Vault
   - HashiCorp Vault

2. **Example with environment variables**:
   ```bash
   export TF_VAR_vpn_tunnel_1_psk="your-secure-key-1"
   export TF_VAR_vpn_tunnel_2_psk="your-secure-key-2"
   export TF_VAR_vpn_tunnel_3_psk="your-secure-key-3"
   export TF_VAR_vpn_tunnel_4_psk="your-secure-key-4"
   terraform apply
   ```

3. **Example with secrets file** (add to `.gitignore`):
   ```hcl
   # secrets.auto.tfvars (DO NOT COMMIT!)
   vpn_tunnel_1_psk = "your-secure-key-1"
   vpn_tunnel_2_psk = "your-secure-key-2"
   vpn_tunnel_3_psk = "your-secure-key-3"
   vpn_tunnel_4_psk = "your-secure-key-4"
   ```

## Multi-Environment Usage

```hcl
# environments/dev/main.tf
module "vpn" {
  source = "../../"  # Local path

  project_name = "myapp"
  environment  = "dev"
  
  azure_vpn_gateway_sku = "VpnGw1AZ"  # Lower cost for dev
  
  # ... other config ...
}

# environments/prod/main.tf
module "vpn" {
  source = "../../"  # Local path

  project_name = "myapp"
  environment  = "prod"
  
  azure_vpn_gateway_sku = "VpnGw3AZ"  # Higher performance for prod
  
  # ... other config ...
}
```

## Dependencies

This module requires:
- Terraform >= 1.0
- Azure provider >= 4.1.0
- AWS provider >= 5.0

## Deployment Time

Initial deployment takes approximately **45-60 minutes** due to:
- Azure VPN Gateway creation: ~40-45 minutes
- AWS VPN Connection establishment: ~5-10 minutes
- BGP session establishment: ~2-5 minutes

## Cost Estimation

Base monthly costs (excluding data transfer):
- Azure VPN Gateway (VpnGw2AZ): ~$350
- Azure Public IPs (2): ~$7
- AWS VPN Connections (2): ~$72
- AWS NAT Gateway: ~$32
- **Total**: ~$461/month

## Troubleshooting

See the main [README.md](README.md#troubleshooting) for detailed troubleshooting steps.

## License

See [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Support

For issues and questions:
- GitHub Issues: https://github.com/notoriousmic/azure-vpn-s2s-aws/issues
- Documentation: [README.md](README.md)
