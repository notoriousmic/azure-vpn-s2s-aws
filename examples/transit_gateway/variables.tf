variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

variable "aws_transit_gateway_id" {
  type        = string
  description = "ID of an existing AWS Transit Gateway"
}

variable "aws_vpc_id" {
  type        = string
  description = "ID of an existing AWS VPC"
}
