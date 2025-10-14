# Example: Creating a new project only
# This example shows how to create a new project without configuring it

# ==========================================
# Required Connection Settings
# ==========================================
base_url = "https://stg.insightfinder.com"  # Use staging for testing
username = "your_username"
# password and license_key are set via environment variables:
# export TF_VAR_password="your_password"
# export TF_VAR_license_key="your_license_key"

enable_project_creation      = true   # Enable project creation
enable_project_configuration = false  # Disable configuration

create_project = {
  project_name         = "my-new-metrics-project"
  system_name          = "production-monitoring-cluster"
  data_type           = "Metric"          # Options: Metric, Log, Incident, Alert
  instance_type       = "OnPremise"      # Your instance type
  project_cloud_type  = "OnPremise"      # Options: AWS, Azure, GCP, OnPremise
  insight_agent_type  = "collectd"       # Use collectd for metrics
}

# ==========================================
# DEPLOYMENT INSTRUCTIONS
# ==========================================
# 1. Set your credentials:
#    export TF_VAR_password="your_insightfinder_password"
#    export TF_VAR_license_key="your_license_key"
# 
# 2. Update the settings above with your values
# 
# 3. Run terraform:
#    terraform init
#    terraform plan -var-file="examples/create-project.tfvars"
#    terraform apply -var-file="examples/create-project.tfvars"
