terraform {
  required_version = ">= 1.0"
}

module "basic_example" {
  source = "../"

  insightfinder_base_url = var.insightfinder_base_url
  insightfinder_username = var.insightfinder_username
  insightfinder_password = var.insightfinder_password

  project_config = var.project_config
}

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
  description = "Project configuration"
  type = object({
    project            = string
    userName          = string
    projectDisplayName = optional(string)
    cValue            = optional(number, 1)
    pValue            = optional(number, 0.95)
    showInstanceDown  = optional(bool, false)
    retentionTime     = optional(number, 90)
    UBLRetentionTime  = optional(number, 8)

    instances = optional(list(object({
      instanceName        = string
      instanceDisplayName = optional(string)
      containerName       = optional(string)
      appName            = optional(string)
      ignoreFlag         = optional(bool, false)
    })), [])

    metrics = optional(list(object({
      metricName                     = string
      escalateIncidentAll            = optional(bool, true)
      thresholdAlertLowerBound       = optional(number, 15)
      thresholdAlertUpperBound       = optional(number, 105)
      thresholdNoAlertLowerBound     = optional(number, 50)
      thresholdNoAlertUpperBound     = optional(number, 75)
    })), [])
  })
}

output "project_configuration" {
  description = "Project configuration output"
  value       = module.basic_example.project_configuration
}