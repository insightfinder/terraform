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
    license_key = string
  })
  sensitive = true
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
    system_name           = string
    data_type             = optional(string, "Metric")
    instance_type         = optional(string, "OnPremise")
    project_cloud_type    = optional(string, "OnPremise")
    insight_agent_type    = optional(string, "Custom")
    project_creation_type = optional(string, null)
  })
  default = null

  validation {
    condition     = var.project_creation_config == null || (var.project_creation_config.system_name != null && var.project_creation_config.system_name != "")
    error_message = "When project_creation_config is provided, system_name must be specified and cannot be empty."
  }
}

# Individual variables for specific project configuration fields
# All variables are optional (default = null) to allow flexible configuration

# Basic Configuration
variable "UBLRetentionTime" {
  description = "Retention time for UBL data in days"
  type        = number
  default     = null
}

variable "alertAverageTime" {
  description = "Average time for alerts"
  type        = number
  default     = null
}

variable "alertHourlyCost" {
  description = "Hourly cost for alerts"
  type        = number
  default     = null
}

variable "anomalyDetectionMode" {
  description = "Anomaly detection mode"
  type        = number
  default     = null
}

variable "anomalySamplingInterval" {
  description = "Sampling interval for anomaly detection"
  type        = number
  default     = null
}

variable "avgPerIncidentDowntimeCost" {
  description = "Average cost per incident downtime"
  type        = number
  default     = null
}

variable "baseValueSetting" {
  description = "Base value setting configuration"
  type = object({
    isSourceProject       = optional(bool)
    mappingKeys           = optional(list(string))
    baseValueKeys         = optional(list(string))
    metricProjects        = optional(list(string))
    additionalMetricNames = optional(list(string))
  })
  default = null
}

variable "cValue" {
  description = "Continues value for project, unit is count"
  type        = number
  default     = null
}

variable "causalMinDelay" {
  description = "Minimum delay for causal analysis"
  type        = string
  default     = null
}

variable "causalPredictionSetting" {
  description = "Causal prediction setting"
  type        = number
  default     = null
}

variable "cdfSetting" {
  description = "CDF setting configuration"
  type        = list(any)
  default     = null
}

variable "coldEventThreshold" {
  description = "Threshold for cold events"
  type        = number
  default     = null
}

variable "coldNumberLimit" {
  description = "Limit for cold numbers"
  type        = number
  default     = null
}

variable "collectAllRareEventsFlag" {
  description = "Flag to collect all rare events"
  type        = bool
  default     = null
}

variable "dailyModelSpan" {
  description = "Daily model span setting"
  type        = number
  default     = null
}

variable "disableLogCompressEvent" {
  description = "Disable log compress event"
  type        = bool
  default     = null
}

variable "disableModelKeywordStatsCollection" {
  description = "Disable model keyword stats collection"
  type        = bool
  default     = null
}

variable "emailSetting" {
  description = "Email notification settings (API expects string values)"
  type = object({
    onlySendWithRCA                    = optional(string)
    enableNotificationAW               = optional(string)
    enableIncidentPredictionEmailAlert = optional(string)
    enableIncidentDetectionEmailAlert  = optional(string)
    enableAlertsEmail                  = optional(string)
    enableRootCauseEmailAlert          = optional(string)
    emailDampeningPeriod               = optional(string)
    alertsEmailDampeningPeriod         = optional(string)
    predictionEmailDampeningPeriod     = optional(string)
  })
  default = null
}

variable "enableAnomalyScoreEscalation" {
  description = "Enable anomaly score escalation"
  type        = bool
  default     = null
}

variable "enableHotEvent" {
  description = "Enable hot event detection"
  type        = bool
  default     = null
}

variable "enableNewAlertEmail" {
  description = "Enable new alert email notifications"
  type        = bool
  default     = null
}

variable "enableStreamDetection" {
  description = "Enable stream detection"
  type        = bool
  default     = null
}

variable "escalationAnomalyScoreThreshold" {
  description = "Threshold for anomaly score escalation"
  type        = string
  default     = null
}

variable "featureOutlierSensitivity" {
  description = "Sensitivity for feature outlier detection"
  type        = string
  default     = null
}

variable "featureOutlierThreshold" {
  description = "Threshold for feature outlier detection"
  type        = number
  default     = null
}

variable "hotEventCalmDownPeriod" {
  description = "Calm down period for hot events"
  type        = number
  default     = null
}

variable "hotEventDetectionMode" {
  description = "Detection mode for hot events"
  type        = number
  default     = null
}

variable "hotEventThreshold" {
  description = "Threshold for hot event detection"
  type        = number
  default     = null
}

variable "hotNumberLimit" {
  description = "Limit for hot numbers"
  type        = number
  default     = null
}

variable "ignoreAnomalyScoreThreshold" {
  description = "Threshold to ignore anomaly scores"
  type        = string
  default     = null
}

variable "ignoreInstanceForKB" {
  description = "Ignore instance for knowledge base"
  type        = bool
  default     = null
}

variable "incidentConsolidationInterval" {
  description = "Interval for incident consolidation"
  type        = number
  default     = null
}

variable "incidentCountThreshold" {
  description = "Threshold for incident count"
  type        = number
  default     = null
}

variable "incidentDurationThreshold" {
  description = "Threshold for incident duration"
  type        = number
  default     = null
}

variable "incidentPredictionEventLimit" {
  description = "Event limit for incident prediction"
  type        = number
  default     = null
}

variable "incidentPredictionWindow" {
  description = "Window for incident prediction"
  type        = number
  default     = null
}

variable "incidentRelationSearchWindow" {
  description = "Window for incident relation search"
  type        = number
  default     = null
}

variable "instanceConvertFlag" {
  description = "Flag for instance conversion"
  type        = bool
  default     = null
}

variable "instanceDownEnable" {
  description = "Enable instance down report"
  type        = bool
  default     = null
}

variable "instanceGroupingUpdate" {
  description = "Instance grouping update settings"
  type = object({
    autoFill = optional(bool)
  })
  default = null
}

variable "isEdgeBrain" {
  description = "Is edge brain enabled"
  type        = bool
  default     = null
}

variable "isGroupingByInstance" {
  description = "Is grouping by instance enabled"
  type        = bool
  default     = null
}

variable "isTracePrompt" {
  description = "Is trace prompt enabled"
  type        = bool
  default     = null
}

variable "keywordFeatureNumber" {
  description = "Number of keyword features"
  type        = number
  default     = null
}

variable "keywordSetting" {
  description = "Keyword setting configuration"
  type        = number
  default     = null
}

variable "largeProject" {
  description = "Is this a large project"
  type        = bool
  default     = null
}

variable "llmEvaluationSetting" {
  description = "LLM evaluation settings"
  type = object({
    isHallucinationEvaluation     = optional(bool)
    isAnswerRelevantEvaluation    = optional(bool)
    isLogicConsistencyEvaluation  = optional(bool)
    isFactualInaccuracyEvaluation = optional(bool)
    isMaliciousPromptEvaluation   = optional(bool)
    isToxicityEvaluation          = optional(bool)
    isPiiPhiLeakageEvaluation     = optional(bool)
    isTopicGuardrailsEvaluation   = optional(bool)
    isToneDetectionEvaluation     = optional(bool)
    isAnomalousOutliersEvaluation = optional(bool)
    showSafetyTemplate            = optional(bool)
    isGenderBiasEvaluation        = optional(bool)
    isRacialBiasEvaluation        = optional(bool)
    isSocioeconomicBiasEvaluation = optional(bool)
    isCulturalBiasEvaluation      = optional(bool)
    isReligiousBiasEvaluation     = optional(bool)
    isPoliticalBiasEvaluation     = optional(bool)
    isDisabilityBiasEvaluation    = optional(bool)
    isAgeBiasEvaluation           = optional(bool)
  })
  default = null
}

variable "logAnomalyEventBaseScore" {
  description = "Base score for log anomaly events"
  type        = string
  default     = null
}

variable "logDetectionMinCount" {
  description = "Minimum count for log detection"
  type        = number
  default     = null
}

variable "logDetectionSize" {
  description = "Size for log detection"
  type        = number
  default     = null
}

variable "logPatternLimitLevel" {
  description = "Limit level for log patterns"
  type        = number
  default     = null
}

variable "logToLogSettingList" {
  description = "List of log to log settings"
  type        = list(any)
  default     = null
}

variable "maxLogModelSize" {
  description = "Maximum log model size"
  type        = number
  default     = null
}

variable "maxWebHookRequestSize" {
  description = "Maximum webhook request size"
  type        = number
  default     = null
}

variable "maximumDetectionWaitTime" {
  description = "Maximum detection wait time"
  type        = number
  default     = null
}

variable "maximumRootCauseResultSize" {
  description = "Maximum root cause result size"
  type        = number
  default     = null
}

variable "maximumThreads" {
  description = "Maximum number of threads"
  type        = number
  default     = null
}

variable "minIncidentPredictionWindow" {
  description = "Minimum incident prediction window"
  type        = number
  default     = null
}

variable "minValidModelSpan" {
  description = "Minimum valid model span"
  type        = number
  default     = null
}

variable "modelKeywordSetting" {
  description = "Model keyword setting"
  type        = number
  default     = null
}

variable "multiHopSearchLevel" {
  description = "Multi-hop search level"
  type        = number
  default     = null
}

variable "multiHopSearchLimit" {
  description = "Multi-hop search limit"
  type        = string
  default     = null
}

variable "multiLineFlag" {
  description = "Multi-line flag"
  type        = bool
  default     = null
}

variable "newAlertFlag" {
  description = "New alert flag"
  type        = bool
  default     = null
}

variable "newPatternNumberLimit" {
  description = "Limit for new pattern numbers"
  type        = number
  default     = null
}

variable "newPatternRange" {
  description = "Range for new patterns"
  type        = number
  default     = null
}

variable "nlpFlag" {
  description = "NLP flag"
  type        = bool
  default     = null
}

variable "normalEventCausalFlag" {
  description = "Normal event causal flag"
  type        = bool
  default     = null
}

variable "pValue" {
  description = "The probability threshold value for UBL"
  type        = number
  default     = null
}

variable "predictionCountThreshold" {
  description = "Threshold for prediction count"
  type        = number
  default     = null
}

variable "predictionProbabilityThreshold" {
  description = "Threshold for prediction probability"
  type        = number
  default     = null
}

variable "predictionRuleActiveCondition" {
  description = "Active condition for prediction rules"
  type        = number
  default     = null
}

variable "predictionRuleActiveThreshold" {
  description = "Active threshold for prediction rules"
  type        = number
  default     = null
}

variable "predictionRuleFalsePositiveThreshold" {
  description = "False positive threshold for prediction rules"
  type        = number
  default     = null
}

variable "predictionRuleInactiveThreshold" {
  description = "Inactive threshold for prediction rules"
  type        = number
  default     = null
}

variable "prettyJsonConvertorFlag" {
  description = "Pretty JSON convertor flag"
  type        = bool
  default     = null
}

variable "projectDisplayName" {
  description = "The display name of the project"
  type        = string
  default     = null
}

variable "projectModelFlag" {
  description = "Project model flag"
  type        = bool
  default     = null
}

variable "projectTimeZone" {
  description = "Project timezone"
  type        = string
  default     = null
}

variable "proxy" {
  description = "Proxy configuration"
  type        = string
  default     = null
}

variable "rareAnomalyType" {
  description = "Type of rare anomaly"
  type        = number
  default     = null
}

variable "rareEventAlertThresholds" {
  description = "Alert thresholds for rare events"
  type        = number
  default     = null
}

variable "rareNumberLimit" {
  description = "Limit for rare numbers"
  type        = number
  default     = null
}

variable "retentionTime" {
  description = "The retention time in days"
  type        = number
  default     = null
}

variable "rootCauseCountThreshold" {
  description = "Threshold for root cause count"
  type        = number
  default     = null
}

variable "rootCauseLogMessageSearchRange" {
  description = "Search range for root cause log messages"
  type        = number
  default     = null
}

variable "rootCauseProbabilityThreshold" {
  description = "Threshold for root cause probability"
  type        = number
  default     = null
}

variable "rootCauseRankSetting" {
  description = "Rank setting for root cause"
  type        = number
  default     = null
}

variable "samplingInterval" {
  description = "The interval for sampling in seconds. Don't change this unless necessary"
  type        = number
  default     = null
}

variable "sharedUsernames" {
  description = "List of shared usernames"
  type        = list(string)
  default     = null
}

variable "showInstanceDown" {
  description = "Whether to show instance down incidents for this project"
  type        = bool
  default     = null
}

variable "similaritySensitivity" {
  description = "Sensitivity for similarity detection"
  type        = string
  default     = null
}

variable "trainingFilter" {
  description = "Training filter flag"
  type        = bool
  default     = null
}

variable "webhookAlertDampening" {
  description = "Alert dampening for webhooks"
  type        = number
  default     = null
}

variable "webhookBlackListSetStr" {
  description = "Blacklist set string for webhooks"
  type        = string
  default     = null
}

variable "webhookCriticalKeywordSetStr" {
  description = "Critical keyword set string for webhooks"
  type        = string
  default     = null
}

variable "webhookHeaderList" {
  description = "List of webhook headers"
  type        = list(any)
  default     = null
}

variable "webhookTypeSetStr" {
  description = "Type set string for webhooks"
  type        = string
  default     = null
}

variable "webhookUrl" {
  description = "Webhook URL"
  type        = string
  default     = null
}

variable "whitelistNumberLimit" {
  description = "Limit for whitelist numbers"
  type        = number
  default     = null
}

variable "zoneNameKey" {
  description = "Zone name key"
  type        = string
  default     = null
}

# Special handling for logLabelSettingCreate - processed separately
variable "logLabelSettingCreate" {
  description = "List of log label settings to create"
  type = list(object({
    labelType      = string
    logLabelString = string
  }))
  default = null
}

# Legacy variables for backward compatibility (these are used for metric projects)
variable "instanceGroupingData" {
  description = "List of instance grouping details"
  type = list(object({
    instanceName        = string
    containerName       = optional(string)
    appName             = optional(string)
    metricInstanceName  = optional(string)
    ignoreFlag          = optional(bool)
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
    condition     = var.patternIdGenerationRule == null || (var.patternIdGenerationRule == 0 || var.patternIdGenerationRule == 1)
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
    isKPI                              = optional(bool)
    escalateIncidentSet                = optional(list(string))
    escalateIncidentAll                = optional(bool)
    patternNameHigher                  = optional(string)
    patternNameLower                   = optional(string)
    detectionType                      = optional(string)
    positiveBaselineViolationFactor    = optional(number)
    thresholdAlertLowerBound           = optional(number)
    thresholdAlertUpperBound           = optional(number)
    thresholdAlertUpperBoundNegative   = optional(number)
    thresholdAlertLowerBoundNegative   = optional(number)
    thresholdNoAlertLowerBound         = optional(number)
    thresholdNoAlertUpperBound         = optional(number)
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
