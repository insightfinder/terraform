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

# ServiceNow Configuration Block
variable "servicenow_config" {
  description = "ServiceNow integration configuration object"
  type = object({
    service_host       = string
    proxy             = optional(string, "")
    account           = string
    password          = string
    dampening_period  = optional(number, 300)
    client_id         = string  # ServiceNow application client ID (sent as app_id to API)
    client_secret     = string  # ServiceNow application client secret (sent as app_key to API)
    system_names      = optional(list(string), [])  # Human-readable system names (automatically resolved to system IDs)
    system_ids        = optional(list(string), [])  # System IDs
    options           = optional(list(string), [])
    content_option    = optional(list(string), [])
  })
  default   = null
  sensitive = true
}