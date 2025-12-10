# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.1] - 2025-12-10

### Security
- **CRITICAL**: Masked `X-API-Key` header in all curl commands to prevent exposure in Terraform error logs
- API keys are no longer printed in error output when `terraform apply` fails
- Implemented curl config files (`-K` flag) for secure header passing in all modules

### Fixed
- Security vulnerability where sensitive API credentials appeared in Terraform logs during failures

## [2.0.0] - 2025-12-08

### Changed
- **BREAKING**: Removed password-based authentication in favor of API key authentication
- **BREAKING**: Removed `password` variable from root module and all submodules
- **BREAKING**: Updated all API endpoints to use new external API paths:
  - `/api/v1/watch-tower-setting` → `/api/external/v1/watch-tower-setting`
  - `/api/v2/systemframework` → `/api/external/v1/systemframework`
  - `/api/v1/service-integration` → `/api/external/v1/service-integration`
- Simplified authentication to use only `X-User-Name` and `X-API-Key` headers
- Removed cookie-based session management and CSRF token handling
- Removed authentication token caching system (no longer needed)

### Removed
- **BREAKING**: `password` variable from all modules
- **BREAKING**: `auth_token` from API client outputs and internal references
- **BREAKING**: `cookie_file` from API client outputs and internal references
- Login endpoint `/api/v1/login-check` usage
- Cookie caching and management logic
- Token retrieval and caching mechanism
- All password-related authentication infrastructure

### Migration Guide for v2.0.0
- **Remove `password` variable** from your `.tfvars` files and variable definitions
- **Keep only `username` and `license_key`** for authentication
- No other code changes required - all API request formats remain the same
- Authentication now uses simple header-based approach:
  ```hcl
  username    = "your-username"
  license_key = "your-license-key"
  # Remove: password = "..."  ← DELETE THIS LINE
  ```

### Benefits
- Simpler authentication mechanism (no session management)
- More secure (API key-based instead of password)
- Faster execution (no login/cookie steps)
- Better API stability with external endpoints

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
