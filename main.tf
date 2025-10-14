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

# Project Creation Module - Creates new projects when create_project block is provided
module "project_creation" {
  count  = var.create_project != null && var.enable_project_creation ? 1 : 0
  source = "./modules/project_creation"
  
  project_name         = var.create_project.project_name
  system_name          = var.create_project.system_name
  data_type           = var.create_project.data_type
  instance_type       = var.create_project.instance_type
  project_cloud_type  = var.create_project.project_cloud_type
  insight_agent_type  = var.create_project.insight_agent_type
  
  api_config = module.api_client.auth_config
}

# Project Configuration Module - Configures projects when project_config is provided
module "project_config" {
  count  = var.project_config != null && var.enable_project_configuration ? 1 : 0
  source = "./modules/project_config"
  
  project_name              = var.project_config.project_name
  project_config            = var.project_config
  create_if_not_exists      = try(var.project_config.create_if_not_exists, false)
  project_creation_config   = try(var.project_config.project_creation_config, null)
  api_config                = module.api_client.auth_config
  
  # Ensure project is created before configuration if both are enabled
  depends_on = [module.project_creation]
}

# Output configuration status
output "configuration_status" {
  description = "Configuration application status"
  value = {
    # Show project names from the respective config blocks
    project_names = {
      created    = var.create_project != null ? var.create_project.project_name : null
      configured = var.project_config != null ? var.project_config.project_name : null
    }
    project_created         = var.create_project != null && var.enable_project_creation
    project_configured      = var.project_config != null && var.enable_project_configuration
    applied_at             = timestamp()
  }
  depends_on = [
    module.project_creation,
    module.project_config
  ]
}