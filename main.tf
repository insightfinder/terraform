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

# Connection Variables
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

variable "project_name" {
  description = "Project name"
  type        = string
}

# Project Configuration
variable "project_config" {
  description = "Project configuration object - supports any fields from the Python client"
  type        = any
  default     = {}
}

# Common individual variables for convenience (optional)
variable "cValue" {
  description = "Continues value for project, unit is count"
  type        = number
  default     = null
}

variable "pValue" {
  description = "The probability threshold value for UBL"
  type        = number
  default     = null
}

variable "showInstanceDown" {
  description = "Whether to show instance down incidents for this project"
  type        = bool
  default     = null
}

variable "retentionTime" {
  description = "The retention time in days"
  type        = number
  default     = null
}

variable "projectDisplayName" {
  description = "The display name of the project"
  type        = string
  default     = null
}

variable "samplingInterval" {
  description = "The interval for sampling in seconds"
  type        = number
  default     = null
}

variable "UBLRetentionTime" {
  description = "UBL retention time in days"
  type        = number
  default     = null
}

variable "highRatioCValue" {
  description = "High ratio C value"
  type        = number
  default     = null
}

variable "dynamicBaselineDetectionFlag" {
  description = "Enable dynamic baseline detection"
  type        = bool
  default     = null
}

variable "enableUBLDetect" {
  description = "Enable UBL detection"
  type        = bool
  default     = null
}

variable "enableCumulativeDetect" {
  description = "Enable cumulative detection"
  type        = bool
  default     = null
}

variable "maximumHint" {
  description = "Maximum hint value"
  type        = number
  default     = null
}

variable "positiveBaselineViolationFactor" {
  description = "Positive baseline violation factor"
  type        = number
  default     = null
}

variable "negativeBaselineViolationFactor" {
  description = "Negative baseline violation factor"  
  type        = number
  default     = null
}

variable "enablePeriodAnomalyFilter" {
  description = "Enable period anomaly filter"
  type        = bool
  default     = null
}

variable "baselineDuration" {
  description = "Baseline duration in milliseconds"
  type        = number
  default     = null
}

variable "modelSpan" {
  description = "Model span setting"
  type        = number
  default     = null
}

variable "projectTimeZone" {
  description = "Project timezone"
  type        = string
  default     = null
}

variable "enableFillGap" {
  description = "Enable gap filling"
  type        = bool
  default     = null
}

variable "gapFillingTrainingDataLength" {
  description = "Gap filling training data length"
  type        = number
  default     = null
}

# Create final configuration by merging individual variables with project_config
locals {
  # Build config from individual variables (only non-null values)
  individual_fields = {
    for k, v in {
      cValue                              = var.cValue
      pValue                              = var.pValue
      showInstanceDown                    = var.showInstanceDown
      retentionTime                       = var.retentionTime
      projectDisplayName                  = var.projectDisplayName
      samplingInterval                    = var.samplingInterval
      UBLRetentionTime                   = var.UBLRetentionTime
      highRatioCValue                    = var.highRatioCValue
      dynamicBaselineDetectionFlag       = var.dynamicBaselineDetectionFlag
      enableUBLDetect                    = var.enableUBLDetect
      enableCumulativeDetect             = var.enableCumulativeDetect
      maximumHint                        = var.maximumHint
      positiveBaselineViolationFactor    = var.positiveBaselineViolationFactor
      negativeBaselineViolationFactor    = var.negativeBaselineViolationFactor
      enablePeriodAnomalyFilter          = var.enablePeriodAnomalyFilter
      baselineDuration                   = var.baselineDuration
      modelSpan                          = var.modelSpan
      projectTimeZone                    = var.projectTimeZone
      enableFillGap                      = var.enableFillGap
      gapFillingTrainingDataLength       = var.gapFillingTrainingDataLength
    } : k => v if v != null
  }
  
  # Merge individual fields with project_config (project_config takes precedence)
  final_config = merge(local.individual_fields, var.project_config)
}

# Generate configuration JSON file
resource "local_file" "config" {
  content  = jsonencode(local.final_config)
  filename = "${path.module}/generated-config.json"
}

# Apply configuration to InsightFinder API
resource "null_resource" "apply_config" {
  depends_on = [local_file.config]

  provisioner "local-exec" {
    command = "${path.module}/apply-config.sh"
    environment = {
      CONFIG_FILE  = local_file.config.filename
      PROJECT_NAME = var.project_name
      BASE_URL     = var.base_url
      USERNAME     = var.username
      PASSWORD     = var.password
    }
  }

  triggers = {
    config_hash = sha256(local_file.config.content)
    timestamp   = timestamp()
  }
}

# Output configuration status
output "configuration_applied" {
  description = "Configuration application status"
  value = {
    project_name = var.project_name
    config_file  = local_file.config.filename
    applied_at   = timestamp()
  }
  depends_on = [null_resource.apply_config]
}