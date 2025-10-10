terraform {
  required_version = ">= 1.0"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Variables for InsightFinder configuration
variable "insightfinder_base_url" {
  description = "Base URL for InsightFinder deployment"
  type        = string
  default     = "https://app.insightfinder.com"
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
  description = "Complete InsightFinder project configuration"
  type = object({
    # Required fields
    project   = string
    userName  = string

    # Basic project settings
    projectDisplayName                  = optional(string)
    cValue                             = optional(number, 1)
    pValue                             = optional(number, 0.95)
    showInstanceDown                   = optional(bool, false)
    retentionTime                      = optional(number, 90)
    UBLRetentionTime                   = optional(number, 8)

    # Advanced project settings  
    highRatioCValue                    = optional(number, 3)
    maximumHint                        = optional(number, 20)
    dynamicBaselineDetectionFlag       = optional(bool, true)
    positiveBaselineViolationFactor    = optional(number, 2.0)
    negativeBaselineViolationFactor    = optional(number, 2.0)
    enablePeriodAnomalyFilter          = optional(bool, false)
    enableUBLDetect                    = optional(bool, true)
    enableCumulativeDetect             = optional(bool, true)
    predictionTrainingDataLength       = optional(number, 0)
    predictionCorrelationSensitivity   = optional(number, 0.75)
    enableKPIPrediction                = optional(bool, false)
    instanceDownThreshold              = optional(number, 3600000)
    instanceDownReportNumber           = optional(number, 50)
    instanceDownEnable                 = optional(bool, false)
    modelSpan                          = optional(number, 0)
    enableMetricDataPrediction         = optional(bool, true)
    enableBaselineDetectionDoubleVerify = optional(bool, false)
    enableFillGap                      = optional(bool, false)
    enableStoreFilledGap               = optional(bool, false)
    gapFillingTrainingDataLength       = optional(number, 0)
    patternIdGenerationRule            = optional(number, 1)
    anomalyGapToleranceCount           = optional(number, 1)
    filterByAnomalyInBaselineGeneration = optional(bool, false)
    baselineDuration                   = optional(number, 14400000)
    anomalyDampening                   = optional(number, 50400000)

    # Prediction and Incident settings
    incidentPredictionWindow           = optional(number, 12)
    minIncidentPredictionWindow        = optional(number, 5)
    incidentRelationSearchWindow       = optional(number, 6)
    incidentPredictionEventLimit       = optional(number, 50)
    rootCauseCountThreshold            = optional(number, 1)
    rootCauseProbabilityThreshold      = optional(number, 0.8)
    compositeRCALimit                  = optional(number, 10)
    rootCauseLogMessageSearchRange     = optional(number, 240)
    causalPredictionSetting            = optional(number, 0)
    rootCauseRankSetting               = optional(number, 0)
    maximumRootCauseResultSize         = optional(number, 5)
    multiHopSearchLevel                = optional(number, 2)
    multiHopSearchLimit                = optional(number, 30)

    # Cost and Alert settings
    avgPerIncidentDowntimeCost         = optional(number, 5000.0)
    predictionRuleActiveCondition      = optional(number, 0)
    predictionRuleFalsePositiveThreshold = optional(number, 1)
    predictionRuleActiveThreshold      = optional(number, 0.8)
    predictionRuleInactiveThreshold    = optional(number, 0.1)
    predictionProbabilityThreshold     = optional(number, 0.8)
    alertHourlyCost                    = optional(number, 200.0)
    alertAverageTime                   = optional(number, 3600000)
    predictionCountThreshold           = optional(number, 1)

    # System settings
    ignoreInstanceForKB                = optional(bool, false)
    trainingFilter                     = optional(bool, true)
    projectTimeZone                    = optional(string, "US/Eastern")
    samplingInterval                   = optional(number, 60)
    minValidModelSpan                  = optional(number, 14400000)
    maxWebHookRequestSize              = optional(number, 2)
    newPatternRange                    = optional(number, 3)
    largeProject                       = optional(bool, false)
    enableAnomalyScoreEscalation       = optional(bool, false)
    escalationAnomalyScoreThreshold    = optional(string, "")
    ignoreAnomalyScoreThreshold        = optional(number, 0.0)
    enableStreamDetection              = optional(bool, false)

    # Webhook settings
    webhookUrl                         = optional(string, "")
    webhookHeaderList                  = optional(list(string), [])
    webhookTypeSetStr                  = optional(string, "[]")
    webhookBlackListSetStr             = optional(string, "[]")
    webhookCriticalKeywordSetStr       = optional(string, "[]")
    webhookAlertDampening              = optional(number, 18000000)
    proxy                              = optional(string, "")

    # Email settings
    emailSetting = optional(object({
      onlySendWithRCA                    = optional(bool, false)
      enableNotificationAW               = optional(bool, false)
      enableIncidentPredictionEmailAlert = optional(bool, false)
      enableIncidentDetectionEmailAlert  = optional(bool, false)
      enableAlertsEmail                  = optional(bool, false)
      enableRootCauseEmailAlert          = optional(bool, false)
      emailDampeningPeriod               = optional(number, 0)
      alertsEmailDampeningPeriod         = optional(number, 0)
      predictionEmailDampeningPeriod     = optional(number, 0)
      enableNewAlertEmail                = optional(bool, false)
      alertEmail                         = optional(string, "")
      predictionEmail                    = optional(string, "")
      rootCauseEmail                     = optional(string, "")
      healthAlertEmail                   = optional(string, "")
      incidentDetectionEmail             = optional(string, "")
      awSeverityLevel                    = optional(string, "")
    }), {})

    # Instance grouping settings  
    instanceGroupingUpdate = optional(object({
      autoFill = optional(bool, false)
    }), {})

    # Lists and collections
    linkedLogProjects                  = optional(list(string), [])
    sharedUsernames                    = optional(list(string), [])

    # Instance data and metric settings (from IFClient-Python structure)
    instances = optional(list(object({
      instanceName         = string
      instanceDisplayName  = optional(string)
      containerName        = optional(string)
      appName              = optional(string)
      metricInstanceName   = optional(string)
      ignoreFlag           = optional(bool, false)
    })), [])

    # Metric settings
    metrics = optional(list(object({
      metricName                             = string
      escalateIncidentAll                    = optional(bool, true)
      thresholdAlertLowerBound               = optional(number, 15)
      thresholdAlertUpperBound               = optional(number, 105)
      thresholdAlertUpperBoundNegative       = optional(number, -20)
      thresholdAlertLowerBoundNegative       = optional(number, -5)
      thresholdNoAlertLowerBound             = optional(number, 50)
      thresholdNoAlertUpperBound             = optional(number, 75)
      thresholdNoAlertLowerBoundNegative     = optional(number, 20)
      thresholdNoAlertUpperBoundNegative     = optional(number, 40)
    })), [])
  })
}

# Local values for processing
locals {
  project_name = var.project_config.project
  
  # Merge email settings with defaults
  email_settings = merge({
    onlySendWithRCA                    = false
    enableNotificationAW               = false
    enableIncidentPredictionEmailAlert = false
    enableIncidentDetectionEmailAlert  = false
    enableAlertsEmail                  = false
    enableRootCauseEmailAlert          = false
    emailDampeningPeriod               = 0
    alertsEmailDampeningPeriod         = 0
    predictionEmailDampeningPeriod     = 0
    enableNewAlertEmail                = false
    alertEmail                         = ""
    predictionEmail                    = ""
    rootCauseEmail                     = ""
    healthAlertEmail                   = ""
    incidentDetectionEmail             = ""
    awSeverityLevel                    = ""
  }, var.project_config.emailSetting)

  # Merge instance grouping settings with defaults
  instance_grouping = merge({
    autoFill = false
  }, var.project_config.instanceGroupingUpdate)
}

# Create comprehensive configuration file
resource "local_file" "project_config" {
  filename = "${path.module}/.terraform/configs/${local.project_name}-config.json"
  content = jsonencode({
    # Required fields
    project   = var.project_config.project
    userName  = var.project_config.userName

    # Basic project settings
    projectName                        = local.project_name
    projectDisplayName                 = coalesce(var.project_config.projectDisplayName, local.project_name)
    cValue                            = var.project_config.cValue
    pValue                            = var.project_config.pValue
    showInstanceDown                  = var.project_config.showInstanceDown
    retentionTime                     = var.project_config.retentionTime
    UBLRetentionTime                  = var.project_config.UBLRetentionTime

    # Advanced project settings
    highRatioCValue                   = var.project_config.highRatioCValue
    maximumHint                       = var.project_config.maximumHint
    dynamicBaselineDetectionFlag      = var.project_config.dynamicBaselineDetectionFlag
    positiveBaselineViolationFactor   = var.project_config.positiveBaselineViolationFactor
    negativeBaselineViolationFactor   = var.project_config.negativeBaselineViolationFactor
    enablePeriodAnomalyFilter         = var.project_config.enablePeriodAnomalyFilter
    enableUBLDetect                   = var.project_config.enableUBLDetect
    enableCumulativeDetect            = var.project_config.enableCumulativeDetect
    predictionTrainingDataLength      = var.project_config.predictionTrainingDataLength
    predictionCorrelationSensitivity  = var.project_config.predictionCorrelationSensitivity
    enableKPIPrediction               = var.project_config.enableKPIPrediction
    instanceDownThreshold             = var.project_config.instanceDownThreshold
    instanceDownReportNumber          = var.project_config.instanceDownReportNumber
    instanceDownEnable                = var.project_config.instanceDownEnable
    modelSpan                         = var.project_config.modelSpan
    enableMetricDataPrediction        = var.project_config.enableMetricDataPrediction
    enableBaselineDetectionDoubleVerify = var.project_config.enableBaselineDetectionDoubleVerify
    enableFillGap                     = var.project_config.enableFillGap
    enableStoreFilledGap              = var.project_config.enableStoreFilledGap
    gapFillingTrainingDataLength      = var.project_config.gapFillingTrainingDataLength
    patternIdGenerationRule           = var.project_config.patternIdGenerationRule
    anomalyGapToleranceCount          = var.project_config.anomalyGapToleranceCount
    filterByAnomalyInBaselineGeneration = var.project_config.filterByAnomalyInBaselineGeneration
    baselineDuration                  = var.project_config.baselineDuration
    anomalyDampening                  = var.project_config.anomalyDampening

    # Prediction and Incident settings
    incidentPredictionWindow          = var.project_config.incidentPredictionWindow
    minIncidentPredictionWindow       = var.project_config.minIncidentPredictionWindow
    incidentRelationSearchWindow      = var.project_config.incidentRelationSearchWindow
    incidentPredictionEventLimit      = var.project_config.incidentPredictionEventLimit
    rootCauseCountThreshold           = var.project_config.rootCauseCountThreshold
    rootCauseProbabilityThreshold     = var.project_config.rootCauseProbabilityThreshold
    compositeRCALimit                 = var.project_config.compositeRCALimit
    rootCauseLogMessageSearchRange    = var.project_config.rootCauseLogMessageSearchRange
    causalPredictionSetting           = var.project_config.causalPredictionSetting
    rootCauseRankSetting              = var.project_config.rootCauseRankSetting
    maximumRootCauseResultSize        = var.project_config.maximumRootCauseResultSize
    multiHopSearchLevel               = var.project_config.multiHopSearchLevel
    multiHopSearchLimit               = var.project_config.multiHopSearchLimit

    # Cost and Alert settings
    avgPerIncidentDowntimeCost        = var.project_config.avgPerIncidentDowntimeCost
    predictionRuleActiveCondition     = var.project_config.predictionRuleActiveCondition
    predictionRuleFalsePositiveThreshold = var.project_config.predictionRuleFalsePositiveThreshold
    predictionRuleActiveThreshold     = var.project_config.predictionRuleActiveThreshold
    predictionRuleInactiveThreshold   = var.project_config.predictionRuleInactiveThreshold
    predictionProbabilityThreshold    = var.project_config.predictionProbabilityThreshold
    alertHourlyCost                   = var.project_config.alertHourlyCost
    alertAverageTime                  = var.project_config.alertAverageTime
    predictionCountThreshold          = var.project_config.predictionCountThreshold

    # System settings
    ignoreInstanceForKB               = var.project_config.ignoreInstanceForKB
    trainingFilter                    = var.project_config.trainingFilter
    projectTimeZone                   = var.project_config.projectTimeZone
    samplingInterval                  = var.project_config.samplingInterval
    minValidModelSpan                 = var.project_config.minValidModelSpan
    maxWebHookRequestSize             = var.project_config.maxWebHookRequestSize
    newPatternRange                   = var.project_config.newPatternRange
    largeProject                      = var.project_config.largeProject
    enableAnomalyScoreEscalation      = var.project_config.enableAnomalyScoreEscalation
    escalationAnomalyScoreThreshold   = var.project_config.escalationAnomalyScoreThreshold
    ignoreAnomalyScoreThreshold       = var.project_config.ignoreAnomalyScoreThreshold
    enableStreamDetection             = var.project_config.enableStreamDetection

    # Webhook settings
    webhookUrl                        = var.project_config.webhookUrl
    webhookHeaderList                 = var.project_config.webhookHeaderList
    webhookTypeSetStr                 = var.project_config.webhookTypeSetStr
    webhookBlackListSetStr            = var.project_config.webhookBlackListSetStr
    webhookCriticalKeywordSetStr      = var.project_config.webhookCriticalKeywordSetStr
    webhookAlertDampening             = var.project_config.webhookAlertDampening
    proxy                             = var.project_config.proxy

    # Email settings
    emailSetting                      = local.email_settings

    # Instance grouping settings
    instanceGroupingUpdate            = local.instance_grouping

    # Lists and collections
    linkedLogProjects                 = var.project_config.linkedLogProjects
    sharedUsernames                   = var.project_config.sharedUsernames
    componentMetricSettingOverallModelList = []

    # Instance data list
    instanceDataList = [
      for instance in var.project_config.instances : {
        instanceName        = instance.instanceName
        instanceDisplayName = coalesce(instance.instanceDisplayName, instance.instanceName)
        containerName       = instance.containerName
        appName             = instance.appName
        metricInstanceName  = instance.metricInstanceName
        ignoreFlag          = instance.ignoreFlag
      }
    ]

    # Metric settings
    metricSettings = [
      for metric in var.project_config.metrics : {
        metricName                         = metric.metricName
        escalateIncidentAll                = metric.escalateIncidentAll
        thresholdAlertLowerBound           = metric.thresholdAlertLowerBound
        thresholdAlertUpperBound           = metric.thresholdAlertUpperBound
        thresholdAlertUpperBoundNegative   = metric.thresholdAlertUpperBoundNegative
        thresholdAlertLowerBoundNegative   = metric.thresholdAlertLowerBoundNegative
        thresholdNoAlertLowerBound         = metric.thresholdNoAlertLowerBound
        thresholdNoAlertUpperBound         = metric.thresholdNoAlertUpperBound
        thresholdNoAlertLowerBoundNegative = metric.thresholdNoAlertLowerBoundNegative
        thresholdNoAlertUpperBoundNegative = metric.thresholdNoAlertUpperBoundNegative
      }
    ]
  })
}

# Apply configuration using null_resource
resource "null_resource" "apply_project_config" {
  triggers = {
    config_file = local_file.project_config.content_md5
    base_url    = var.insightfinder_base_url
    username    = var.insightfinder_username
  }

  provisioner "local-exec" {
    command = "${path.module}/apply-config.sh"
    environment = {
      CONFIG_FILE  = local_file.project_config.filename
      PROJECT_NAME = local.project_name
      BASE_URL     = var.insightfinder_base_url
      USERNAME     = var.insightfinder_username
      PASSWORD     = var.insightfinder_password
    }
  }

  depends_on = [local_file.project_config]
}

# Add delay between requests
resource "time_sleep" "request_delay" {
  create_duration = "1s"
  depends_on      = [null_resource.apply_project_config]
}

# Output the results
output "project_configuration" {
  description = "Status of project configuration"
  value = {
    project_name    = local.project_name
    configured_at   = timestamp()
    instances_count = length(var.project_config.instances)
    metrics_count   = length(var.project_config.metrics)
    config_file     = local_file.project_config.filename
  }
  depends_on = [null_resource.apply_project_config]
}