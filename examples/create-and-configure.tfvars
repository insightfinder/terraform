# Example: Creating and configuring a project in one step
# This example shows how to create a new project AND configure its settings in one terraform apply

# ==========================================
# Required Connection Settings
# ==========================================
base_url = "https://stg.insightfinder.com"  # Use staging for testing
username = "your_username"
# password and license_key are set via environment variables:
# export TF_VAR_password="your_password"
# export TF_VAR_license_key="your_license_key"

enable_project_creation      = true   # Enable project creation
enable_project_configuration = true   # Enable project configuration
create_if_not_exists         = true   # Create project if it doesn't exist

# ==========================================
# Project Creation Settings
# ==========================================
create_project = {
  project_name         = "web-app-monitoring"
  system_name          = "production-web-cluster"
  data_type           = "Metric"
  instance_type       = "OnPremise"
  project_cloud_type  = "OnPremise"
  insight_agent_type  = "collectd"
}

# ==========================================
# Project Configuration Settings
# ==========================================
project_config = {
  project_name       = "web-app-monitoring"  # Same as create_project.project_name
  
  # Basic Configuration
  projectDisplayName = "Web Application Monitoring"
  cValue             = 3              # Continues value for project (count)
  pValue             = 0.95           # Probability threshold value for UBL
  retentionTime      = 90             # Data retention time in days
  samplingInterval   = 600            # Sampling interval in seconds (10 minutes)
  
  # Advanced Detection Settings
  dynamicBaselineDetectionFlag = true   # Enable dynamic baseline detection
  enableUBLDetect = true                # Enable UBL anomaly detection
  enableCumulativeDetect = false       # Disable cumulative detection
  modelSpan = 0                        # Model span (0=daily, 1=monthly)
  
  # Instance Grouping Data
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
# 2. Update the project names and settings above
# 
# 3. Run terraform:
#    terraform init
#    terraform plan -var-file="examples/create-and-configure.tfvars"
#    terraform apply -var-file="examples/create-and-configure.tfvars"