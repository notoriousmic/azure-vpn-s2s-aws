---
description: "Azure Verified Modules (AVM) and Terraform"
applyTo: "**/*.terraform, **/*.tf, **/*.tfvars, **/*.tfstate, **/*.tflint.hcl, **/*.tf.json, **/*.tfvars.json"
---

# Azure Verified Modules (AVM) Terraform

This repository uses Azure Verified Modules (AVM) for Terraform.
For detailed guidance on module development, refer to the [AVM-Terraform-Development skill](.agents/skills/avm-terraform-development/SKILL.md).

## Module Naming Conventions

- **Pattern Modules**: `Azure/avm-ptn-{pattern}/azurerm`
- Use kebab-case for services and resources

## Module Usage

When using AVM modules:

1. Pin to a specific version: `version = "1.2.3"`
2. Map enable telemetry to root variable: `enable_telemetry = var.enable_telemetry`
3. For providers, use pessimistic constraints: `version = "~> 1.0"`
