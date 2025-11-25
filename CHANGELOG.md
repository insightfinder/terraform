# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2025-11-25

### Changed
- Add ServiceNow integration support


### Added
- **ServiceNow Integration**: New `servicenow_config` module for configuring ServiceNow integration
- **Token Caching System**: Automatic authentication token caching to avoid re-authentication across modules
- New example files: `servicenow-config.tfvars` and `project-with-servicenow.tfvars`
- Enhanced `api_client` module with token management and caching functionality
- Support for combining project configuration with ServiceNow integration in single deployment

### Changed
- **BREAKING**: Consolidated project creation and configuration into a single `project_config` block
- **BREAKING**: Removed dedicated `project_creation` module and `create_project` variable
- **BREAKING**: Removed `enable_project_creation` and `enable_project_configuration` control flags
- Enhanced API client module to handle authentication and token caching
- Simplified module structure with unified project management
- Updated all example files to use new consolidated structure
- Updated external usage examples to reflect simplified interface

### Removed
- `modules/project_creation/` directory and files
- `create_project` variable
- `enable_project_creation` variable
- `enable_project_configuration` variable

### Migration Guide
- Replace `create_project` block with `project_config.project_creation_config`
- Set `project_config.create_if_not_exists = true` instead of `enable_project_creation = true`
- Remove `enable_project_creation` and `enable_project_configuration` variables
- Consolidate all project settings into single `project_config` block
- Add `servicenow_config` block for ServiceNow integration (optional)

## [1.0.0] - 2025-10-10

### Added
- Initial release of the Terraform InsightFinder module
- Support for all InsightFinder project configuration options
- Comprehensive variable validation and type checking
- Direct API integration with InsightFinder
- Email configuration support
- Webhook configuration support
- Instance grouping capabilities
- Metric threshold management
- Advanced anomaly detection settings
- Prediction and incident management
- Root cause analysis configuration
- Cost and alert management
- System integration settings
- Sensitive data handling
- Example configurations (basic and advanced)
- Comprehensive documentation

### Features
- **Project Management**: Complete project lifecycle management
- **Configuration Validation**: Type-safe configuration with validation
- **API Integration**: Direct REST API calls to InsightFinder
- **Security**: Sensitive data marked and handled properly
- **Flexibility**: Supports all configuration options from IFClient-Python
- **Examples**: Ready-to-use examples for common scenarios
- **Documentation**: Comprehensive README and usage examples

### Supported Configuration Areas
- Basic project settings (cValue, pValue, retention times)
- Advanced detection settings (baseline detection, UBL, predictions)
- Email notifications (alerts, predictions, RCA)
- Webhook integrations
- Instance and metric configurations
- Threshold and alert management
- Cost calculations
- System integrations

## [0.1.0] - 2025-10-10

### Added
- Initial development version
- Basic module structure
- Core functionality implementation
