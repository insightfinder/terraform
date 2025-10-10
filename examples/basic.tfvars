# Basic example configuration
insightfinder_base_url = "https://app.insightfinder.com"
insightfinder_username = "your-username"
# insightfinder_password is set via environment variable: TF_VAR_insightfinder_password

project_config = {
  project            = "basic-example"
  userName          = "your-username"
  projectDisplayName = "Basic Example Project"
  cValue            = 3
  pValue            = 0.95
  showInstanceDown  = false
  retentionTime     = 90
  UBLRetentionTime  = 8

  instances = [
    {
      instanceName        = "web-server-1"
      instanceDisplayName = "Web Server 1"
      containerName       = "nginx"
      appName            = "web-frontend"
      ignoreFlag         = false
    },
    {
      instanceName        = "database-1"
      instanceDisplayName = "Database Server 1"
      containerName       = "postgres"
      appName            = "database"
      ignoreFlag         = false
    }
  ]

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
      metricName                     = "cpu_usage"
      escalateIncidentAll            = true
      thresholdAlertLowerBound       = 10
      thresholdAlertUpperBound       = 90
      thresholdNoAlertLowerBound     = 30
      thresholdNoAlertUpperBound     = 70
    }
  ]
}