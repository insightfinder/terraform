# Project Configuration Module
# This module configures an existing InsightFinder project

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

# Check if project exists first
resource "null_resource" "check_project_exists" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Checking if project '${var.project_name}' exists for configuration..."
      
      # Create form data for project check
      response=$(curl -s -w "\nHTTP_STATUS:%%{http_code}" \
        -X POST \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "operation=check" \
        -d "userName=${var.api_config.username}" \
        -d "licenseKey=${var.api_config.license_key}" \
        -d "projectName=${var.project_name}" \
        "${var.api_config.base_url}/api/v1/check-and-add-custom-project")
      
      # Extract response body and status code
      body=$(echo "$response" | sed '$d')
      status=$(echo "$response" | tail -n1 | sed 's/.*HTTP_STATUS://')
      
      echo "Project Check Response Status: $status"
      echo "Project Check Response Body: $body"
      
      # Save response for next step
      echo "$body" > "/tmp/project-config-check-${var.project_name}.json"
      echo "$status" > "/tmp/project-config-status-${var.project_name}.txt"
    EOT
  }

  triggers = {
    project_name = var.project_name
    username     = var.api_config.username
  }
}

# Create project if it doesn't exist and create_if_not_exists is true
resource "null_resource" "create_project_if_needed" {
  count      = var.create_if_not_exists ? 1 : 0
  depends_on = [null_resource.check_project_exists]
  
  provisioner "local-exec" {
    command = <<-EOT
      # Check if project already exists
      if [ -f "/tmp/project-config-check-${var.project_name}.json" ]; then
        check_response=$(cat "/tmp/project-config-check-${var.project_name}.json")
        check_status=$(cat "/tmp/project-config-status-${var.project_name}.txt")
        
        if [ "$check_status" = "200" ]; then
          # Parse JSON to check if project exists (basic check)
          if echo "$check_response" | grep -q '"isProjectExist":true'; then
            echo "✅ Project '${var.project_name}' already exists. Proceeding to configuration."
            exit 0
          fi
        fi
      fi
      
      echo "Creating project '${var.project_name}' as it doesn't exist..."
      
      # Create form data for project creation
      response=$(curl -s -w "\nHTTP_STATUS:%%{http_code}" \
        -X POST \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "operation=create" \
        -d "userName=${var.api_config.username}" \
        -d "licenseKey=${var.api_config.license_key}" \
        -d "projectName=${var.project_name}" \
        -d "systemName=${var.project_creation_config.system_name}" \
        -d "dataType=${var.project_creation_config.data_type}" \
        -d "instanceType=${var.project_creation_config.instance_type}" \
        -d "projectCloudType=${var.project_creation_config.project_cloud_type}" \
        -d "insightAgentType=${var.project_creation_config.insight_agent_type}" \
        "${var.api_config.base_url}/api/v1/check-and-add-custom-project")
      
      # Extract response body and status code
      body=$(echo "$response" | sed '$d')
      status=$(echo "$response" | tail -n1 | sed 's/.*HTTP_STATUS://')
      
      echo "Project Creation Response Status: $status"
      echo "Project Creation Response Body: $body"
      
      # Check for credential errors first
      if echo "$body" | grep -q "does not match our records"; then
        echo "❌ Authentication failed. Please check your username and license key."
        echo "Username: ${var.api_config.username}"
        echo "License Key: [REDACTED - first 8 chars: $(echo "${var.api_config.license_key}" | cut -c1-8)...]"
        exit 1
      fi
      
      # Check if request was successful
      if [ "$status" -eq 200 ]; then
        # Check if response indicates success
        if echo "$body" | grep -q '"success":true' || echo "$body" | grep -q '"isSuccess":true'; then
          echo "✅ Project '${var.project_name}' created successfully!"
          echo "$body" > "project-creation-response-${var.project_name}.json"
        else
          echo "❌ Project creation failed. API returned success=false"
          echo "Response: $body"
          exit 1
        fi
      elif [ "$status" -eq 500 ]; then
        # Check if this is a "project already exists" error by trying to check again
        echo "⚠️ Got HTTP 500, checking if project already exists..."
        check_response=$(curl -s -w "\nHTTP_STATUS:%%{http_code}" \
          -X POST \
          -H "Content-Type: application/x-www-form-urlencoded" \
          -d "operation=check" \
          -d "userName=${var.api_config.username}" \
          -d "licenseKey=${var.api_config.license_key}" \
          -d "projectName=${var.project_name}" \
          "${var.api_config.base_url}/api/v1/check-and-add-custom-project")
        
        check_body=$(echo "$check_response" | sed '$d')
        check_status=$(echo "$check_response" | tail -n1 | sed 's/.*HTTP_STATUS://')
        
        if [ "$check_status" -eq 200 ] && echo "$check_body" | grep -q '"isProjectExist":true'; then
          echo "✅ Project '${var.project_name}' already exists (confirmed after 500 error)."
          echo "$check_body" > "project-creation-response-${var.project_name}.json"
        else
          echo "❌ Failed to create project. HTTP Status: $status"
          echo "Response: $body"
          exit 1
        fi
      else
        echo "❌ Failed to create project. HTTP Status: $status"
        echo "Response: $body"
        exit 1
      fi
      
      # Cleanup temp files
      rm -f "/tmp/project-config-check-${var.project_name}.json"
      rm -f "/tmp/project-config-status-${var.project_name}.txt"
    EOT
  }

  triggers = {
    project_name         = var.project_name
    system_name          = var.project_creation_config.system_name
    data_type           = var.project_creation_config.data_type
    instance_type       = var.project_creation_config.instance_type
    project_cloud_type  = var.project_creation_config.project_cloud_type
    insight_agent_type  = var.project_creation_config.insight_agent_type
    username            = var.api_config.username
  }
}

# Create final configuration by merging individual variables with project_config
locals {
  # Build config from individual variables (only non-null values, matching OpenAPI spec)
  individual_fields = {
    for k, v in {
      cValue                              = var.cValue
      pValue                              = var.pValue
      showInstanceDown                    = var.showInstanceDown
      retentionTime                       = var.retentionTime
      UBLRetentionTime                   = var.UBLRetentionTime
      projectDisplayName                  = var.projectDisplayName
      samplingInterval                    = var.samplingInterval
      instanceGroupingData                = var.instanceGroupingData
      highRatioCValue                    = var.highRatioCValue
      dynamicBaselineDetectionFlag       = var.dynamicBaselineDetectionFlag
      positiveBaselineViolationFactor    = var.positiveBaselineViolationFactor
      negativeBaselineViolationFactor    = var.negativeBaselineViolationFactor
      enablePeriodAnomalyFilter          = var.enablePeriodAnomalyFilter
      enableUBLDetect                    = var.enableUBLDetect
      enableCumulativeDetect             = var.enableCumulativeDetect
      instanceDownThreshold              = var.instanceDownThreshold
      instanceDownReportNumber           = var.instanceDownReportNumber
      instanceDownEnable                 = var.instanceDownEnable
      modelSpan                          = var.modelSpan
      enableMetricDataPrediction         = var.enableMetricDataPrediction
      enableBaselineDetectionDoubleVerify = var.enableBaselineDetectionDoubleVerify
      enableFillGap                      = var.enableFillGap
      patternIdGenerationRule            = var.patternIdGenerationRule
      anomalyGapToleranceCount           = var.anomalyGapToleranceCount
      filterByAnomalyInBaselineGeneration = var.filterByAnomalyInBaselineGeneration
      baselineDuration                   = var.baselineDuration
      componentMetricSettingOverallModelList = var.componentMetricSettingOverallModelList
      enableBaselineNearConstance        = var.enableBaselineNearConstance
      computeDifference                  = var.computeDifference
    } : k => v if v != null
  }
  
  # Merge individual fields with project_config (project_config takes precedence)
  final_config = merge(local.individual_fields, var.project_config)
  
  # Extract only the config fields for API call (remove metadata)
  api_config = try(var.project_config.config, {})
}

# Generate configuration JSON file (includes all metadata for reference)
resource "local_file" "config" {
  content  = jsonencode(local.final_config)
  filename = "${path.module}/generated-config.json"
}

# Generate API-specific configuration JSON file (only config fields)
resource "local_file" "api_config" {
  content  = jsonencode(local.api_config)
  filename = "${path.module}/api-config.json"
}

# Apply configuration to InsightFinder API
resource "null_resource" "apply_config" {
  depends_on = [
    local_file.config,
    local_file.api_config,
    null_resource.check_project_exists,
    null_resource.create_project_if_needed
  ]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Applying configuration to project '${var.project_name}'..."
      
      # Verify project exists before applying configuration
      if [ -f "/tmp/project-config-check-${var.project_name}.json" ]; then
        check_response=$(cat "/tmp/project-config-check-${var.project_name}.json")
        check_status=$(cat "/tmp/project-config-status-${var.project_name}.txt")
        
        if [ "$check_status" = "200" ]; then
          if ! echo "$check_response" | grep -q '"isProjectExist":true'; then
            if [ "${var.create_if_not_exists}" = "false" ]; then
              echo "❌ Project '${var.project_name}' does not exist and create_if_not_exists is false"
              exit 1
            else
              echo "📋 Project '${var.project_name}' does not exist but create_if_not_exists is true, will be handled by create_project_if_needed resource"
            fi
          fi
        fi
      fi
      
      # Read configuration from generated config file (use full config like working script)
      config_json=$(cat "${local_file.config.filename}")
      
      # Validate JSON
      if ! echo "$config_json" | python3 -c "import json,sys; json.load(sys.stdin)" > /dev/null 2>&1; then
        echo "❌ Invalid JSON in config file"
        exit 1
      fi
      
      # Step 1: Authenticate and get token
      echo "Getting authentication token..."
      
      # Create temporary cookie jar
      cookie_jar=$(mktemp)
      trap "rm -f $cookie_jar" EXIT
      
      # URL encode password
      encoded_password=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${var.api_config.password}', safe=''))")
      
      token_response=$(curl --http1.1 -s -c "$cookie_jar" -X POST \
        "${var.api_config.base_url}/api/v1/login-check?userName=${var.api_config.username}&password=$encoded_password" \
        -H "Content-Type: application/json")
      
      if [[ -z "$token_response" ]]; then
        echo "❌ No response from authentication endpoint"
        exit 1
      fi
      
      # Extract token from response
      token=$(echo "$token_response" | grep -o '"token":"[^"]*"' | cut -d'"' -f4 || echo "")
      
      if [[ -z "$token" ]]; then
        echo "❌ Failed to get authentication token"
        echo "Response: $token_response"
        exit 1
      fi
      echo "✅ Authentication successful"
      
      # Step 2: Apply configuration using authenticated session
      echo "Applying project configuration..."
      
      # Add verbose output to debug
      echo "Config to be sent:"
      echo "$config_json" | head -c 200
      echo "..."
      
      # Use separate temp files for verbose output and response
      temp_response=$(mktemp)
      temp_stderr=$(mktemp)
      trap "rm -f $temp_response $temp_stderr" EXIT
      
      # Run curl without verbose output mixing with response
      http_code=$(curl --http1.1 -s -b "$cookie_jar" -w "%%{http_code}" -X POST \
        "${var.api_config.base_url}/api/v1/watch-tower-setting?projectName=${var.project_name}&customerName=${var.api_config.username}" \
        -H "Content-Type: application/json" \
        -H "X-CSRF-TOKEN: $token" \
        -d "$config_json" \
        -o "$temp_response" 2>"$temp_stderr")
      
      # Read response body and status
      body=$(cat "$temp_response")
      status="$http_code"
      
      echo "Configuration Response Status: $status"
      echo "Configuration Response Body: $body"
      
      # Check if request was successful
      if [ "$status" -eq 200 ]; then
        echo "✅ Configuration applied successfully to project '${var.project_name}'!"
        if [[ -n "$body" ]]; then
          echo "$body" > "project-config-response-${var.project_name}.json"
        else
          echo '{"status":"success","message":"Configuration applied successfully"}' > "project-config-response-${var.project_name}.json"
        fi
      else
        echo "❌ Failed to apply configuration. HTTP Status: $status"
        echo "Response: $body"
        exit 1
      fi
      
      # Cleanup temp files
      rm -f "/tmp/project-config-check-${var.project_name}.json"
      rm -f "/tmp/project-config-status-${var.project_name}.txt"
    EOT
  }

  triggers = {
    config_hash  = sha256(local_file.config.content)
    project_name = var.project_name
    username     = var.api_config.username
  }
}