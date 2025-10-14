# Project Configuration Module Outputs

output "project_name" {
  description = "The name of the configured project"
  value       = var.project_name
}

output "config_file_path" {
  description = "Path to the generated configuration file"
  value       = local_file.config.filename
}

output "final_config" {
  description = "The final merged configuration applied to the project"
  value       = local.final_config
}

output "configuration_applied" {
  description = "Configuration application status"
  value = {
    project_name = var.project_name
    config_file  = local_file.config.filename
    applied_at   = timestamp()
  }
  depends_on = [null_resource.apply_config]
}