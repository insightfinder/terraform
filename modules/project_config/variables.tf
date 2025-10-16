# Project Configuration Module Variables

# Project identification
variable "project_name" {
  description = "Project name"
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
    auth_token  = string
    cookie_file = optional(string)
  })
  sensitive = true
}

# Project Configuration
variable "project_config" {
  description = "Project configuration object - supports any fields from the OpenAPI spec"
  type        = any
  default     = {}
}

# Configuration behavior
variable "create_if_not_exists" {
  description = "Whether to create the project if it doesn't exist (requires project creation parameters)"
  type        = bool
  default     = false
}

variable "project_creation_config" {
  description = "Project creation configuration (required if create_if_not_exists is true)"
  type = object({
    system_name         = string
    data_type          = optional(string, "Metric")
    instance_type      = optional(string, "OnPremise")
    project_cloud_type = optional(string, "OnPremise")
    insight_agent_type = optional(string, "Custom")
  })
  default = null
  
  validation {
    condition = var.create_if_not_exists == false || (var.project_creation_config != null && var.project_creation_config.system_name != null && var.project_creation_config.system_name != "")
    error_message = "project_creation_config with system_name is required when create_if_not_exists is true."
  }
}

# Individual variables for convenience (matching OpenAPI spec exactly)
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

variable "UBLRetentionTime" {
  description = "Retention time for UBL data in days"
  type        = number
  default     = null
}

variable "projectDisplayName" {
  description = "The display name of the project"
  type        = string
  default     = null
}

variable "samplingInterval" {
  description = "The interval for sampling in seconds. Don't change this unless necessary"
  type        = number
  default     = null
}

variable "instanceGroupingData" {
  description = "List of instance grouping details"
  type = list(object({
    instanceName        = string
    containerName       = optional(string)
    appName            = optional(string)
    metricInstanceName = optional(string)
    ignoreFlag         = optional(bool)
    instanceDisplayName = optional(string)
  }))
  default = null
}

variable "highRatioCValue" {
  description = "c value for those anomaly with 1000% higher than normal, needs to be smaller than normal c value"
  type        = number
  default     = null
}

variable "dynamicBaselineDetectionFlag" {
  description = "Enable Baseline Detection"
  type        = bool
  default     = null
}

variable "positiveBaselineViolationFactor" {
  description = "The baseline violation factor for higher than normal detection"
  type        = number
  default     = null
}

variable "negativeBaselineViolationFactor" {
  description = "The baseline violation factor for lower than normal detection"
  type        = number
  default     = null
}

variable "enablePeriodAnomalyFilter" {
  description = "Enable period detection, usually false this is very resource consuming"
  type        = bool
  default     = null
}

variable "enableUBLDetect" {
  description = "Enable UBL Detection"
  type        = bool
  default     = null
}

variable "enableCumulativeDetect" {
  description = "Enable Auto-Cumulative Detection"
  type        = bool
  default     = null
}

variable "instanceDownThreshold" {
  description = "How long instance down will generate incident, unit is milliseconds"
  type        = number
  default     = null
}

variable "instanceDownReportNumber" {
  description = "How many instance down instances will be reported"
  type        = number
  default     = null
}

variable "instanceDownEnable" {
  description = "Enable instance down report"
  type        = bool
  default     = null
}

variable "modelSpan" {
  description = "model span setting. 0 is daily, 1 is monthly"
  type        = number
  default     = null
}

variable "enableMetricDataPrediction" {
  description = "Enable metric data prediction"
  type        = bool
  default     = null
}

variable "enableBaselineDetectionDoubleVerify" {
  description = "Enable metric baseline double verification, normally disabled"
  type        = bool
  default     = null
}

variable "enableFillGap" {
  description = "Enable metric data gap filling for missing data, normally disabled"
  type        = bool
  default     = null
}

variable "patternIdGenerationRule" {
  description = "0 or 1. Generate pattern name and id by metric type(0) or metric name(1)"
  type        = number
  default     = null
  validation {
    condition     = var.patternIdGenerationRule == null || contains([0, 1], var.patternIdGenerationRule)
    error_message = "Pattern ID generation rule must be 0 or 1."
  }
}

variable "anomalyGapToleranceCount" {
  description = "Gap tolerance value, 0 means disabled"
  type        = number
  default     = null
}

variable "filterByAnomalyInBaselineGeneration" {
  description = "Filter out anomaly part when generating baseline, normally false"
  type        = bool
  default     = null
}

variable "baselineDuration" {
  description = "Baseline block duration, unit is milliseconds"
  type        = number
  default     = null
}

variable "componentMetricSettingOverallModelList" {
  description = "Settings for Metric Settings Page"
  type = list(object({
    metricName                         = string
    isKPI                             = optional(bool)
    escalateIncidentSet               = optional(list(string))
    escalateIncidentAll               = optional(bool)
    patternNameHigher                 = optional(string)
    patternNameLower                  = optional(string)
    detectionType                     = optional(string)
    positiveBaselineViolationFactor   = optional(number)
    thresholdAlertLowerBound          = optional(number)
    thresholdAlertUpperBound          = optional(number)
    thresholdAlertUpperBoundNegative  = optional(number)
    thresholdAlertLowerBoundNegative  = optional(number)
    thresholdNoAlertLowerBound        = optional(number)
    thresholdNoAlertUpperBound        = optional(number)
    thresholdNoAlertLowerBoundNegative = optional(number)
    thresholdNoAlertUpperBoundNegative = optional(number)
  }))
  default = null
}

variable "enableBaselineNearConstance" {
  description = "Enable baseline near constance check"
  type        = bool
  default     = null
}

variable "computeDifference" {
  description = "Set if metric is cumulative or not manually"
  type        = bool
  default     = null
}