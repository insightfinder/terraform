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

output "auth_config" {
  description = "Complete authentication configuration"
  value = {
    base_url    = var.base_url
    username    = var.username
    password    = var.password
    license_key = var.license_key
  }
  sensitive = true
}