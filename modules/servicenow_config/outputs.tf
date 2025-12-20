# ServiceNow Configuration Module Outputs

output "configuration_status" {
  description = "ServiceNow configuration status"
  value = {
    service_host       = var.servicenow_config.service_host
    account            = var.servicenow_config.account
    app_id             = var.servicenow_config.app_id
    system_names_count = length(var.servicenow_config.system_names)
    configured_at      = timestamp()
    status             = "configured"
  }
}

output "service_integration_summary" {
  description = "Summary of ServiceNow integration configuration"
  value = {
    integration_type      = "ServiceNow"
    system_names          = var.servicenow_config.system_names
    options_count         = length(var.servicenow_config.options)
    content_options_count = length(var.servicenow_config.content_option)
    dampening_period      = var.servicenow_config.dampening_period
  }
}

output "servicenow_config_drift" {
  description = "ServiceNow configuration drift detection information"
  value = {
    service_host       = local.servicenow_config_drift.service_host
    account            = local.servicenow_config_drift.account
    has_changes        = local.servicenow_config_drift.has_changes
    current_dampening  = local.servicenow_config_drift.current_dampening
    desired_dampening  = local.servicenow_config_drift.desired_dampening
    current_options    = local.servicenow_config_drift.current_options
    desired_options    = local.servicenow_config_drift.desired_options
    current_content    = local.servicenow_config_drift.current_content
    desired_content    = local.servicenow_config_drift.desired_content
    current_system_ids = local.servicenow_config_drift.current_system_ids
    desired_system_ids = local.servicenow_config_drift.desired_system_ids
    current_app_id     = local.servicenow_config_drift.current_app_id
    desired_app_id     = local.servicenow_config_drift.desired_app_id
    current_app_key    = local.servicenow_config_drift.current_app_key
    desired_app_key    = local.servicenow_config_drift.desired_app_key
  }
  sensitive = false
}