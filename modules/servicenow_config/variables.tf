# ServiceNow Configuration Module Variables

# API client configuration
variable "api_config" {
  description = "API client configuration from api_client module"
  type = object({
    base_url    = string
    username    = string
    license_key = string
  })
  sensitive = true
}

# ServiceNow Configuration
variable "servicenow_config" {
  description = "ServiceNow integration configuration"
  type = object({
    service_host     = string                     # Required: ServiceNow instance hostname
    account          = string                     # Required: ServiceNow username  
    password         = string                     # Required: ServiceNow password
    dampening_period = number                     # Required: Dampening period in seconds
    system_names     = optional(list(string), []) # Optional: List of system display names (will be resolved to IDs)
    system_ids       = optional(list(string), []) # Optional: List of system IDs 
    proxy            = optional(string, "")       # Optional: Proxy server
    app_id           = optional(string, "")       # Optional: ServiceNow application ID (mapped from client_id)
    app_key          = optional(string, "")       # Optional: ServiceNow application key (mapped from client_secret)
    options          = optional(list(string), []) # Optional: Integration options
    content_option   = optional(list(string), []) # Optional: Content options
  })
  sensitive = true

  validation {
    condition     = var.servicenow_config.dampening_period > 0
    error_message = "Dampening period must be greater than 0."
  }

  validation {
    condition     = length(var.servicenow_config.system_names) > 0 || length(var.servicenow_config.system_ids) > 0
    error_message = "Either system_names or system_ids must be provided (both cannot be empty)."
  }

  validation {
    condition     = !(length(var.servicenow_config.system_names) > 0 && length(var.servicenow_config.system_ids) > 0)
    error_message = "Cannot specify both system_names and system_ids - choose one approach."
  }
}

# Optional validation
variable "validate_config" {
  description = "Whether to validate the ServiceNow configuration before applying"
  type        = bool
  default     = true
}