# Complex Configuration Example - consumerMetricSetting & instanceGroupingSetting
# This demonstrates how to configure metric thresholds and instance groupings in Terraform

# Connection settings
base_url     = "https://app.insightfinder.com"
username     = "your_username" 
project_name = "example-advanced-project"

# Basic settings
cValue             = 3
pValue             = 0.95
projectDisplayName = "Example Advanced Project"

# Complex configurations via project_config
project_config = {
  # consumerMetricSetting equivalent - Component Metric Settings
  componentMetricSettingOverallModelList = [
    {
      metricName                        = "cpu_usage"
      escalateIncidentAll              = true
      thresholdAlertLowerBound         = 15
      thresholdAlertUpperBound         = 105
      thresholdAlertUpperBoundNegative = -20
      thresholdAlertLowerBoundNegative = -5
      thresholdNoAlertLowerBound       = 50
      thresholdNoAlertUpperBound       = 75
      thresholdNoAlertLowerBoundNegative = 20
      thresholdNoAlertUpperBoundNegative = 40
    },
    {
      metricName                        = "memory_usage"
      escalateIncidentAll              = true
      thresholdAlertLowerBound         = 15
      thresholdAlertUpperBound         = 105
      thresholdAlertUpperBoundNegative = -20
      thresholdAlertLowerBoundNegative = -5
      thresholdNoAlertLowerBound       = 50
      thresholdNoAlertUpperBound       = 75
      thresholdNoAlertLowerBoundNegative = 20
      thresholdNoAlertUpperBoundNegative = 40
    },
    {
      metricName                        = "network_connections"
      escalateIncidentAll              = false
      thresholdAlertLowerBound         = 5
      thresholdAlertUpperBound         = 95
      thresholdAlertUpperBoundNegative = -10
      thresholdAlertLowerBoundNegative = -2
      thresholdNoAlertLowerBound       = 20
      thresholdNoAlertUpperBound       = 80
      thresholdNoAlertLowerBoundNegative = 10
      thresholdNoAlertUpperBoundNegative = 25
    }
  ]

  # instanceGroupingSetting equivalent - Instance Grouping Update
  instanceGroupingUpdate = {
    instanceDataList = [
      {
        instanceName        = "server-001"
        instanceDisplayName = "Server 001"
        containerName      = "web-container"
        component          = "web-service"
        ignoreFlag         = false
      },
      {
        instanceName        = "server-002"
        instanceDisplayName = "Server 002"
        containerName      = "api-container"
        component          = "api-service"
        ignoreFlag         = false
      },
      {
        instanceName        = "database-001"
        instanceDisplayName = "Database Server 001"
        containerName      = "db-container"
        component          = "database-service"
        ignoreFlag         = false
      },
      {
        instanceName        = "cache-001"
        instanceDisplayName = "Cache Server 001" 
        containerName      = "cache-container"
        component          = "cache-service"
        ignoreFlag         = true
      }
    ]
    autoFill = false
  }

  # Additional settings you can combine
  retentionTime      = 90
  samplingInterval   = 600
  showInstanceDown   = false
  projectTimeZone    = "US/Eastern"
}