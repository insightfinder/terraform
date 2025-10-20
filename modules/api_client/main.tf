# API Client Module
# This module provides session-based API client configuration and token management for InsightFinder
# Authentication happens fresh each terraform session without file persistence

terraform {
  required_version = ">= 1.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
}

# Create a unique cache key based on base_url and username for this session
locals {
  cache_key = md5("${var.base_url}:${var.username}")
  cookie_cache_file = "/tmp/insightfinder-cookies-${local.cache_key}.txt"
}

# Authenticate and cache token/cookies for this terraform session
resource "null_resource" "authenticate_and_cache" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "Authenticating with InsightFinder API (fresh session)..."
      echo "Base URL: ${var.base_url}"
      echo "Username: ${var.username}"
      
      # Clean up any existing cache files from previous sessions
      rm -f "${local.cookie_cache_file}"
      
      # URL encode password
      encoded_password=$(python3 -c "import urllib.parse; print(urllib.parse.quote('${var.password}', safe=''))")
      
      # Authenticate and get both token and session cookies
      echo "Getting authentication token and session cookies..."
      token_response=$(curl --http1.1 -s -c "${local.cookie_cache_file}" -X POST \
        "${var.base_url}/api/v1/login-check?userName=${var.username}&password=$encoded_password" \
        -H "Content-Type: application/json")
      
      if [[ -z "$token_response" ]]; then
        echo "❌ No response from authentication endpoint"
        rm -f "${local.cookie_cache_file}"
        exit 1
      fi
      
      echo "Authentication Response: $token_response"
      
      # Extract token from response
      token=$(echo "$token_response" | grep -o '"token":"[^"]*"' | cut -d'"' -f4 || echo "")
      
      if [[ -z "$token" ]]; then
        echo "❌ Failed to get authentication token"
        echo "Response: $token_response"
        rm -f "${local.cookie_cache_file}"
        exit 1
      fi
      
      # Verify cookies were created
      if [ ! -f "${local.cookie_cache_file}" ] || [ ! -s "${local.cookie_cache_file}" ]; then
        echo "❌ Failed to get session cookies"
        rm -f "${local.cookie_cache_file}"
        exit 1
      fi
      
      echo "✅ Authentication successful for this terraform session"
      echo "Token: $token"
      echo "Cookies cached at: ${local.cookie_cache_file}"
      
      # Store token in a way that can be read by outputs without file dependency
      echo "$token" > "/tmp/token-${local.cache_key}.txt"
      
      # Log cached cookies for debugging (without sensitive values)
      if [ -f "${local.cookie_cache_file}" ]; then
        echo "Cached cookies count: $(wc -l < "${local.cookie_cache_file}")"
      fi
    EOT
  }

  triggers = {
    base_url = var.base_url
    username = var.username
    # Force re-authentication if password changes
    password_hash = md5(var.password)
    # Force fresh authentication every time by including timestamp
    timestamp = timestamp()
  }
}