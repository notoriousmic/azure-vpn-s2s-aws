output "resource_group_name" {
  value = module.azure_aws_vpn.resource_group_name
}

output "aws_scenario" {
  value = module.azure_aws_vpn.aws_scenario
}

output "azure_vpn_gateway_name" {
  value = module.azure_aws_vpn.azure_vpn_gateway_name
}

output "azure_vpn_gateway_public_ip_1" {
  value = module.azure_aws_vpn.azure_vpn_gateway_public_ip_1
}

output "azure_vpn_gateway_public_ip_2" {
  value = module.azure_aws_vpn.azure_vpn_gateway_public_ip_2
}

output "aws_vpc_id" {
  value = module.azure_aws_vpn.aws_vpc_id
}

output "aws_vpn_gateway_id" {
  value = module.azure_aws_vpn.aws_vpn_gateway_id
}

output "bgp_apipa_configuration" {
  value = module.azure_aws_vpn.bgp_apipa_configuration
}
