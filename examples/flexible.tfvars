# Flexible Configuration - Recommended approach
base_url = "https://app.insightfinder.com" 
username = "your_username"
project_name = "example-flexible-project"

# Use project_config for maximum flexibility and future-proofing
project_config = {
  # Core fields
  cValue             = 3
  pValue             = 0.95
  showInstanceDown   = false
  retentionTime      = 90
  projectDisplayName = "Example Flexible Project"
  samplingInterval   = 600

  # Advanced fields
  UBLRetentionTime               = 8
  dynamicBaselineDetectionFlag   = true
  enableUBLDetect                = true
  enableCumulativeDetect         = false
  highRatioCValue                = 5

  # Future fields - any new fields work automatically
  # customFeature = "enabled"
  # advancedSettings = { threshold = 95.5 }
}