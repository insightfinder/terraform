# InsightFinder Terraform Configuration
# This module provides clean, structured configuration for InsightFinder projects
# Module Version: 2.1.0

terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Read module version from VERSION file
locals {
  module_version = trimspace(file("${path.module}/VERSION"))
}

# API Client Module - Provides shared authentication configuration
module "api_client" {
  source = "./modules/api_client"

  base_url    = var.base_url
  username    = var.username
  license_key = var.license_key
}

# Project Configuration Module - Configures projects and can create them if they don't exist
module "project_config" {
  count  = var.project_config != null ? 1 : 0
  source = "./modules/project_config"

  project_name            = var.project_config.project_name
  project_config          = var.project_config
  create_if_not_exists    = try(var.project_config.create_if_not_exists, false)
  project_creation_config = try(var.project_config.project_creation_config, null)
  api_config              = module.api_client.auth_config
}

# ServiceNow Configuration Module - Configures ServiceNow integration
module "servicenow_config" {
  count  = var.servicenow_config != null ? 1 : 0
  source = "./modules/servicenow_config"

  servicenow_config = var.servicenow_config != null ? merge(var.servicenow_config, {
    # Map user-facing client_id/client_secret to API app_id/app_key
    app_id  = var.servicenow_config.client_id
    app_key = var.servicenow_config.client_secret
  }) : null
  api_config = module.api_client.auth_config

  # Ensure authentication is completed first
  depends_on = [module.api_client]
}

# JWT Configuration Module - Configures JWT token settings
module "jwt_config" {
  count  = var.jwt_config != null ? 1 : 0
  source = "./modules/jwt_config"

  jwt_config = var.jwt_config
  api_config = module.api_client.auth_config

  # Ensure authentication is completed first
  depends_on = [module.api_client]
}

# Output configuration status
output "configuration_status" {
  description = "Configuration application status"
  value = {
    project_name          = var.project_config != null ? var.project_config.project_name : null
    project_configured    = var.project_config != null
    create_if_not_exists  = var.project_config != null ? try(var.project_config.create_if_not_exists, false) : false
    servicenow_configured = var.servicenow_config != null
    jwt_configured        = var.jwt_config != null
    applied_at            = timestamp()
  }
  sensitive  = true
  depends_on = [module.project_config, module.servicenow_config, module.jwt_config]
}

# ServiceNow configuration output
output "servicenow_status" {
  description = "ServiceNow integration configuration status"
  value = var.servicenow_config != null ? {
    configured   = true
    service_host = var.servicenow_config.service_host
    account      = var.servicenow_config.account
    client_id    = var.servicenow_config.client_id
    system_count = length(var.servicenow_config.system_names)
  } : null
  sensitive  = true
  depends_on = [module.servicenow_config]
}

# JWT configuration output
output "jwt_status" {
  description = "JWT configuration status"
  value = var.jwt_config != null ? {
    configured    = true
    system_name   = var.jwt_config.system_name
    secret_length = length(var.jwt_config.jwt_secret)
  } : null
  sensitive  = true
  depends_on = [module.jwt_config]
}

# Module version output
output "module_version" {
  description = "InsightFinder Terraform Module version"
  value = {
    version   = local.module_version
    changelog = "See CHANGELOG.md for version history"
    source    = "https://github.com/insightfinder/terraform"
  }
}