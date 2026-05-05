# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for license information.

# ==============================================================================
# Default Test — Plan smoke test for the default example.
# ==============================================================================

run "setup" {
  command = plan

  module {
    source = "./examples/default"
  }
}
