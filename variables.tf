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

variable "license_key" {
  description = "InsightFinder license key"
  type        = string
  sensitive   = true
}

# Project Configuration Block
variable "project_config" {
  description = "Project configuration object - includes project identification and all configuration settings"
  type = object({
    # Project identification
    project_name         = string
    create_if_not_exists = optional(bool, false)
    
    # Project creation config (required if create_if_not_exists = true)
    project_creation_config = optional(object({
      system_name           = string
      data_type             = optional(string, "Metric")
      instance_type         = optional(string, "OnPremise")
      project_cloud_type    = optional(string, "OnPremise")
      insight_agent_type    = optional(string, "Custom")
      project_creation_type = optional(string, null)
    }))
    
    # All configuration fields (optional)
    UBLRetentionTime                       = optional(number)
    alertAverageTime                       = optional(number)
    alertHourlyCost                        = optional(number)
    anomalyDetectionMode                   = optional(number)
    anomalySamplingInterval                = optional(number)
    avgPerIncidentDowntimeCost             = optional(number)
    baseValueSetting = optional(object({
      isSourceProject       = optional(bool)
      mappingKeys           = optional(list(string))
      baseValueKeys         = optional(list(string))
      metricProjects        = optional(list(string))
      additionalMetricNames = optional(list(string))
    }))
    cValue                                 = optional(number)
    causalMinDelay                         = optional(string)
    causalPredictionSetting                = optional(number)
    cdfSetting                             = optional(list(any))
    coldEventThreshold                     = optional(number)
    coldNumberLimit                        = optional(number)
    collectAllRareEventsFlag               = optional(bool)
    dailyModelSpan                         = optional(number)
    disableLogCompressEvent                = optional(bool)
    disableModelKeywordStatsCollection     = optional(bool)
    emailSetting = optional(object({
      onlySendWithRCA                    = optional(bool)
      enableNotificationAW               = optional(bool)
      enableIncidentPredictionEmailAlert = optional(bool)
      enableIncidentDetectionEmailAlert  = optional(bool)
      enableAlertsEmail                  = optional(bool)
      enableRootCauseEmailAlert          = optional(bool)
      emailDampeningPeriod               = optional(number)
      alertsEmailDampeningPeriod         = optional(number)
      predictionEmailDampeningPeriod     = optional(number)
    }))
    enableAnomalyScoreEscalation           = optional(bool)
    enableHotEvent                         = optional(bool)
    enableNewAlertEmail                    = optional(bool)
    enableStreamDetection                  = optional(bool)
    escalationAnomalyScoreThreshold        = optional(string)
    featureOutlierSensitivity              = optional(string)
    featureOutlierThreshold                = optional(number)
    hotEventCalmDownPeriod                 = optional(number)
    hotEventDetectionMode                  = optional(number)
    hotEventThreshold                      = optional(number)
    hotNumberLimit                         = optional(number)
    ignoreAnomalyScoreThreshold            = optional(string)
    ignoreInstanceForKB                    = optional(bool)
    incidentConsolidationInterval          = optional(number)
    incidentCountThreshold                 = optional(number)
    incidentDurationThreshold              = optional(number)
    incidentPredictionEventLimit           = optional(number)
    incidentPredictionWindow               = optional(number)
    incidentRelationSearchWindow           = optional(number)
    instanceConvertFlag                    = optional(bool)
    instanceDownEnable                     = optional(bool)
    instanceGroupingUpdate = optional(object({
      autoFill = optional(bool)
    }))
    isEdgeBrain                            = optional(bool)
    isGroupingByInstance                   = optional(bool)
    isTracePrompt                          = optional(bool)
    keywordFeatureNumber                   = optional(number)
    keywordSetting                         = optional(number)
    largeProject                           = optional(bool)
    llmEvaluationSetting = optional(object({
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
    }))
    logAnomalyEventBaseScore               = optional(string)
    logDetectionMinCount                   = optional(number)
    logDetectionSize                       = optional(number)
    logPatternLimitLevel                   = optional(number)
    logToLogSettingList                    = optional(list(any))
    maxLogModelSize                        = optional(number)
    maxWebHookRequestSize                  = optional(number)
    maximumDetectionWaitTime               = optional(number)
    maximumRootCauseResultSize             = optional(number)
    maximumThreads                         = optional(number)
    minIncidentPredictionWindow            = optional(number)
    minValidModelSpan                      = optional(number)
    modelKeywordSetting                    = optional(number)
    multiHopSearchLevel                    = optional(number)
    multiHopSearchLimit                    = optional(string)
    multiLineFlag                          = optional(bool)
    newAlertFlag                           = optional(bool)
    newPatternNumberLimit                  = optional(number)
    newPatternRange                        = optional(number)
    nlpFlag                                = optional(bool)
    normalEventCausalFlag                  = optional(bool)
    pValue                                 = optional(number)
    predictionCountThreshold               = optional(number)
    predictionProbabilityThreshold         = optional(number)
    predictionRuleActiveCondition          = optional(number)
    predictionRuleActiveThreshold          = optional(number)
    predictionRuleFalsePositiveThreshold   = optional(number)
    predictionRuleInactiveThreshold        = optional(number)
    prettyJsonConvertorFlag                = optional(bool)
    projectDisplayName                     = optional(string)
    projectModelFlag                       = optional(bool)
    projectTimeZone                        = optional(string)
    proxy                                  = optional(string)
    rareAnomalyType                        = optional(number)
    rareEventAlertThresholds               = optional(number)
    rareNumberLimit                        = optional(number)
    retentionTime                          = optional(number)
    rootCauseCountThreshold                = optional(number)
    rootCauseLogMessageSearchRange         = optional(number)
    rootCauseProbabilityThreshold          = optional(number)
    rootCauseRankSetting                   = optional(number)
    samplingInterval                       = optional(number)
    sharedUsernames                        = optional(list(string))
    showInstanceDown                       = optional(bool)
    similaritySensitivity                  = optional(string)
    trainingFilter                         = optional(bool)
    webhookAlertDampening                  = optional(number)
    webhookBlackListSetStr                 = optional(string)
    webhookCriticalKeywordSetStr           = optional(string)
    webhookHeaderList                      = optional(list(any))
    webhookTypeSetStr                      = optional(string)
    webhookUrl                             = optional(string)
    whitelistNumberLimit                   = optional(number)
    zoneNameKey                            = optional(string)
    
    # Special handling for logLabelSettingCreate
    logLabelSettingCreate = optional(list(object({
      labelType      = string
      logLabelString = string
    })))
    
    # Legacy metric project variables
    instanceGroupingData = optional(list(object({
      instanceName        = string
      containerName       = optional(string)
      appName             = optional(string)
      metricInstanceName  = optional(string)
      ignoreFlag          = optional(bool)
      instanceDisplayName = optional(string)
    })))
    highRatioCValue                        = optional(number)
    dynamicBaselineDetectionFlag           = optional(bool)
    positiveBaselineViolationFactor        = optional(number)
    negativeBaselineViolationFactor        = optional(number)
    enablePeriodAnomalyFilter              = optional(bool)
    enableUBLDetect                        = optional(bool)
    enableCumulativeDetect                 = optional(bool)
    instanceDownThreshold                  = optional(number)
    instanceDownReportNumber               = optional(number)
    modelSpan                              = optional(number)
    enableMetricDataPrediction             = optional(bool)
    enableBaselineDetectionDoubleVerify    = optional(bool)
    enableFillGap                          = optional(bool)
    patternIdGenerationRule                = optional(number)
    anomalyGapToleranceCount               = optional(number)
    filterByAnomalyInBaselineGeneration    = optional(bool)
    baselineDuration                       = optional(number)
    componentMetricSettingOverallModelList = optional(list(object({
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
    })))
    enableBaselineNearConstance            = optional(bool)
    computeDifference                      = optional(bool)
  })
  default = null
}

# ServiceNow Configuration Block
variable "servicenow_config" {
  description = "ServiceNow integration configuration object"
  type = object({
    service_host     = string
    proxy            = optional(string, "")
    account          = string
    password         = string
    dampening_period = optional(number, 300)
    client_id        = string                     # ServiceNow application client ID (sent as app_id to API)
    client_secret    = string                     # ServiceNow application client secret (sent as app_key to API)
    system_names     = optional(list(string), []) # Human-readable system names (automatically resolved to system IDs)
    system_ids       = optional(list(string), []) # System IDs
    options          = optional(list(string), [])
    content_option   = optional(list(string), [])
  })
  default   = null
  sensitive = true
}

# JWT Configuration Block
variable "jwt_config" {
  description = "JWT token configuration object"
  type = object({
    jwt_secret  = string # JWT secret key (minimum 6 characters)
    system_name = string # System name to configure JWT for (will be resolved to system ID)
  })
  default   = null
  sensitive = true

  validation {
    condition = (
      var.jwt_config == null ||
      (
        try(var.jwt_config.jwt_secret, "") != "" &&
        try(var.jwt_config.system_name, "") != "" &&
        try(length(var.jwt_config.jwt_secret), 0) >= 6
      )
    )
    error_message = "When jwt_config is provided, jwt_secret must be at least 6 characters and system_name cannot be empty."
  }
}