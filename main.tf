# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See LICENSE file in the project root for license information.

# ==============================================================================
# Resource Group
# ==============================================================================

resource "azurerm_resource_group" "this" {
  location = var.azure_location
  name     = local.azure_resource_group_name
  tags     = local.common_tags
}
