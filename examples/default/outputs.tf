output "resource_group_name" {
  value = module.azure_aws_vpn.resource_group_name
}

output "aws_scenario" {
  value = module.azure_aws_vpn.aws_scenario
}

output "azure_vpn_gateway_name" {
  value = module.azure_aws_vpn.azure_vpn_gateway_name
}

output "aws_vpc_id" {
  value = module.azure_aws_vpn.aws_vpc_id
}
