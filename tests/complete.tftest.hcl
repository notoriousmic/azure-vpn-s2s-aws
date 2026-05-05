# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for license information.

# ==============================================================================
# Complete Test — Plan smoke test for the complete example.
# ==============================================================================

run "setup" {
  command = plan

  module {
    source = "./examples/complete"
  }
}
