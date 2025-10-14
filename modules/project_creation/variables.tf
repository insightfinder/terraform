# Project Creation Module Variables

# Project identification and basic settings
variable "project_name" {
  description = "Name of the project to create"
  type        = string
  validation {
    condition     = length(var.project_name) >= 3
    error_message = "Project name must be at least 3 characters long."
  }
}

variable "system_name" {
  description = "System name for the project"
  type        = string
}

variable "data_type" {
  description = "Type of data the project will handle"
  type        = string
  validation {
    condition     = contains(["Metric", "Log", "Incident", "Alert"], var.data_type)
    error_message = "Data type must be one of: Metric, Log, Incident, Alert."
  }
}

variable "instance_type" {
  description = "Instance type for the project"
  type        = string
  default     = "OnPremise"
}

variable "project_cloud_type" {
  description = "Cloud provider type for the project"
  type        = string
  default     = "OnPremise"
}

variable "insight_agent_type" {
  description = "InsightFinder agent type"
  type        = string
}

# API client configuration
variable "api_config" {
  description = "API client configuration from api_client module"
  type = object({
    base_url    = string
    username    = string
    password    = string
    license_key = string
  })
  sensitive = true
}