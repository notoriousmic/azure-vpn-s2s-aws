# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for license information.

# ==============================================================================
# Transit Gateway Test — Plan smoke test for the transit_gateway example.
# ==============================================================================

run "setup" {
  command = plan

  module {
    source = "./examples/transit_gateway"
  }

  variables {
    aws_transit_gateway_id = "tgw-0123456789abcdef0"
    aws_vpc_id             = "vpc-0123456789abcdef0"
  }
}
