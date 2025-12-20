# InsightFinder Terraform Configuration
# This module provides clean, structured configuration for InsightFinder projects
# Module Version: 2.1.0

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

# Read module version from VERSION file
locals {
  module_version = trimspace(file("${path.module}/VERSION"))
}

# API Client Module - Provides shared authentication configuration
module "api_client" {
  source = "./modules/api_client"

  base_url    = var.base_url
  username    = var.username
  license_key = var.license_key
}

# Project Configuration Module - Configures projects and can create them if they don't exist
module "project_config" {
  count  = var.project_config != null ? 1 : 0
  source = "./modules/project_config"

  # Project identification
  project_name            = var.project_config.project_name
  create_if_not_exists    = try(var.project_config.create_if_not_exists, false)
  project_creation_config = try(var.project_config.project_creation_config, null)
  api_config              = module.api_client.auth_config

  # All configuration fields - explicitly pass each variable
  UBLRetentionTime                       = try(var.project_config.UBLRetentionTime, null)
  alertAverageTime                       = try(var.project_config.alertAverageTime, null)
  alertHourlyCost                        = try(var.project_config.alertHourlyCost, null)
  anomalyDetectionMode                   = try(var.project_config.anomalyDetectionMode, null)
  anomalySamplingInterval                = try(var.project_config.anomalySamplingInterval, null)
  avgPerIncidentDowntimeCost             = try(var.project_config.avgPerIncidentDowntimeCost, null)
  baseValueSetting                       = try(var.project_config.baseValueSetting, null)
  cValue                                 = try(var.project_config.cValue, null)
  causalMinDelay                         = try(var.project_config.causalMinDelay, null)
  causalPredictionSetting                = try(var.project_config.causalPredictionSetting, null)
  cdfSetting                             = try(var.project_config.cdfSetting, null)
  coldEventThreshold                     = try(var.project_config.coldEventThreshold, null)
  coldNumberLimit                        = try(var.project_config.coldNumberLimit, null)
  collectAllRareEventsFlag               = try(var.project_config.collectAllRareEventsFlag, null)
  dailyModelSpan                         = try(var.project_config.dailyModelSpan, null)
  disableLogCompressEvent                = try(var.project_config.disableLogCompressEvent, null)
  disableModelKeywordStatsCollection     = try(var.project_config.disableModelKeywordStatsCollection, null)
  emailSetting                           = try(var.project_config.emailSetting, null)
  enableAnomalyScoreEscalation           = try(var.project_config.enableAnomalyScoreEscalation, null)
  enableHotEvent                         = try(var.project_config.enableHotEvent, null)
  enableNewAlertEmail                    = try(var.project_config.enableNewAlertEmail, null)
  enableStreamDetection                  = try(var.project_config.enableStreamDetection, null)
  escalationAnomalyScoreThreshold        = try(var.project_config.escalationAnomalyScoreThreshold, null)
  featureOutlierSensitivity              = try(var.project_config.featureOutlierSensitivity, null)
  featureOutlierThreshold                = try(var.project_config.featureOutlierThreshold, null)
  hotEventCalmDownPeriod                 = try(var.project_config.hotEventCalmDownPeriod, null)
  hotEventDetectionMode                  = try(var.project_config.hotEventDetectionMode, null)
  hotEventThreshold                      = try(var.project_config.hotEventThreshold, null)
  hotNumberLimit                         = try(var.project_config.hotNumberLimit, null)
  ignoreAnomalyScoreThreshold            = try(var.project_config.ignoreAnomalyScoreThreshold, null)
  ignoreInstanceForKB                    = try(var.project_config.ignoreInstanceForKB, null)
  incidentConsolidationInterval          = try(var.project_config.incidentConsolidationInterval, null)
  incidentCountThreshold                 = try(var.project_config.incidentCountThreshold, null)
  incidentDurationThreshold              = try(var.project_config.incidentDurationThreshold, null)
  incidentPredictionEventLimit           = try(var.project_config.incidentPredictionEventLimit, null)
  incidentPredictionWindow               = try(var.project_config.incidentPredictionWindow, null)
  incidentRelationSearchWindow           = try(var.project_config.incidentRelationSearchWindow, null)
  instanceConvertFlag                    = try(var.project_config.instanceConvertFlag, null)
  instanceDownEnable                     = try(var.project_config.instanceDownEnable, null)
  instanceGroupingUpdate                 = try(var.project_config.instanceGroupingUpdate, null)
  isEdgeBrain                            = try(var.project_config.isEdgeBrain, null)
  isGroupingByInstance                   = try(var.project_config.isGroupingByInstance, null)
  isTracePrompt                          = try(var.project_config.isTracePrompt, null)
  keywordFeatureNumber                   = try(var.project_config.keywordFeatureNumber, null)
  keywordSetting                         = try(var.project_config.keywordSetting, null)
  largeProject                           = try(var.project_config.largeProject, null)
  llmEvaluationSetting                   = try(var.project_config.llmEvaluationSetting, null)
  logAnomalyEventBaseScore               = try(var.project_config.logAnomalyEventBaseScore, null)
  logDetectionMinCount                   = try(var.project_config.logDetectionMinCount, null)
  logDetectionSize                       = try(var.project_config.logDetectionSize, null)
  logPatternLimitLevel                   = try(var.project_config.logPatternLimitLevel, null)
  logToLogSettingList                    = try(var.project_config.logToLogSettingList, null)
  maxLogModelSize                        = try(var.project_config.maxLogModelSize, null)
  maxWebHookRequestSize                  = try(var.project_config.maxWebHookRequestSize, null)
  maximumDetectionWaitTime               = try(var.project_config.maximumDetectionWaitTime, null)
  maximumRootCauseResultSize             = try(var.project_config.maximumRootCauseResultSize, null)
  maximumThreads                         = try(var.project_config.maximumThreads, null)
  minIncidentPredictionWindow            = try(var.project_config.minIncidentPredictionWindow, null)
  minValidModelSpan                      = try(var.project_config.minValidModelSpan, null)
  modelKeywordSetting                    = try(var.project_config.modelKeywordSetting, null)
  multiHopSearchLevel                    = try(var.project_config.multiHopSearchLevel, null)
  multiHopSearchLimit                    = try(var.project_config.multiHopSearchLimit, null)
  multiLineFlag                          = try(var.project_config.multiLineFlag, null)
  newAlertFlag                           = try(var.project_config.newAlertFlag, null)
  newPatternNumberLimit                  = try(var.project_config.newPatternNumberLimit, null)
  newPatternRange                        = try(var.project_config.newPatternRange, null)
  nlpFlag                                = try(var.project_config.nlpFlag, null)
  normalEventCausalFlag                  = try(var.project_config.normalEventCausalFlag, null)
  pValue                                 = try(var.project_config.pValue, null)
  predictionCountThreshold               = try(var.project_config.predictionCountThreshold, null)
  predictionProbabilityThreshold         = try(var.project_config.predictionProbabilityThreshold, null)
  predictionRuleActiveCondition          = try(var.project_config.predictionRuleActiveCondition, null)
  predictionRuleActiveThreshold          = try(var.project_config.predictionRuleActiveThreshold, null)
  predictionRuleFalsePositiveThreshold   = try(var.project_config.predictionRuleFalsePositiveThreshold, null)
  predictionRuleInactiveThreshold        = try(var.project_config.predictionRuleInactiveThreshold, null)
  prettyJsonConvertorFlag                = try(var.project_config.prettyJsonConvertorFlag, null)
  projectDisplayName                     = try(var.project_config.projectDisplayName, null)
  projectModelFlag                       = try(var.project_config.projectModelFlag, null)
  projectTimeZone                        = try(var.project_config.projectTimeZone, null)
  proxy                                  = try(var.project_config.proxy, null)
  rareAnomalyType                        = try(var.project_config.rareAnomalyType, null)
  rareEventAlertThresholds               = try(var.project_config.rareEventAlertThresholds, null)
  rareNumberLimit                        = try(var.project_config.rareNumberLimit, null)
  retentionTime                          = try(var.project_config.retentionTime, null)
  rootCauseCountThreshold                = try(var.project_config.rootCauseCountThreshold, null)
  rootCauseLogMessageSearchRange         = try(var.project_config.rootCauseLogMessageSearchRange, null)
  rootCauseProbabilityThreshold          = try(var.project_config.rootCauseProbabilityThreshold, null)
  rootCauseRankSetting                   = try(var.project_config.rootCauseRankSetting, null)
  samplingInterval                       = try(var.project_config.samplingInterval, null)
  sharedUsernames                        = try(var.project_config.sharedUsernames, null)
  showInstanceDown                       = try(var.project_config.showInstanceDown, null)
  similaritySensitivity                  = try(var.project_config.similaritySensitivity, null)
  trainingFilter                         = try(var.project_config.trainingFilter, null)
  webhookAlertDampening                  = try(var.project_config.webhookAlertDampening, null)
  webhookBlackListSetStr                 = try(var.project_config.webhookBlackListSetStr, null)
  webhookCriticalKeywordSetStr           = try(var.project_config.webhookCriticalKeywordSetStr, null)
  webhookHeaderList                      = try(var.project_config.webhookHeaderList, null)
  webhookTypeSetStr                      = try(var.project_config.webhookTypeSetStr, null)
  webhookUrl                             = try(var.project_config.webhookUrl, null)
  whitelistNumberLimit                   = try(var.project_config.whitelistNumberLimit, null)
  zoneNameKey                            = try(var.project_config.zoneNameKey, null)
  
  # Special handling for logLabelSettingCreate
  logLabelSettingCreate = try(var.project_config.logLabelSettingCreate, null)
  
  # Legacy metric project variables
  instanceGroupingData                   = try(var.project_config.instanceGroupingData, null)
  highRatioCValue                        = try(var.project_config.highRatioCValue, null)
  dynamicBaselineDetectionFlag           = try(var.project_config.dynamicBaselineDetectionFlag, null)
  positiveBaselineViolationFactor        = try(var.project_config.positiveBaselineViolationFactor, null)
  negativeBaselineViolationFactor        = try(var.project_config.negativeBaselineViolationFactor, null)
  enablePeriodAnomalyFilter              = try(var.project_config.enablePeriodAnomalyFilter, null)
  enableUBLDetect                        = try(var.project_config.enableUBLDetect, null)
  enableCumulativeDetect                 = try(var.project_config.enableCumulativeDetect, null)
  instanceDownThreshold                  = try(var.project_config.instanceDownThreshold, null)
  instanceDownReportNumber               = try(var.project_config.instanceDownReportNumber, null)
  modelSpan                              = try(var.project_config.modelSpan, null)
  enableMetricDataPrediction             = try(var.project_config.enableMetricDataPrediction, null)
  enableBaselineDetectionDoubleVerify    = try(var.project_config.enableBaselineDetectionDoubleVerify, null)
  enableFillGap                          = try(var.project_config.enableFillGap, null)
  patternIdGenerationRule                = try(var.project_config.patternIdGenerationRule, null)
  anomalyGapToleranceCount               = try(var.project_config.anomalyGapToleranceCount, null)
  filterByAnomalyInBaselineGeneration    = try(var.project_config.filterByAnomalyInBaselineGeneration, null)
  baselineDuration                       = try(var.project_config.baselineDuration, null)
  componentMetricSettingOverallModelList = try(var.project_config.componentMetricSettingOverallModelList, null)
  enableBaselineNearConstance            = try(var.project_config.enableBaselineNearConstance, null)
  computeDifference                      = try(var.project_config.computeDifference, null)
}

# ServiceNow Configuration Module - Configures ServiceNow integration
module "servicenow_config" {
  count  = var.servicenow_config != null ? 1 : 0
  source = "./modules/servicenow_config"

  servicenow_config = var.servicenow_config != null ? merge(var.servicenow_config, {
    # Map user-facing client_id/client_secret to API app_id/app_key
    app_id  = var.servicenow_config.client_id
    app_key = var.servicenow_config.client_secret
  }) : null
  api_config = module.api_client.auth_config

  # Ensure authentication is completed first
  depends_on = [module.api_client]
}

# JWT Configuration Module - Configures JWT token settings
module "jwt_config" {
  count  = var.jwt_config != null ? 1 : 0
  source = "./modules/jwt_config"

  jwt_config = var.jwt_config
  api_config = module.api_client.auth_config

  # Ensure authentication is completed first
  depends_on = [module.api_client]
}

# Output configuration status
output "configuration_status" {
  description = "Configuration application status"
  value = {
    project_name          = var.project_config != null ? var.project_config.project_name : null
    project_configured    = var.project_config != null
    create_if_not_exists  = var.project_config != null ? try(var.project_config.create_if_not_exists, false) : false
    servicenow_configured = var.servicenow_config != null
    jwt_configured        = var.jwt_config != null
    applied_at            = timestamp()
  }
  sensitive  = true
  depends_on = [module.project_config, module.servicenow_config, module.jwt_config]
}

# ServiceNow configuration output
output "servicenow_status" {
  description = "ServiceNow integration configuration status"
  value = var.servicenow_config != null ? {
    configured   = true
    service_host = var.servicenow_config.service_host
    account      = var.servicenow_config.account
    client_id    = var.servicenow_config.client_id
    system_count = length(var.servicenow_config.system_names)
  } : null
  sensitive  = true
  depends_on = [module.servicenow_config]
}

# JWT configuration output
output "jwt_status" {
  description = "JWT configuration status"
  value = var.jwt_config != null ? {
    configured    = true
    system_name   = var.jwt_config.system_name
    secret_length = length(var.jwt_config.jwt_secret)
  } : null
  sensitive  = true
  depends_on = [module.jwt_config]
}

# Module version output
output "module_version" {
  description = "InsightFinder Terraform Module version"
  value = {
    version   = local.module_version
    changelog = "See CHANGELOG.md for version history"
    source    = "https://github.com/insightfinder/terraform"
  }
}