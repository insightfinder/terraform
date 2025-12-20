# Project Configuration Module Outputs

output "project_name" {
  description = "The name of the configured project"
  value       = var.project_name
}

output "api_config_json" {
  description = "The JSON configuration sent to the API"
  value       = local.api_config_json
}

output "final_config" {
  description = "The final merged configuration applied to the project"
  value       = local.final_config
}

output "current_config" {
  description = "The current configuration from the API"
  value       = local.current_config_normalized
}

output "config_diff" {
  description = "Differences between desired and current configuration"
  value       = local.config_diff
}

output "changed_fields" {
  description = "Fields that have changed between desired and current configuration"
  value       = local.changed_fields
}

output "configuration_applied" {
  description = "Configuration application status"
  value = {
    project_name       = var.project_name
    config_state_hash  = local.config_state_hash
    has_changes        = length(local.changed_fields) > 0
    changed_field_count = length(local.changed_fields)
    applied_at         = timestamp()
  }
  depends_on = [null_resource.apply_config]
}
output "log_label_drift" {
  description = "Drift detection for log label settings"
  value = {
    total_settings            = length(local.log_label_settings)
    settings_needing_update   = length(local.log_labels_needing_update)
    has_changes               = length(local.log_labels_needing_update) > 0
    changes_by_label_type     = local.log_label_changes
  }
}
