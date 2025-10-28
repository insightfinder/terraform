# JWT Configuration Module
# This module configures JWT token settings for InsightFinder systems

terraform {
  required_version = ">= 1.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Resolve system name to system ID using the same strategy as servicenow module
resource "null_resource" "resolve_system_name" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Resolving system name '${var.jwt_config.system_name}' to system ID for JWT configuration..."
      
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
      echo "$body" > "/tmp/jwt-systems-${var.api_config.username}.json"
      
      # Check if the response is empty or contains no systems
      if [ $(echo "$body" | wc -c) -le 2 ]; then
        echo ""
        echo "⚠️  No systems found in your InsightFinder account."
        echo ""
        exit 1
      fi
      
      # Process system name and resolve to system ID using dedicated Python script
      system_id=""
      user_system_names='["${var.jwt_config.system_name}"]'
      
      echo "User provided system name: ${var.jwt_config.system_name}"
      
      # Use dedicated Python script for robust JSON parsing
      script_path="${path.module}/../../scripts/process_systems.py"
      if [ ! -f "$script_path" ]; then
        echo "❌ Python script not found: $script_path"
        exit 1
      fi
      
      resolved_ids=$(python3 "$script_path" "/tmp/jwt-systems-${var.api_config.username}.json" "$user_system_names")
      
      if [ $? -eq 0 ]; then
        system_id="$resolved_ids"
        echo "✅ Successfully resolved system name '${var.jwt_config.system_name}' to ID: $system_id"
      else
        echo "❌ Failed to resolve system name '${var.jwt_config.system_name}'. Please check the available systems listed above."
        exit 1
      fi
      
      echo "Resolved system ID: $system_id"
      echo "$system_id" > "/tmp/jwt-resolved-system-id-${var.api_config.username}.txt"
      
      # Cleanup
      rm -f "/tmp/jwt-systems-${var.api_config.username}.json"
    EOT
  }

  triggers = {
    username    = var.api_config.username
    auth_token  = var.api_config.auth_token
    system_name = var.jwt_config.system_name
  }
}

# Configure JWT token using resolved system ID
resource "null_resource" "configure_jwt" {
  depends_on = [null_resource.resolve_system_name]
  
  provisioner "local-exec" {
    command = <<-EOT
      echo "Configuring JWT token for system '${var.jwt_config.system_name}'..."
      
      # Validate JWT secret length (additional runtime validation)
      jwt_secret="${var.jwt_config.jwt_secret}"
      if [ ${length(var.jwt_config.jwt_secret)} -lt 6 ]; then
        echo "❌ JWT secret must be at least 6 characters long"
        exit 1
      fi
      
      echo "✅ JWT secret validation passed (length: ${length(var.jwt_config.jwt_secret)} characters)"
      
      # Create outputs directory if it doesn't exist
      mkdir -p outputs
      
      # Read resolved system ID
      if [ ! -f "/tmp/jwt-resolved-system-id-${var.api_config.username}.txt" ]; then
        echo "❌ System ID resolution failed - no resolved system ID file found"
        exit 1
      fi
      
      system_id=$(cat "/tmp/jwt-resolved-system-id-${var.api_config.username}.txt")
      echo "Using resolved system ID: $system_id"
      
      # Prepare systemKey JSON according to the API specification
      # Format: {"userName":"username","systemName":"systemId","environmentName":"All"}
      system_key="{\"userName\":\"${var.api_config.username}\",\"systemName\":\"$system_id\",\"environmentName\":\"All\"}"
      
      # Prepare systemFrameworkSetting JSON according to the API specification  
      # Format: {"systemLevelJWTSecret":"jwt_secret","jwtType":1}
      system_framework_setting="{\"systemLevelJWTSecret\":\"$jwt_secret\",\"jwtType\":1}"
      
      echo "System Key JSON: $system_key"
      echo "System Framework Setting JSON: $system_framework_setting"
      
      # URL encode the JSON strings for form data
      encoded_system_key=$(printf '%s' "$system_key" | python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.stdin.read().strip()))")
      encoded_system_framework_setting=$(printf '%s' "$system_framework_setting" | python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.stdin.read().strip()))")
      
      echo "Encoded System Key: $encoded_system_key"
      echo "Encoded System Framework Setting: $encoded_system_framework_setting"
      
      # Use shared cookie-based authentication from api_client module
      echo "Using cached session cookies for JWT configuration..."
      
      # Check if cookie file exists from api_client module
      cookie_file="${var.api_config.cookie_file}"
      if [ ! -f "$cookie_file" ]; then
        echo "❌ Session cookie file not found: $cookie_file"
        echo "Make sure api_client module has been applied first"
        exit 1
      fi
      
      echo "Using cached session cookies from: $cookie_file"
      
      # Make API call to configure JWT using both shared session cookies and auth token
      response=$(curl -s -w "\nHTTP_STATUS:%%{http_code}" \
        -X POST \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -H "X-CSRF-TOKEN: ${var.api_config.auth_token}" \
        -b "$cookie_file" \
        -d "operation=systemFrameworkSetting" \
        -d "systemKey=$encoded_system_key" \
        -d "systemFrameworkSetting=$encoded_system_framework_setting" \
        "${var.api_config.base_url}/api/v2/systemframework?tzOffset=-14400000")
      
      # Extract response body and status code
      body=$(echo "$response" | sed '$d')
      status=$(echo "$response" | tail -n1 | sed 's/.*HTTP_STATUS://')
      
      echo "JWT Configuration Response Status: $status"
      echo "JWT Configuration Response Body: $body"
      
      # Check for authentication errors first
      if echo "$body" | grep -q "authentication\|unauthorized\|invalid.*credentials\|token.*expired"; then
        echo "❌ Authentication failed during JWT configuration. Please verify your token."
        echo "Username: ${var.api_config.username}"
        echo "Base URL: ${var.api_config.base_url}"
        exit 1
      fi
      
      # Check if request was successful
      if [ "$status" -eq 200 ]; then
        # Check if response indicates success - looking for the specific success response format
        if echo "$body" | grep -q '"success":true' || echo "$body" | grep -q '"status":"success"' || [[ "$body" == *"success"* ]]; then
          echo "✅ JWT configuration applied successfully for system '${var.jwt_config.system_name}'!"
          echo "$body" > "outputs/jwt-config-response-${var.jwt_config.system_name}.json"
        else
          echo "❌ JWT configuration failed. API returned unexpected response"
          echo "Response: $body"
          exit 1
        fi
      elif [ "$status" -eq 401 ]; then
        echo "❌ Authentication failed. Please check your authentication token."
        echo "Username: ${var.api_config.username}"
        exit 1
      elif [ "$status" -eq 403 ]; then
        echo "❌ Access forbidden. Please check your permissions for JWT configuration."
        exit 1
      else
        echo "❌ Failed to configure JWT. HTTP Status: $status"
        echo "Response: $body"
        exit 1
      fi
      
      # Cleanup temp files
      rm -f "/tmp/jwt-resolved-system-id-${var.api_config.username}.txt"
    EOT
  }

  triggers = {
    system_name   = var.jwt_config.system_name
    jwt_secret    = sha256(var.jwt_config.jwt_secret) # Use hash to avoid exposing secret in triggers
    username      = var.api_config.username
    auth_token    = var.api_config.auth_token
  }
}