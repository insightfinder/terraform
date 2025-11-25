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