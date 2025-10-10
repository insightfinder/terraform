# Advanced example with email settings and webhooks
insightfinder_base_url = "https://app.insightfinder.com"
insightfinder_username = "your-username"
# insightfinder_password is set via environment variable: TF_VAR_insightfinder_password

project_config = {
  project                = "advanced-example"
  userName              = "your-username"
  projectDisplayName    = "Advanced Production Monitoring"
  
  # Advanced settings
  cValue                            = 3
  pValue                            = 0.95
  highRatioCValue                   = 3
  dynamicBaselineDetectionFlag      = true
  enableUBLDetect                   = true
  enableKPIPrediction               = true
  enableMetricDataPrediction        = true
  
  # Email configuration
  emailSetting = {
    enableAlertsEmail                  = true
    enableIncidentPredictionEmailAlert = true
    enableRootCauseEmailAlert          = true
    alertEmail                        = "alerts@company.com"
    predictionEmail                   = "predictions@company.com"
    rootCauseEmail                    = "rca@company.com"
    emailDampeningPeriod              = 3600000
    alertsEmailDampeningPeriod        = 1800000
    predictionEmailDampeningPeriod    = 7200000
  }

  # Webhook configuration
  webhookUrl = "https://company.com/webhook/insightfinder"
  webhookHeaderList = ["Authorization: Bearer YOUR_TOKEN", "Content-Type: application/json"]
  webhookAlertDampening = 1800000

  # Instance configuration
  instances = [
    {
      instanceName        = "prod-web-1"
      instanceDisplayName = "Production Web Server 1"
      containerName       = "nginx"
      appName            = "web-frontend"
      ignoreFlag         = false
    },
    {
      instanceName        = "prod-web-2"
      instanceDisplayName = "Production Web Server 2"
      containerName       = "nginx"
      appName            = "web-frontend"
      ignoreFlag         = false
    },
    {
      instanceName        = "prod-db-1"
      instanceDisplayName = "Production Database 1"
      containerName       = "postgres"
      appName            = "database"
      ignoreFlag         = false
    },
    {
      instanceName        = "prod-cache-1"
      instanceDisplayName = "Production Cache 1"
      containerName       = "redis"
      appName            = "cache"
      ignoreFlag         = false
    }
  ]

  # Metric configuration with custom thresholds
  metrics = [
    {
      metricName                     = "response_time"
      escalateIncidentAll            = true
      thresholdAlertLowerBound       = 100
      thresholdAlertUpperBound       = 5000
      thresholdNoAlertLowerBound     = 200
      thresholdNoAlertUpperBound     = 3000
    },
    {
      metricName                     = "error_rate"
      escalateIncidentAll            = true
      thresholdAlertLowerBound       = 0.1
      thresholdAlertUpperBound       = 10.0
      thresholdNoAlertLowerBound     = 0.5
      thresholdNoAlertUpperBound     = 5.0
    },
    {
      metricName                     = "cpu_usage"
      escalateIncidentAll            = true
      thresholdAlertLowerBound       = 10
      thresholdAlertUpperBound       = 90
      thresholdNoAlertLowerBound     = 30
      thresholdNoAlertUpperBound     = 70
    },
    {
      metricName                     = "memory_usage"
      escalateIncidentAll            = true
      thresholdAlertLowerBound       = 20
      thresholdAlertUpperBound       = 85
      thresholdNoAlertLowerBound     = 40
      thresholdNoAlertUpperBound     = 75
    },
    {
      metricName                     = "disk_usage"
      escalateIncidentAll            = false
      thresholdAlertLowerBound       = 40
      thresholdAlertUpperBound       = 95
      thresholdNoAlertLowerBound     = 60
      thresholdNoAlertUpperBound     = 85
    }
  ]

  # Advanced prediction settings
  incidentPredictionWindow       = 24
  minIncidentPredictionWindow    = 6
  incidentRelationSearchWindow   = 12
  rootCauseProbabilityThreshold  = 0.85
  
  # Cost settings
  avgPerIncidentDowntimeCost     = 10000.0
  alertHourlyCost               = 500.0
}