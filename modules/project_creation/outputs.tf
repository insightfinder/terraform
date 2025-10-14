# Project Creation Module Outputs

output "project_name" {
  description = "Name of the created project"
  value       = var.project_name
}

output "system_name" {
  description = "System name for the created project"
  value       = var.system_name
}

output "api_response_file" {
  description = "Path to the API response file (if creation was successful)"
  value       = "project-creation-response-${var.project_name}.json"
}

output "creation_summary" {
  description = "Summary of project creation operation"
  value = {
    project_name        = var.project_name
    system_name         = var.system_name
    data_type          = var.data_type
    instance_type      = var.instance_type
    project_cloud_type = var.project_cloud_type
    insight_agent_type = var.insight_agent_type
    created_by_terraform = true
  }
}