# InsightFinder Terraform Configuration
# This module provides clean, structured configuration for InsightFinder projects

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

# API Client Module - Provides shared authentication configuration
module "api_client" {
  source = "./modules/api_client"
  
  base_url    = var.base_url
  username    = var.username
  password    = var.password
  license_key = var.license_key
}

# Project Configuration Module - Configures projects and can create them if they don't exist
module "project_config" {
  count  = var.project_config != null ? 1 : 0
  source = "./modules/project_config"
  
  project_name              = var.project_config.project_name
  project_config            = var.project_config
  create_if_not_exists      = try(var.project_config.create_if_not_exists, false)
  project_creation_config   = try(var.project_config.project_creation_config, null)
  api_config                = module.api_client.auth_config
}

# Output configuration status
output "configuration_status" {
  description = "Configuration application status"
  value = {
    project_name       = var.project_config != null ? var.project_config.project_name : null
    project_configured = var.project_config != null
    create_if_not_exists = var.project_config != null ? try(var.project_config.create_if_not_exists, false) : false
    applied_at         = timestamp()
  }
  depends_on = [module.project_config]
}