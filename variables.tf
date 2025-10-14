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

# Control flags for what to create/configure
variable "enable_project_creation" {
  description = "Whether to create a new project"
  type        = bool
  default     = false
}

variable "enable_project_configuration" {
  description = "Whether to configure an existing project"
  type        = bool
  default     = true
}

# Project Creation Configuration Block
variable "create_project" {
  description = "Project creation configuration"
  type = object({
    project_name         = string
    system_name          = string
    data_type           = string
    instance_type       = string
    project_cloud_type  = string
    insight_agent_type  = string
  })
  default = null
}

# Project Configuration Block
variable "project_config" {
  description = "Project configuration object - must include project_name and supports any OpenAPI fields"
  type        = any
  default     = null
}