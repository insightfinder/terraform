terraform {
  required_version = ">= 1.0"
}

module "advanced_example" {
  source = "../"

  insightfinder_base_url = var.insightfinder_base_url
  insightfinder_username = var.insightfinder_username
  insightfinder_password = var.insightfinder_password

  project_config = var.project_config
}

# Include all the complex variable definitions for the advanced example
variable "insightfinder_base_url" {
  description = "Base URL for InsightFinder deployment"
  type        = string
}

variable "insightfinder_username" {
  description = "InsightFinder username"
  type        = string
  sensitive   = true
}

variable "insightfinder_password" {
  description = "InsightFinder password"
  type        = string
  sensitive   = true
}

variable "project_config" {
  description = "Advanced project configuration"
  type = any # Use 'any' for complex nested structures
}

output "project_configuration" {
  description = "Advanced project configuration output"
  value       = module.advanced_example.project_configuration
}