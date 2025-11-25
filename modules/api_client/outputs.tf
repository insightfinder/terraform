# API Client Module Outputs
output "base_url" {
  description = "The InsightFinder API base URL"
  value       = var.base_url
}

output "username" {
  description = "The InsightFinder username"
  value       = var.username
}

output "password" {
  description = "The InsightFinder password"
  value       = var.password
  sensitive   = true
}

output "license_key" {
  description = "The InsightFinder license key"
  value       = var.license_key
  sensitive   = true
}

# Use external data to read token without file dependency
data "external" "auth_token" {
  depends_on = [null_resource.authenticate_and_cache]
  program = ["bash", "-c", <<-EOT
    cache_key="${md5("${var.base_url}:${var.username}")}"
    token_file="/tmp/token-$cache_key.txt"
    
    if [ -f "$token_file" ]; then
      token=$(cat "$token_file")
      echo "{\"token\":\"$token\"}"
    else
      echo "{\"token\":\"\"}"
    fi
  EOT
  ]
}

output "auth_token" {
  description = "The authentication token for this session"
  value       = data.external.auth_token.result.token
  sensitive   = true
  depends_on  = [null_resource.authenticate_and_cache]
}

output "auth_config" {
  description = "Complete authentication configuration with token and cookies for this session"
  value = {
    base_url    = var.base_url
    username    = var.username
    password    = var.password
    license_key = var.license_key
    auth_token  = data.external.auth_token.result.token
    cookie_file = "/tmp/insightfinder-cookies-${md5("${var.base_url}:${var.username}")}.txt"
  }
  sensitive  = true
  depends_on = [null_resource.authenticate_and_cache]
}

output "cookie_file" {
  description = "Path to the session cookies file for this terraform session"
  value       = "/tmp/insightfinder-cookies-${md5("${var.base_url}:${var.username}")}.txt"
  depends_on  = [null_resource.authenticate_and_cache]
}