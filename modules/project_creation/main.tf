# Project Creation Module
# This module creates a new InsightFinder project using the check-and-add-custom-project API

terraform {
  required_version = ">= 1.0"
  required_providers {
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
      echo "Checking if project '${var.project_name}' exists..."
      
      # Create form data for project check
      response=$(curl -s -w "\nHTTP_STATUS:%%{http_code}" \
        -X POST \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "operation=check" \
        -d "userName=${var.api_config.username}" \
        -d "licenseKey=${var.api_config.license_key}" \
        -d "projectName=${var.project_name}" \
        -d "systemName=${var.system_name}" \
        "${var.api_config.base_url}/api/v1/check-and-add-custom-project")
      
      # Extract response body and status code
      body=$(echo "$response" | sed '$d')
      status=$(echo "$response" | tail -n1 | sed 's/.*HTTP_STATUS://')
      
      echo "Project Check Response Status: $status"
      echo "Project Check Response Body: $body"
      
      # Check for credential errors first
      if echo "$body" | grep -q "does not match our records"; then
        echo "❌ Authentication failed during project check. Please verify your credentials."
        echo "Username: ${var.api_config.username}"
        echo "License Key: [REDACTED - first 8 chars: $(echo "${var.api_config.license_key}" | cut -c1-8)...]"
        exit 1
      fi
      
      # Save response for next step
      echo "$body" > "/tmp/project-check-${var.project_name}.json"
      echo "$status" > "/tmp/project-check-status-${var.project_name}.txt"
    EOT
  }

  triggers = {
    project_name = var.project_name
    system_name  = var.system_name
    username     = var.api_config.username
  }
}

# Create the project if it doesn't exist
resource "null_resource" "create_project" {
  depends_on = [null_resource.check_project_exists]
  
  provisioner "local-exec" {
    command = <<-EOT
      # Check if project already exists
      if [ -f "/tmp/project-check-${var.project_name}.json" ]; then
        check_response=$(cat "/tmp/project-check-${var.project_name}.json")
        check_status=$(cat "/tmp/project-check-status-${var.project_name}.txt")
        
        if [ "$check_status" = "200" ]; then
          # Parse JSON to check if project exists (basic check)
          if echo "$check_response" | grep -q '"isProjectExist":true'; then
            echo "✅ Project '${var.project_name}' already exists. Skipping creation."
            exit 0
          fi
        fi
      fi
      
      echo "Creating project '${var.project_name}'..."
      
      # Create form data for project creation
      response=$(curl -s -w "\nHTTP_STATUS:%%{http_code}" \
        -X POST \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "operation=create" \
        -d "userName=${var.api_config.username}" \
        -d "licenseKey=${var.api_config.license_key}" \
        -d "projectName=${var.project_name}" \
        -d "systemName=${var.system_name}" \
        -d "dataType=${var.data_type}" \
        -d "instanceType=${var.instance_type}" \
        -d "projectCloudType=${var.project_cloud_type}" \
        -d "insightAgentType=${var.insight_agent_type}" \
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
      rm -f "/tmp/project-check-${var.project_name}.json"
      rm -f "/tmp/project-check-status-${var.project_name}.txt"
    EOT
  }

  triggers = {
    project_name         = var.project_name
    system_name          = var.system_name
    data_type           = var.data_type
    instance_type       = var.instance_type
    project_cloud_type  = var.project_cloud_type
    insight_agent_type  = var.insight_agent_type
    username            = var.api_config.username
  }
}
