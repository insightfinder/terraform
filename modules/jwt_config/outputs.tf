# JWT Configuration Module Outputs

output "system_id" {
  description = "The resolved system ID for the configured system"
  value       = try(trim(replace(file("/tmp/jwt-resolved-system-id-${var.api_config.username}.txt"), "\n", ""), " "), "")
  depends_on  = [null_resource.resolve_system_name]
}

output "configuration_status" {
  description = "Status of the JWT configuration operation"
  value = {
    success            = fileexists("outputs/jwt-config-response-${var.jwt_config.system_name}.json")
    system_name        = var.jwt_config.system_name
    resolved_system_id = try(trim(replace(file("/tmp/jwt-resolved-system-id-${var.api_config.username}.txt"), "\n", ""), " "), "unknown")
    response_file      = fileexists("outputs/jwt-config-response-${var.jwt_config.system_name}.json") ? "outputs/jwt-config-response-${var.jwt_config.system_name}.json" : null
  }
  depends_on = [null_resource.configure_jwt]
}

output "jwt_secret_length" {
  description = "Length of the JWT secret (for validation purposes)"
  value       = length(var.jwt_config.jwt_secret)
  sensitive   = false
}