# Basic Configuration Example
# This example shows more than minimal fields but not all available options

# InsightFinder connection settings
base_url = "https://app.insightfinder.com"
username = "your_username"
# password is set via environment variable: TF_VAR_password

# Project configuration with additional fields
project_name = "example-project"
projectDisplayName = "Basic Example Project"

# Core required settings
cValue           = 3
pValue           = 0.95
showInstanceDown = false
retentionTime    = 90
samplingInterval = 600

# Additional basic settings
UBLRetentionTime = 8
highRatioCValue  = 5
dynamicBaselineDetectionFlag = true
enableUBLDetect = true
enableCumulativeDetect = false