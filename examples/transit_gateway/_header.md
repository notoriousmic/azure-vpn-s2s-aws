# Transit Gateway Example — Multi-VPC Hub

Connects Azure to an existing AWS Transit Gateway for multi-VPC connectivity:

- VPN attaches to an existing Transit Gateway (not a VPG)
- No VPC or VPG is created on the AWS side
- Azure side creates VNet + active-active VPN Gateway
- Ideal for hub-spoke AWS networks connecting to Azure

> **Note:** You must provide an existing `aws_transit_gateway_id` and `aws_vpc_id`.
