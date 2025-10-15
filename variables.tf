# Root Module Variables
# These variables will be passed to the appropriate modules

# API Connection Variables
variable "base_url" {
  description = "InsightFinder API base URL"
  type        = string
  default     = "https://app.insightfinder.com"
}

variable "username" {
  description = "InsightFinder username"
  type        = string
}

variable "password" {
  description = "InsightFinder password"
  type        = string
  sensitive   = true
}

variable "license_key" {
  description = "InsightFinder license key (required for project creation)"
  type        = string
  sensitive   = true
}

# Project Configuration Block
variable "project_config" {
  description = "Project configuration object - must include project_name and supports any OpenAPI fields. Set create_if_not_exists=true and provide project_creation_config to create projects that don't exist."
  type        = any
  default     = null
}