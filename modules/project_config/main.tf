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

# Validate that project_creation_config is provided when create_if_not_exists is true
locals {
  validate_creation_config = (
    var.create_if_not_exists == false ||
    (var.project_creation_config != null && var.project_creation_config.system_name != null && var.project_creation_config.system_name != "")
  )
  validation_error = !local.validate_creation_config ? "ERROR: project_creation_config with system_name is required when create_if_not_exists is true." : ""
}

# This will fail at plan time if validation fails
resource "null_resource" "validation" {
  count = local.validate_creation_config ? 0 : 1

  provisioner "local-exec" {
    command = "echo '${local.validation_error}' && exit 1"
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
        -d "userName=$IF_USERNAME" \
        -d "licenseKey=$IF_API_KEY" \
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

    environment = {
      IF_USERNAME = var.api_config.username
      IF_API_KEY  = var.api_config.license_key
    }
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
      
      # Create outputs directory if it doesn't exist
      mkdir -p outputs
      
      # Build curl command with conditional projectCreationType parameter
      curl_cmd="curl -s -w \"\nHTTP_STATUS:%%{http_code}\" \
        -X POST \
        -H \"Content-Type: application/x-www-form-urlencoded\" \
        -d \"operation=create\" \
        -d \"userName=\$IF_USERNAME\" \
        -d \"licenseKey=\$IF_API_KEY\" \
        -d \"projectName=${var.project_name}\" \
        -d \"systemName=${var.project_creation_config.system_name}\" \
        -d \"dataType=${var.project_creation_config.data_type}\" \
        -d \"instanceType=${var.project_creation_config.instance_type}\" \
        -d \"projectCloudType=${var.project_creation_config.project_cloud_type}\" \
        -d \"insightAgentType=${var.project_creation_config.insight_agent_type}\""
      
      # Add projectCreationType only if it's provided
      %{if var.project_creation_config.project_creation_type != null && var.project_creation_config.project_creation_type != ""}
      curl_cmd="$curl_cmd -d \"projectCreationType=${var.project_creation_config.project_creation_type}\""
      %{endif}
      
      curl_cmd="$curl_cmd \"${var.api_config.base_url}/api/v1/check-and-add-custom-project\""
      
      # Execute the curl command
      response=$(eval $curl_cmd)
      
      # Extract response body and status code
      body=$(echo "$response" | sed '$d')
      status=$(echo "$response" | tail -n1 | sed 's/.*HTTP_STATUS://')
      
      echo "Project Creation Response Status: $status"
      echo "Project Creation Response Body: $body"
      
      # Check for credential errors first
      if echo "$body" | grep -q "does not match our records"; then
        echo "❌ Authentication failed. Please check your username and license key."
        echo "Username: $IF_USERNAME"
        echo "License Key: [REDACTED - first 8 chars: $(echo "$IF_API_KEY" | cut -c1-8)...]"
        exit 1
      fi
      
      # Check if request was successful
      if [ "$status" -eq 200 ]; then
        # Check if response indicates success
        if echo "$body" | grep -q '"success":true' || echo "$body" | grep -q '"isSuccess":true'; then
          echo "✅ Project '${var.project_name}' created successfully!"
          echo "$body" > "outputs/project-creation-response-${var.project_name}.json"
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
          -d "userName=$IF_USERNAME" \
          -d "licenseKey=$IF_API_KEY" \
          -d "projectName=${var.project_name}" \
          "${var.api_config.base_url}/api/v1/check-and-add-custom-project")
        
        check_body=$(echo "$check_response" | sed '$d')
        check_status=$(echo "$check_response" | tail -n1 | sed 's/.*HTTP_STATUS://')
        
        if [ "$check_status" -eq 200 ] && echo "$check_body" | grep -q '"isProjectExist":true'; then
          echo "✅ Project '${var.project_name}' already exists (confirmed after 500 error)."
          echo "$check_body" > "outputs/project-creation-response-${var.project_name}.json"
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

    environment = {
      IF_USERNAME = var.api_config.username
      IF_API_KEY  = var.api_config.license_key
    }
  }

  triggers = {
    project_name          = var.project_name
    system_name           = var.project_creation_config.system_name
    data_type             = var.project_creation_config.data_type
    instance_type         = var.project_creation_config.instance_type
    project_cloud_type    = var.project_creation_config.project_cloud_type
    insight_agent_type    = var.project_creation_config.insight_agent_type
    project_creation_type = var.project_creation_config.project_creation_type
    username              = var.api_config.username
  }
}

# Create final configuration by merging individual variables with project_config
locals {
  # Build config from individual variables (only non-null values, matching OpenAPI spec)
  individual_fields = {
    for k, v in {
      cValue                                 = var.cValue
      pValue                                 = var.pValue
      showInstanceDown                       = var.showInstanceDown
      retentionTime                          = var.retentionTime
      UBLRetentionTime                       = var.UBLRetentionTime
      projectDisplayName                     = var.projectDisplayName
      samplingInterval                       = var.samplingInterval
      instanceGroupingData                   = var.instanceGroupingData
      highRatioCValue                        = var.highRatioCValue
      dynamicBaselineDetectionFlag           = var.dynamicBaselineDetectionFlag
      positiveBaselineViolationFactor        = var.positiveBaselineViolationFactor
      negativeBaselineViolationFactor        = var.negativeBaselineViolationFactor
      enablePeriodAnomalyFilter              = var.enablePeriodAnomalyFilter
      enableUBLDetect                        = var.enableUBLDetect
      enableCumulativeDetect                 = var.enableCumulativeDetect
      instanceDownThreshold                  = var.instanceDownThreshold
      instanceDownReportNumber               = var.instanceDownReportNumber
      instanceDownEnable                     = var.instanceDownEnable
      modelSpan                              = var.modelSpan
      enableMetricDataPrediction             = var.enableMetricDataPrediction
      enableBaselineDetectionDoubleVerify    = var.enableBaselineDetectionDoubleVerify
      enableFillGap                          = var.enableFillGap
      patternIdGenerationRule                = var.patternIdGenerationRule
      anomalyGapToleranceCount               = var.anomalyGapToleranceCount
      filterByAnomalyInBaselineGeneration    = var.filterByAnomalyInBaselineGeneration
      baselineDuration                       = var.baselineDuration
      componentMetricSettingOverallModelList = var.componentMetricSettingOverallModelList
      enableBaselineNearConstance            = var.enableBaselineNearConstance
      computeDifference                      = var.computeDifference
    } : k => v if v != null
  }

  # Merge individual fields with project_config (project_config takes precedence)
  final_config = merge(local.individual_fields, var.project_config)

  # Extract only the config fields for API call (remove metadata)
  api_config = try(var.project_config.config, {})
}

# Create outputs directory
resource "null_resource" "create_outputs_dir" {
  provisioner "local-exec" {
    command = "mkdir -p outputs"
  }
}

# Generate configuration JSON file for debugging/validation (all fields)
resource "local_file" "config_json" {
  depends_on = [null_resource.create_outputs_dir]
  content    = jsonencode(local.final_config)
  filename   = "outputs/generated-config.json"
}

# Generate API-specific configuration JSON file (only config fields)
resource "local_file" "api_config" {
  depends_on = [null_resource.create_outputs_dir]
  content    = jsonencode(local.api_config)
  filename   = "outputs/api-config.json"
}

# Apply configuration to InsightFinder API
resource "null_resource" "apply_config" {
  depends_on = [
    local_file.config_json,
    local_file.api_config,
    null_resource.check_project_exists,
    null_resource.create_project_if_needed
  ]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Applying configuration to project '${var.project_name}'..."
      
      # Create outputs directory if it doesn't exist
      mkdir -p outputs
      
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
      config_json=$(cat "${local_file.config_json.filename}")
      
      # Validate JSON
      if ! echo "$config_json" | python3 -c "import json,sys; json.load(sys.stdin)" > /dev/null 2>&1; then
        echo "❌ Invalid JSON in config file"
        exit 1
      fi
      
      # Step 2: Apply configuration
      echo "Applying project configuration..."
      
      # Add verbose output to debug
      echo "Config to be sent:"
      echo "$config_json" | head -c 200
      echo "..."
      
      # Use separate temp files for verbose output and response
      temp_response=$(mktemp)
      temp_stderr=$(mktemp)
      temp_curl_config=$(mktemp)
      trap "rm -f $temp_response $temp_stderr $temp_curl_config" EXIT

      # Create curl config file to hide sensitive headers from logs
      # Use environment variables to avoid exposing credentials in error output
      cat > "$temp_curl_config" <<EOF
header = "Content-Type: application/json"
header = "X-User-Name: $IF_USERNAME"
header = "X-API-Key: $IF_API_KEY"
EOF

      # Run curl with header-based authentication (API key hidden from logs)
      http_code=$(curl --http1.1 -s -w "%%{http_code}" -X POST \
        "${var.api_config.base_url}/api/external/v1/watch-tower-setting?projectName=${var.project_name}&customerName=$IF_USERNAME" \
        -K "$temp_curl_config" \
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
          echo "$body" > "outputs/project-config-response-${var.project_name}.json"
        else
          echo '{"status":"success","message":"Configuration applied successfully"}' > "outputs/project-config-response-${var.project_name}.json"
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

    environment = {
      IF_USERNAME = var.api_config.username
      IF_API_KEY  = var.api_config.license_key
    }
  }

  triggers = {
    config_hash  = sha256(local_file.config_json.content)
    project_name = var.project_name
    username     = var.api_config.username
    license_key  = var.api_config.license_key
  }
}