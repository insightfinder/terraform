# JWT Configuration Module Variables

# API client configuration
variable "api_config" {
  description = "API client configuration from api_client module"
  type = object({
    base_url    = string
    username    = string
    password    = string
    license_key = string
    auth_token  = optional(string)
    cookie_file = optional(string)
  })
  sensitive = true
}

# JWT Configuration
variable "jwt_config" {
  description = "JWT token configuration"
  type = object({
    jwt_secret  = string                # Required: JWT secret key
    system_name = string                # Required: System name to resolve to system ID
  })
  sensitive = true
  
  validation {
    condition     = length(var.jwt_config.jwt_secret) >= 6
    error_message = "JWT secret must be at least 6 characters long to meet minimum security requirements."
  }
  
  validation {
    condition     = var.jwt_config.jwt_secret != ""
    error_message = "JWT secret cannot be empty."
  }
  
  validation {
    condition     = var.jwt_config.system_name != ""
    error_message = "System name cannot be empty."
  }
}

# Optional validation
variable "validate_config" {
  description = "Whether to validate the JWT configuration before applying"
  type        = bool
  default     = true
}