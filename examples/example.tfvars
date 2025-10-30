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

# ==========================================
# Project Configuration Only
# ==========================================
project_config = {
  project_name       = "existing-project-name"  # Name of existing project to configure
  create_if_not_exists = true

  # Project creation settings (required when create_if_not_exists = true)
  project_creation_config = {
    system_name         = "production-monitoring-cluster"
    data_type          = "Metric"          # Options: Metric, Log, Incident, Alert
    instance_type      = "OnPremise"      # Your instance type
    project_cloud_type = "OnPremise"      # Options: AWS, Azure, GCP, OnPremise
    insight_agent_type = "Custom"         # Agent Type
  }
  
  # ========================================
  # Basic Configuration
  # ========================================
  projectDisplayName = "Metric Project"
  cValue             = 3              # Continues value for project (count)
  pValue             = 0.95           # Probability threshold value for UBL
  retentionTime      = 90             # Data retention time in days
  samplingInterval   = 300            # Sampling interval in seconds (5 minutes)
  
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
# ServiceNow Integration Configuration
# ==========================================
servicenow_config = {
  # ServiceNow Instance Settings
  service_host      = "https://dev296992.service-now.com/"
  proxy            = ""  # Optional proxy server
  account          = "servicenow_username"
  password         = "servicenow_password"
  
  # Integration Settings
  dampening_period = 7200000  # 120 minutes dampening for production
  client_id        = ""  # Optional
  client_secret    = ""  # Optional
  
  # System and Content Configuration
  system_names    = ["Test System 1", "Test System 2"]     # Replace with your actual system names from InsightFinder
  options         = ["Detected Incident", "Root Cause"]    # Options: "Detected Incident", "Detected Incident with RCA", "Predicted Incident", "Root Cause"
  content_option  = ["RECOMMENDATION"]                     # Options: "SUMMARY", "RECOMMENDATION"
}

# ==========================================
# JWT Token Configuration
# ==========================================
jwt_config = {
  jwt_secret  = "your-jwt-secret-key"  # Minimum 6 characters required
  system_name = "Test System 1"       # System name to configure JWT for (must exist in your InsightFinder account)
}

# ==========================================
# DEPLOYMENT INSTRUCTIONS
# ==========================================
# 1. Set your credentials:
#    export TF_VAR_password="your_insightfinder_password"
#    export TF_VAR_license_key="your_license_key"
# 
# 2. Configure services (choose what you need):
#    - Project configuration: Update project_config block above
#    - ServiceNow integration: Update servicenow_config block above  
#    - JWT token settings: Update jwt_config block above
#
# 3. Run terraform:
#    terraform init
#    terraform plan -var-file="examples/example.tfvars"
#    terraform apply -var-file="examples/example.tfvars"
#
# Note: You can use any combination of the configurations above.
# Simply comment out or remove the blocks you don't need.
