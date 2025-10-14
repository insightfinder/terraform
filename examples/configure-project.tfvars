# Example: Configuring an existing project
# This example shows how to configure an existing project's settings

# ==========================================
# Required Connection Settings
# ==========================================
base_url = "https://stg.insightfinder.com"  # Use staging for testing
username = "your_username"
# password and license_key are set via environment variables:
# export TF_VAR_password="your_password"
# export TF_VAR_license_key="your_license_key"

enable_project_configuration = true   # Enable project configuration

project_config = {
  project_name       = "existing-project-name"  # Name of existing project to configure
  
  # ========================================
  # Basic Configuration
  # ========================================
  projectDisplayName = "Metric Project"
  cValue             = 3              # Continues value for project (count)
  pValue             = 0.95           # Probability threshold value for UBL
  retentionTime      = 123             # Data retention time in days
  samplingInterval   = 600            # Sampling interval in seconds (5 minutes)
  
  # ========================================
  # Advanced Detection Settings
  # ========================================
  dynamicBaselineDetectionFlag = true   # Enable dynamic baseline detection
  enableUBLDetect = true                # Enable UBL anomaly detection
  enableCumulativeDetect = false       # Disable cumulative detection
  modelSpan = 0                        # Model span (0=daily, 1=monthly)
  
  componentMetricSettingOverallModelList = [
    {
      metricName                        = "Metric-1"
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
      metricName                        = "Metric-2"
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
        instanceName        = "instance1"
        instanceDisplayName = "Server 001"
        appName      = "web-container"
        component          = "web-service"
        ignoreFlag         = false
      },
      {
        instanceName        = "instance2"
        instanceDisplayName = "Server 002"
        appName      = "api-container"
        component          = "api-service"
        ignoreFlag         = false
      },
      {
        instanceName        = "instance3"
        instanceDisplayName = "Database Server 001"
        appName      = "db-container"
        component          = "database-service"
        ignoreFlag         = false
      },
      {
        instanceName        = "instance4"
        instanceDisplayName = "Cache Server 001" 
        appName      = "cache-container"
        component          = "cache-service"
        ignoreFlag         = true
      }
    ]
  }
}

# ==========================================
# DEPLOYMENT INSTRUCTIONS
# ==========================================
# 1. Set your credentials:
#    export TF_VAR_password="your_insightfinder_password"
#    export TF_VAR_license_key="your_license_key"
# 
# 2. Run terraform:
#    terraform init
#    terraform plan -var-file="examples/configure-project.tfvars"
#    terraform apply -var-file="examples/configure-project.tfvars"
