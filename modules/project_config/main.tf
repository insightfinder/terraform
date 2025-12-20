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
    http = {
      source  = "hashicorp/http"
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
      elif [ "$status" -eq 400 ]; then
        # Check if this is a "project already exists" error
        if echo "$body" | grep -qi "already existed"; then
          echo "✅ Project '${var.project_name}' already exists (HTTP 400)."
          echo "$body" > "outputs/project-creation-response-${var.project_name}.json"
          exit 0
        else
          echo "❌ Failed to create project. HTTP Status: $status"
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
    # Trigger recreation if project is deleted from UI
    project_exists = local.project_exists
  }
}

# Create final configuration by merging individual variables
locals {
  # Build config from all explicit variables (only non-null values)
  individual_fields = {
    for k, v in {
      UBLRetentionTime                     = var.UBLRetentionTime
      alertAverageTime                     = var.alertAverageTime
      alertHourlyCost                      = var.alertHourlyCost
      anomalyDetectionMode                 = var.anomalyDetectionMode
      anomalySamplingInterval              = var.anomalySamplingInterval
      avgPerIncidentDowntimeCost           = var.avgPerIncidentDowntimeCost
      baseValueSetting                     = var.baseValueSetting
      cValue                               = var.cValue
      causalMinDelay                       = var.causalMinDelay
      causalPredictionSetting              = var.causalPredictionSetting
      cdfSetting                           = var.cdfSetting
      coldEventThreshold                   = var.coldEventThreshold
      coldNumberLimit                      = var.coldNumberLimit
      collectAllRareEventsFlag             = var.collectAllRareEventsFlag
      dailyModelSpan                       = var.dailyModelSpan
      disableLogCompressEvent              = var.disableLogCompressEvent
      disableModelKeywordStatsCollection   = var.disableModelKeywordStatsCollection
      emailSetting                         = var.emailSetting
      enableAnomalyScoreEscalation         = var.enableAnomalyScoreEscalation
      enableHotEvent                       = var.enableHotEvent
      enableNewAlertEmail                  = var.enableNewAlertEmail
      enableStreamDetection                = var.enableStreamDetection
      escalationAnomalyScoreThreshold      = var.escalationAnomalyScoreThreshold
      featureOutlierSensitivity            = var.featureOutlierSensitivity
      featureOutlierThreshold              = var.featureOutlierThreshold
      hotEventCalmDownPeriod               = var.hotEventCalmDownPeriod
      hotEventDetectionMode                = var.hotEventDetectionMode
      hotEventThreshold                    = var.hotEventThreshold
      hotNumberLimit                       = var.hotNumberLimit
      ignoreAnomalyScoreThreshold          = var.ignoreAnomalyScoreThreshold
      ignoreInstanceForKB                  = var.ignoreInstanceForKB
      incidentConsolidationInterval        = var.incidentConsolidationInterval
      incidentCountThreshold               = var.incidentCountThreshold
      incidentDurationThreshold            = var.incidentDurationThreshold
      incidentPredictionEventLimit         = var.incidentPredictionEventLimit
      incidentPredictionWindow             = var.incidentPredictionWindow
      incidentRelationSearchWindow         = var.incidentRelationSearchWindow
      instanceConvertFlag                  = var.instanceConvertFlag
      instanceDownEnable                   = var.instanceDownEnable
      instanceGroupingUpdate               = var.instanceGroupingUpdate
      isEdgeBrain                          = var.isEdgeBrain
      isGroupingByInstance                 = var.isGroupingByInstance
      isTracePrompt                        = var.isTracePrompt
      keywordFeatureNumber                 = var.keywordFeatureNumber
      keywordSetting                       = var.keywordSetting
      largeProject                         = var.largeProject
      llmEvaluationSetting                 = var.llmEvaluationSetting
      logAnomalyEventBaseScore             = var.logAnomalyEventBaseScore
      logDetectionMinCount                 = var.logDetectionMinCount
      logDetectionSize                     = var.logDetectionSize
      logPatternLimitLevel                 = var.logPatternLimitLevel
      logToLogSettingList                  = var.logToLogSettingList
      maxLogModelSize                      = var.maxLogModelSize
      maxWebHookRequestSize                = var.maxWebHookRequestSize
      maximumDetectionWaitTime             = var.maximumDetectionWaitTime
      maximumRootCauseResultSize           = var.maximumRootCauseResultSize
      maximumThreads                       = var.maximumThreads
      minIncidentPredictionWindow          = var.minIncidentPredictionWindow
      minValidModelSpan                    = var.minValidModelSpan
      modelKeywordSetting                  = var.modelKeywordSetting
      multiHopSearchLevel                  = var.multiHopSearchLevel
      multiHopSearchLimit                  = var.multiHopSearchLimit
      multiLineFlag                        = var.multiLineFlag
      newAlertFlag                         = var.newAlertFlag
      newPatternNumberLimit                = var.newPatternNumberLimit
      newPatternRange                      = var.newPatternRange
      nlpFlag                              = var.nlpFlag
      normalEventCausalFlag                = var.normalEventCausalFlag
      pValue                               = var.pValue
      predictionCountThreshold             = var.predictionCountThreshold
      predictionProbabilityThreshold       = var.predictionProbabilityThreshold
      predictionRuleActiveCondition        = var.predictionRuleActiveCondition
      predictionRuleActiveThreshold        = var.predictionRuleActiveThreshold
      predictionRuleFalsePositiveThreshold = var.predictionRuleFalsePositiveThreshold
      predictionRuleInactiveThreshold      = var.predictionRuleInactiveThreshold
      prettyJsonConvertorFlag              = var.prettyJsonConvertorFlag
      projectDisplayName                   = var.projectDisplayName
      projectModelFlag                     = var.projectModelFlag
      projectTimeZone                      = var.projectTimeZone
      proxy                                = var.proxy
      rareAnomalyType                      = var.rareAnomalyType
      rareEventAlertThresholds             = var.rareEventAlertThresholds
      rareNumberLimit                      = var.rareNumberLimit
      retentionTime                        = var.retentionTime
      rootCauseCountThreshold              = var.rootCauseCountThreshold
      rootCauseLogMessageSearchRange       = var.rootCauseLogMessageSearchRange
      rootCauseProbabilityThreshold        = var.rootCauseProbabilityThreshold
      rootCauseRankSetting                 = var.rootCauseRankSetting
      samplingInterval                     = var.samplingInterval
      sharedUsernames                      = var.sharedUsernames
      showInstanceDown                     = var.showInstanceDown
      similaritySensitivity                = var.similaritySensitivity
      trainingFilter                       = var.trainingFilter
      webhookAlertDampening                = var.webhookAlertDampening
      webhookBlackListSetStr               = var.webhookBlackListSetStr
      webhookCriticalKeywordSetStr         = var.webhookCriticalKeywordSetStr
      webhookHeaderList                    = var.webhookHeaderList
      webhookTypeSetStr                    = var.webhookTypeSetStr
      webhookUrl                           = var.webhookUrl
      whitelistNumberLimit                 = var.whitelistNumberLimit
      zoneNameKey                          = var.zoneNameKey
      # Legacy metric project variables
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

  # Final configuration is just the individual fields
  final_config = local.individual_fields

  # Extract logLabelSettingCreate for separate processing
  log_label_settings = var.logLabelSettingCreate != null ? var.logLabelSettingCreate : []

  # List of Terraform-specific fields that should not be sent to API
  terraform_only_fields = toset(["create_if_not_exists", "project_creation_config", "project_name", "logLabelSettingCreate"])

  # Remove logLabelSettingCreate and Terraform-specific fields from the main config
  config_without_log_labels = {
    for k, v in local.final_config : k => v
    if !contains(local.terraform_only_fields, k)
  }

  # Use config without log labels for the main API call
  api_config = local.config_without_log_labels

  # JSON encode the config once for reuse
  api_config_json = jsonencode(local.api_config)

  # Use a combination of project name and plantimestamp to create a cache key
  # This ensures the URL changes on each plan, forcing fresh data
  cache_key = md5("${var.project_name}-${plantimestamp()}")
}

# Fetch current project configuration from API for drift detection
data "http" "current_project_config" {
  url = "${var.api_config.base_url}/api/external/v1/watch-tower-setting?projectList=${urlencode(jsonencode([{ projectName = var.project_name, customerName = var.api_config.username }]))}&_v=${local.cache_key}"

  request_headers = {
    X-User-Name = var.api_config.username
    X-API-Key   = var.api_config.license_key
  }

  lifecycle {
    postcondition {
      condition     = contains([200, 204], self.status_code)
      error_message = "Failed to fetch project configuration: HTTP ${self.status_code}"
    }
  }
}

# Fetch current log label settings from API for drift detection
data "http" "current_log_labels" {
  url = "${var.api_config.base_url}/api/external/v1/projectkeywords?projectName=${var.project_name}&_v=${local.cache_key}"

  request_headers = {
    X-User-Name = var.api_config.username
    X-API-Key   = var.api_config.license_key
  }

  lifecycle {
    postcondition {
      condition     = contains([200, 204], self.status_code)
      error_message = "Failed to fetch log label settings: HTTP ${self.status_code}"
    }
  }
}

# Resource to display project existence status in plan output
resource "null_resource" "project_existence_status" {
  triggers = {
    project_name            = var.project_name
    project_exists          = local.project_exists
    http_status_code        = data.http.current_project_config.status_code
    create_if_not_exists    = var.create_if_not_exists
    will_create_if_missing  = !local.project_exists && var.create_if_not_exists
    drift_detection_enabled = true
  }

  lifecycle {
    # This resource is just for visibility, don't actually run anything
    create_before_destroy = true
  }
}

# Parse the API response to extract current configuration
locals {
  # Check if project exists (HTTP 200 = exists, HTTP 204 = doesn't exist)
  project_exists = data.http.current_project_config.status_code == 200

  # Parse the response which has structure: {"settingList": {"ProjectName": "{\"CLASSNAME\":\"...\",\"DATA\":{...}}"}}
  # If project doesn't exist (204), response_body will be empty
  api_response = local.project_exists ? jsondecode(data.http.current_project_config.response_body) : {}

  # Extract the project-specific settings (it's a JSON string that needs another decode)
  project_settings_raw = try(local.api_response.settingList[var.project_name], "{}")

  # Parse the nested JSON to get the actual DATA object
  project_settings_parsed = try(jsondecode(local.project_settings_raw), {})

  # Extract the DATA field which contains the actual configuration
  # If project doesn't exist, this will be empty {}
  current_config = try(local.project_settings_parsed.DATA, {})

  # Create a normalized version of current config (only fields we manage)
  # For nested objects, only compare keys that exist in our desired config
  # Special handling for emailSetting: API returns strings, keep them as strings
  current_config_normalized = {
    for k, v in local.current_config : k => (
      # If it's an object and we have a desired config for it, normalize it
      can(local.api_config[k]) && can(keys(local.api_config[k])) ? {
        for nested_k in keys(local.api_config[k]) : nested_k => try(v[nested_k], null)
      } : v
    )
    if contains(keys(local.api_config), k)
  }

  # Helper function to check if two values are effectively equal
  # This handles nested objects, arrays, and null/empty comparisons
  values_equal = { for k in distinct(concat(keys(local.api_config), keys(local.current_config_normalized))) :
    k => (
      # Both null or both missing = equal
      try(local.api_config[k], null) == null && try(local.current_config_normalized[k], null) == null ? true :
      # Direct equality check (handles primitives and nested structures)
      jsonencode(try(local.api_config[k], null)) == jsonencode(try(local.current_config_normalized[k], null))
    )
  }

  # Create a map showing which fields differ between desired and current
  config_diff = {
    for k in distinct(concat(keys(local.api_config), keys(local.current_config_normalized))) :
    k => {
      desired = try(local.api_config[k], null)
      current = try(local.current_config_normalized[k], null)
      changed = !local.values_equal[k]
    }
  }

  # Extract only changed fields for trigger
  changed_fields = {
    for k, v in local.config_diff : k => v
    if v.changed
  }

  # Create a deterministic hash of only the fields that matter
  config_state_hash = sha256(jsonencode({
    desired = local.api_config
    current = local.current_config_normalized
  }))

  # Parse log label API response
  # Response structure: {"keywords": {"whitelist": [...], "trainingWhitelist": [...], "patternNameLabels": [...], ...}}
  # If project doesn't exist (204), response_body will be empty
  log_labels_response    = try(jsondecode(data.http.current_log_labels.response_body), {})
  current_log_labels_raw = try(local.log_labels_response.keywords, {})

  # Map of Terraform labelType to API response field names
  label_type_mapping = {
    "whitelist"           = "whitelist"
    "trainingWhitelist"   = "trainingWhitelist"
    "blacklist"           = "trainingBlacklistLabels"
    "featurelist"         = "featurelist"
    "incidentlist"        = "incidentlist"
    "triagelist"          = "triagelist"
    "anomalyFeature"      = "anomalyFeatureLabels"
    "dataFilter"          = "dataFilterLabels"
    "patternName"         = "patternNameLabels"
    "instanceName"        = "instanceNameLabels"
    "dataQualityCheck"    = "dataQualityCheckLabels"
    "extractionBlacklist" = "extractionBlacklist"
  }

  # Prepare data for each log label setting
  log_label_desired = {
    for idx, label_setting in local.log_label_settings : idx => try(jsondecode(label_setting.logLabelString), [])
  }

  log_label_api_fields = {
    for idx, label_setting in local.log_label_settings : idx => try(local.label_type_mapping[label_setting.labelType], label_setting.labelType)
  }

  log_label_current = {
    for idx, api_field in local.log_label_api_fields : idx => try(local.current_log_labels_raw[api_field], [])
  }

  # For each desired log label setting, compare with current API state
  log_label_changes = {
    for idx, label_setting in local.log_label_settings : idx => {
      label_type = label_setting.labelType
      api_field  = local.log_label_api_fields[idx]
      desired    = local.log_label_desired[idx]
      current    = local.log_label_current[idx]
      # Sort both arrays by their JSON representation for consistent comparison
      has_changes = jsonencode(sort([for item in local.log_label_desired[idx] : jsonencode(item)])) != jsonencode(sort([for item in local.log_label_current[idx] : jsonencode(item)]))
    }
  }

  # Determine which log label settings actually need to be applied
  log_labels_needing_update = {
    for idx, change in local.log_label_changes : idx => change
    if change.has_changes
  }
}

# Apply configuration to InsightFinder API
resource "null_resource" "apply_config" {
  depends_on = [
    null_resource.check_project_exists,
    null_resource.create_project_if_needed
  ]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Applying configuration to project '${var.project_name}'..."
      
      # Create outputs directory if it doesn't exist (for response files)
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
      
      # Use configuration from Terraform variable (no file reading needed)
      config_json='${local.api_config_json}'
      
      # Validate JSON
      if ! echo "$config_json" | python3 -c "import json,sys; json.load(sys.stdin)" > /dev/null 2>&1; then
        echo "❌ Invalid JSON in config"
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
        if [ -n "$body" ]; then
          echo "$body" > "outputs/project-config-response-${var.project_name}.json"
        else
          echo '{"status":"success","message":"Configuration applied successfully"}' > "outputs/project-config-response-${var.project_name}.json"
        fi
      elif [ "$status" -eq 204 ]; then
        echo "⚠️  Project '${var.project_name}' doesn't exist yet (HTTP 204)."
        if [ "${var.create_if_not_exists}" = "true" ]; then
          echo "📋 This is expected on first run when project is being created. Configuration will be applied on next run."
          echo "💡 Tip: Run 'terraform apply' again to apply the configuration after project creation."
          exit 0
        else
          echo "❌ Project doesn't exist and create_if_not_exists is false"
          exit 1
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
    # Show project name
    project_name = var.project_name

    # Trigger recreation when project is recreated
    project_creation_id = var.create_if_not_exists ? try(null_resource.create_project_if_needed[0].id, null) : null

    # Include full drift information for all managed fields (similar to log label settings)
    # This shows current vs desired for each field with has_changes indicator
    config_drift_details = jsonencode(local.config_diff)

    # Hash of ONLY the desired configuration - this stays constant unless tfvars change
    desired_config_hash = sha256(jsonencode(local.api_config))

    # Hash of the CURRENT configuration from API - this changes when someone modifies in UI
    current_config_hash = sha256(jsonencode(local.current_config_normalized))
  }
}
# Apply logLabelSettingCreate items individually after main configuration
resource "null_resource" "apply_log_label_settings" {
  count = length(local.log_label_settings)

  depends_on = [null_resource.apply_config]

  provisioner "local-exec" {
    command = <<-EOT
      echo "Applying logLabelSettingCreate item ${count.index + 1} of ${length(local.log_label_settings)} to project '${var.project_name}'..."
      
      # Create outputs directory if it doesn't exist
      mkdir -p outputs
      
      # Build JSON for this specific log label setting
      config_json=$(cat <<'INNER_EOF'
{
  "logLabelSettingCreate": ${jsonencode(local.log_label_settings[count.index])}
}
INNER_EOF
)
      
      echo "Log Label Config to be sent:"
      echo "$config_json"
      
      # Create temporary files
      temp_response=$(mktemp)
      temp_stderr=$(mktemp)
      temp_curl_config=$(mktemp)
      trap "rm -f $temp_response $temp_stderr $temp_curl_config" EXIT

      # Create curl config file to hide sensitive headers from logs
      cat > "$temp_curl_config" <<CURL_EOF
header = "Content-Type: application/json"
header = "X-User-Name: $IF_USERNAME"
header = "X-API-Key: $IF_API_KEY"
CURL_EOF

      # Run curl with header-based authentication
      http_code=$(curl --http1.1 -s -w "%%{http_code}" -X POST \
        "${var.api_config.base_url}/api/external/v1/watch-tower-setting?projectName=${var.project_name}&customerName=$IF_USERNAME" \
        -K "$temp_curl_config" \
        -d "$config_json" \
        -o "$temp_response" 2>"$temp_stderr")
      
      # Read response body and status
      body=$(cat "$temp_response")
      status="$http_code"
      
      echo "Log Label Setting Response Status: $status"
      echo "Log Label Setting Response Body: $body"
      
      # Check if request was successful
      if [ "$status" -eq 200 ]; then
        echo "✅ Log label setting ${count.index + 1} applied successfully!"
        if [ -n "$body" ]; then
          echo "$body" > "outputs/log-label-${count.index + 1}-response-${var.project_name}.json"
        fi
      elif [ "$status" -eq 204 ]; then
        echo "⚠️  Project '${var.project_name}' doesn't exist yet (HTTP 204)."
        echo "📋 Log label settings will be applied after project is created. Run 'terraform apply' again."
        exit 0
      else
        echo "❌ Failed to apply log label setting ${count.index + 1}. HTTP Status: $status"
        echo "Response: $body"
        exit 1
      fi
    EOT

    environment = {
      IF_USERNAME = var.api_config.username
      IF_API_KEY  = var.api_config.license_key
    }
  }

  triggers = {
    # Show project name
    project_name = var.project_name

    # Trigger recreation when project is recreated
    project_creation_id = var.create_if_not_exists ? try(null_resource.create_project_if_needed[0].id, null) : null

    # Include drift detection information for this log label setting
    log_label_change = jsonencode(try(local.log_label_changes[count.index], {
      label_type  = local.log_label_settings[count.index].labelType
      has_changes = true # If no drift data, assume it needs to be applied
      desired     = jsondecode(local.log_label_settings[count.index].logLabelString)
      current     = []
    }))

    # Hash of this specific log label setting for comparison
    log_label_hash = sha256(jsonencode(local.log_label_settings[count.index]))
  }
}
