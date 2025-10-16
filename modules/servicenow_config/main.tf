# ServiceNow Configuration Module
# This module configures ServiceNow integration for InsightFinder

terraform {
  required_version = ">= 1.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Resolve system names to system IDs OR use provided system IDs directly
resource "null_resource" "resolve_system_names" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Preparing system IDs for ServiceNow configuration..."
      
      # Check if user provided system_ids directly (bypass resolution)
      if [ ${length(var.servicenow_config.system_ids)} -gt 0 ]; then
        echo "Using provided system IDs directly (bypassing system name resolution)"
        system_ids="${join(",", var.servicenow_config.system_ids)}"
        echo "System IDs: $system_ids"
        echo "$system_ids" > "/tmp/resolved-system-ids-${var.api_config.username}.txt"
        exit 0
      fi
      
      echo "Resolving system names to system IDs..."
      
      echo "Fetching systems list from API..."
      
      # Check if cookie file exists from api_client module
      cookie_file="${var.api_config.cookie_file}"
      if [ ! -f "$cookie_file" ]; then
        echo "❌ Session cookie file not found: $cookie_file"
        echo "Make sure api_client module has been applied first"
        exit 1
      fi
      
      echo "Using cached session cookies from: $cookie_file"
      
      # Use the cached session cookies to call systems API
      systems_response=$(curl -s -w "\nHTTP_STATUS:%%{http_code}" \
        -X GET \
        -b "$cookie_file" \
        "${var.api_config.base_url}/api/v2/systemframework?customerName=${var.api_config.username}&needDetail=false")
      
      # Extract response body and status code
      body=$(echo "$systems_response" | sed '$d')
      status=$(echo "$systems_response" | tail -n1 | sed 's/.*HTTP_STATUS://')
      
      echo "Systems API Response Status: $status"
      echo "Raw API Response Body:"
      echo "$body"
      echo "Response Length: $(echo "$body" | wc -c) characters"
      
      if [ "$status" -ne 200 ]; then
        echo "❌ Failed to fetch systems list. HTTP Status: $status"
        echo "Response: $body"
        exit 1
      fi
      
      # Save systems response for processing
      echo "$body" > "/tmp/systems-${var.api_config.username}.json"
      
      # Check if the response is empty or contains no systems
      if [ $(echo "$body" | wc -c) -le 2 ]; then
        echo ""
        echo "⚠️  No systems found in your InsightFinder account."
        echo ""
        exit 1
      fi
      
      # Process system names and resolve to system IDs using dedicated Python script
      system_ids=""
      user_system_names='${jsonencode(var.servicenow_config.system_names)}'
      
      echo "User provided system names: $user_system_names"
      
      # Use dedicated Python script for robust JSON parsing
      script_path="${path.module}/../../scripts/process_systems.py"
      if [ ! -f "$script_path" ]; then
        echo "❌ Python script not found: $script_path"
        exit 1
      fi
      
      resolved_ids=$(python3 "$script_path" "/tmp/systems-${var.api_config.username}.json" "$user_system_names")
      
      if [ $? -eq 0 ]; then
        system_ids="$resolved_ids"
        echo "✅ Successfully resolved all system names to IDs: $system_ids"
      else
        echo "❌ Failed to resolve system names. Please check the available systems listed above."
        exit 1
      fi
      
      echo "Resolved system IDs: $system_ids"
      echo "$system_ids" > "/tmp/resolved-system-ids-${var.api_config.username}.txt"
    EOT
  }

  triggers = {
    username     = var.api_config.username
    auth_token   = var.api_config.auth_token
    system_names = join(",", var.servicenow_config.system_names)
    system_ids   = join(",", var.servicenow_config.system_ids)
  }
}

# Configure ServiceNow integration using resolved system IDs
resource "null_resource" "configure_servicenow" {
  depends_on = [null_resource.resolve_system_names]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Configuring ServiceNow integration..."
      
      # Read resolved system IDs
      if [ ! -f "/tmp/resolved-system-ids-${var.api_config.username}.txt" ]; then
        echo "❌ System ID resolution failed - no resolved system IDs file found"
        exit 1
      fi
      
      system_ids_str=$(cat "/tmp/resolved-system-ids-${var.api_config.username}.txt")
      echo "Using resolved system IDs: $system_ids_str"
      
      # Format system IDs as JSON array string
      system_ids_json="[\"$(echo "$system_ids_str" | sed 's/,/","/g')\"]"
      
      # Prepare options and content_option as JSON array strings for form data
      options_json='${jsonencode(var.servicenow_config.options)}'
      content_option_json='${jsonencode(var.servicenow_config.content_option)}'
      
      echo "System IDs JSON: $system_ids_json"
      echo "Options JSON: $options_json"
      echo "Content Options JSON: $content_option_json"
      
      # Use shared cookie-based authentication from api_client module
      echo "Using cached session cookies for ServiceNow configuration..."
      
      # Check if cookie file exists from api_client module
      cookie_file="${var.api_config.cookie_file}"
      if [ ! -f "$cookie_file" ]; then
        echo "❌ Session cookie file not found: $cookie_file"
        echo "Make sure api_client module has been applied first"
        exit 1
      fi
      
      echo "Using cached session cookies from: $cookie_file"
      
      # Make API call to configure ServiceNow using both shared session cookies and auth token
      response=$(curl -s -w "\nHTTP_STATUS:%%{http_code}" \
        -X POST \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "X-CSRF-TOKEN: ${var.api_config.auth_token}" \
        -b "$cookie_file" \
        -d "operation=ServiceNow" \
        -d "service_host=${var.servicenow_config.service_host}" \
        -d "proxy=${var.servicenow_config.proxy}" \
        -d "account=${var.servicenow_config.account}" \
        -d "password=${var.servicenow_config.password}" \
        -d "dampeningPeriod=${var.servicenow_config.dampening_period}" \
        -d "appId=${var.servicenow_config.app_id}" \
        -d "appKey=${var.servicenow_config.app_key}" \
        -d "customerName=${var.api_config.username}" \
        -d "systemIds=$system_ids_json" \
        -d "options=$options_json" \
        -d "contentOption=$content_option_json" \
        "${var.api_config.base_url}/api/v1/service-integration")
      
      # Extract response body and status code
      body=$(echo "$response" | sed '$d')
      status=$(echo "$response" | tail -n1 | sed 's/.*HTTP_STATUS://')
      
      echo "ServiceNow Configuration Response Status: $status"
      echo "ServiceNow Configuration Response Body: $body"
      
      # Check for authentication errors first
      if echo "$body" | grep -q "authentication\|unauthorized\|invalid.*credentials\|token.*expired"; then
        echo "❌ Authentication failed during ServiceNow configuration. Please verify your token."
        echo "Username: ${var.api_config.username}"
        echo "Base URL: ${var.api_config.base_url}"
        exit 1
      fi
      
      # Check if request was successful
      if [ "$status" -eq 200 ]; then
        # Check if response indicates success - looking for the specific success response format
        if echo "$body" | grep -q '"success":true'; then
          echo "✅ ServiceNow integration configured successfully!"
          echo "$body" > "servicenow-config-response.json"
        else
          echo "❌ ServiceNow configuration failed. API returned success=false"
          echo "Response: $body"
          exit 1
        fi
      elif [ "$status" -eq 401 ]; then
        echo "❌ Authentication failed. Please check your authentication token."
        echo "Username: ${var.api_config.username}"
        exit 1
      elif [ "$status" -eq 403 ]; then
        echo "❌ Access forbidden. Please check your permissions for ServiceNow configuration."
        exit 1
      else
        echo "❌ Failed to configure ServiceNow integration. HTTP Status: $status"
        echo "Response: $body"
        exit 1
      fi
      
      # Cleanup temp files
      rm -f "/tmp/systems-${var.api_config.username}.json"
      rm -f "/tmp/resolved-system-ids-${var.api_config.username}.txt"
    EOT
  }

  triggers = {
    service_host       = var.servicenow_config.service_host
    proxy             = var.servicenow_config.proxy
    account           = var.servicenow_config.account
    dampening_period  = var.servicenow_config.dampening_period
    app_id            = var.servicenow_config.app_id
    app_key           = var.servicenow_config.app_key
    username          = var.api_config.username
    auth_token        = var.api_config.auth_token
    system_names      = join(",", var.servicenow_config.system_names)
    options           = join(",", var.servicenow_config.options)
    content_option    = join(",", var.servicenow_config.content_option)
  }
}