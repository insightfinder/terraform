# InsightFinder Terraform Module

[![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)](./VERSION)
[![Changelog](https://img.shields.io/badge/changelog-CHANGELOG.md-orange.svg)](./CHANGELOG.md)

A production-ready Terraform module for managing InsightFinder projects using Infrastructure as Code (IaC) principles.

## ✨ Features

- **Unified Project Management**: Create and configure projects with a single, simplified interface
- **Smart Project Creation**: Create projects automatically when they don't exist using `create_if_not_exists`
- **ServiceNow Integration**: Configure ServiceNow integration with automatic system name resolution
- **JWT Token Configuration**: Configure JWT token settings for system-level authentication
- **Flexible Configuration**: Configure projects with advanced monitoring settings
- **Environment Support**: Support for different environments (dev/staging/production)
- **Type Safety**: Terraform validates configuration before deployment
- **Error Handling**: Robust error checking and validation
- **Future-Proof**: Supports any OpenAPI fields without code changes

## 🚀 Quick Start

### 1. Set Credentials

```bash
export TF_VAR_password="your_insightfinder_password"
export TF_VAR_license_key="your_insightfinder_license_key"
```

### 2. Choose Your Use Case

- **Complete project + ServiceNow setup**: `examples/example.tfvars`
- **JWT token configuration**: Configure JWT secrets for system authentication

### 3. Deploy

```bash
# Copy and modify the appropriate example
cp examples/example.tfvars my-config.tfvars
# Edit my-config.tfvars with your settings

# Deploy
terraform init
terraform plan -var-file="my-config.tfvars"
terraform apply -var-file="my-config.tfvars"
```

## 📋 Configuration Examples

### 1. Create New Project Only

Use this when you only want to create a project without additional configuration:

```hcl
# examples/example.tfvars
base_url = "https://stg.insightfinder.com"
username = "your_username"

project_config = {
  project_name         = "my-new-metrics-project"
  create_if_not_exists = true
  
  project_creation_config = {
    system_name         = "production-monitoring-cluster"
    data_type          = "Metric"
    instance_type      = "OnPremise"
    project_cloud_type = "OnPremise"
    insight_agent_type = "collectd"
  }
}
```

### 2. Configure Existing Project

Use this when you want to configure an existing project:

```hcl
# examples/example.tfvars
base_url = "https://stg.insightfinder.com"
username = "your_username"

project_config = {
  project_name         = "existing-project-name"
  create_if_not_exists = false  # Don't create - expect it to exist
  
  projectDisplayName = "Production Monitoring"
  cValue             = 3
  pValue             = 0.95
  retentionTime      = 90
  samplingInterval   = 600
  
  # Advanced settings
  dynamicBaselineDetectionFlag = true
  enableUBLDetect = true
  
  # Instance grouping
  instanceGroupingUpdate = {
    instanceDataList = [
      {
        instanceName        = "web-server-01"
        instanceDisplayName = "Web Server 1"
        appName            = "frontend"
        component          = "web-service"
        ignoreFlag         = false
      }
    ]
  }
}
```

### 3. Create and Configure Together

Use this for end-to-end project setup:

```hcl
# examples/example.tfvars
base_url = "https://stg.insightfinder.com"
username = "your_username"

project_config = {
  project_name         = "web-app-monitoring"
  create_if_not_exists = true
  
  # Project creation settings
  project_creation_config = {
    system_name         = "production-web-cluster"
    data_type          = "Metric"
    instance_type      = "OnPremise"
    project_cloud_type = "OnPremise"
    insight_agent_type = "collectd"
  }
  
  # Project configuration
  projectDisplayName = "Web Application Monitoring"
  cValue             = 3
  pValue             = 0.95
  retentionTime      = 90
  samplingInterval   = 600
  
  # Advanced settings
  dynamicBaselineDetectionFlag = true
  enableUBLDetect = true
  enableCumulativeDetect = false
  modelSpan = 0
  
  # Metric-specific configuration
  componentMetricSettingOverallModelList = [
    {
      metricName                        = "cpu_usage"
      escalateIncidentAll              = true
      thresholdAlertLowerBound         = 15
      thresholdAlertUpperBound         = 85
      thresholdNoAlertLowerBound       = 30
      thresholdNoAlertUpperBound       = 70
    }
  ]
}
```

### 4. ServiceNow Integration

Use this to configure ServiceNow integration for incident management:

```hcl
base_url = "https://app.insightfinder.com"
username = "your_username"

servicenow_config = {
  service_host      = "your-instance.service-now.com"
  account          = "servicenow_username"
  password         = "servicenow_password"
  dampening_period = 7200000
  client_id        = "your_client_id"
  client_secret    = "your_client_secret"
  system_names     = ["Production System", "Development System"]
  options          = ["Root Cause"]  # Options: "Detected Incident", "Detected Incident with RCA", "Predicted Incident", "Root Cause"
  content_option   = ["SUMMARY"]   # Options: "SUMMARY", "RECOMMENDATION"
}
```

> **🎯 System Name Resolution**: The module automatically resolves human-readable system names to system IDs by querying the InsightFinder API. This improves usability by allowing you to specify descriptive names instead of cryptic system IDs.

### 5. JWT Token Configuration

Use this to configure JWT token settings for system-level authentication:

```hcl
base_url = "https://app.insightfinder.com"
username = "your_username"

jwt_config = {
  jwt_secret  = "your-jwt-secret-key"  # Minimum 6 characters required
  system_name = "Production System"    # System name to configure JWT for
}
```

> **🔐 JWT Security**: The JWT secret must be at least 6 characters long. The module automatically resolves system names to system IDs and configures the JWT token using the InsightFinder API endpoint `/api/v2/systemframework`.

### 6. Complete Project + ServiceNow Setup

Use this for end-to-end setup with ServiceNow integration:

```hcl
base_url = "https://app.insightfinder.com"
username = "your_username"

project_config = {
  project_name         = "production-monitoring"
  create_if_not_exists = true
  
  project_creation_config = {
    system_name = "production-system"
    data_type   = "Metric"
    # ... other settings
  }
  
  # Project configuration
  projectDisplayName = "Production Monitoring with ServiceNow"
  # ... other project settings
}

servicenow_config = {
  service_host     = "production.service-now.com"
  account         = "prod_servicenow_user"
  password        = "servicenow_password"
  # ... other ServiceNow settings
}
```

### 7. Multi-Service Configuration

Use this to configure multiple services together:

```hcl
base_url = "https://app.insightfinder.com"
username = "your_username"

# Project configuration
project_config = {
  project_name         = "production-monitoring"
  create_if_not_exists = true
  projectDisplayName   = "Production System Monitoring"
  # ... other project settings
}

# ServiceNow integration
servicenow_config = {
  service_host = "production.service-now.com"
  account     = "servicenow_user"
  password    = "servicenow_password"
  system_names = ["Production System"]
  # ... other ServiceNow settings
}

# JWT token configuration
jwt_config = {
  jwt_secret  = "secure-jwt-secret-key-123"
  system_name = "Production System"
}
```

## 🔧 Variables Reference

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `username` | string | InsightFinder username |
| `password` | string | InsightFinder password (via `TF_VAR_password`) |
| `license_key` | string | InsightFinder license key (via `TF_VAR_license_key`) |

### Connection Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `base_url` | string | `"https://app.insightfinder.com"` | InsightFinder API URL |

### Configuration Objects

| Variable | Type | Description |
|----------|------|-------------|
| `project_config` | object | Project configuration settings with optional creation parameters |
| `servicenow_config` | object | ServiceNow integration configuration (optional) |
| `jwt_config` | object | JWT token configuration (optional) |

#### Project Config Object Structure

The `project_config` object supports:

- **project_name** (string, required): Project name
- **create_if_not_exists** (bool, optional): Create project if it doesn't exist
- **project_creation_config** (object, required if create_if_not_exists=true): Creation parameters
- **All OpenAPI project configuration fields**: Any field from the InsightFinder API spec

#### ServiceNow Config Object Structure

The `servicenow_config` object supports:

- **service_host** (string, required): ServiceNow instance hostname
- **account** (string, required): ServiceNow username
- **password** (string, required): ServiceNow password
- **client_id** (string, optional): ServiceNow application client ID
- **client_secret** (string, optional): ServiceNow application client secret
- **system_names** (list(string), required): List of human-readable system names (automatically resolved to system IDs)
- **proxy** (string, optional): Proxy server (default: "")
- **dampening_period** (number, required): Dampening period in seconds
- **options** (list(string), optional): Integration options (default: [])
- **content_option** (list(string), optional): Content options (default: [])

#### JWT Config Object Structure

The `jwt_config` object supports:

- **jwt_secret** (string, required): JWT secret key (minimum 6 characters)
- **system_name** (string, required): Human-readable system name (automatically resolved to system ID)

## 🏗️ Module Structure

```
terraform/
├── main.tf                           # Main module orchestration
├── variables.tf                      # Variable definitions  
├── examples/
│   └── example.tfvars                # Complete project + ServiceNow
├── modules/
│   ├── api_client/                   # Shared authentication & token caching
│   ├── project_config/               # Unified project management
│   ├── servicenow_config/            # ServiceNow integration
│   └── jwt_config/                   # JWT token configuration
└── external-usage-example/           # External module usage demo
    ├── main.tf                       # Module integration
    ├── variables.tf                  # Custom variables
    ├── dev.tfvars                    # Development config
    └── prod.tfvars                   # Production config
```

## 🔒 Security Best Practices

### Environment Variables

```bash
# Set sensitive values via environment
export TF_VAR_password="your-secure-password"
export TF_VAR_license_key="your-secure-license-key"
```

## 🚨 Troubleshooting

### Authentication Errors

```bash
# Ensure credentials are set correctly
export TF_VAR_password="your_actual_password"
export TF_VAR_license_key="your_actual_license_key"

# Verify they're set
echo $TF_VAR_password
echo $TF_VAR_license_key
```

### Project Not Found Errors

- Ensure the project name exists if `create_if_not_exists = false`
- Set `create_if_not_exists = true` to create missing projects automatically
- Use staging URL for testing: `base_url = "https://stg.insightfinder.com"`

### Rate Limiting

- The API has rate limiting protection
- Add delays between successive deployments during testing
- Use proper credentials to avoid authentication failures

### Configuration Not Applied

- Ensure `project_config` is properly defined with required parameters
- Check that the project name matches exactly
- Verify the API returns HTTP 200 status

### JWT Configuration Issues

- Ensure JWT secret is at least 6 characters long
- Verify the system name exists in your InsightFinder account
- Check that the system name resolves to a valid system ID
- Ensure proper authentication credentials are provided

## 🔗 API Integration

- **Authentication**: `POST /api/v1/login-check`
- **Project Creation**: `POST /api/v1/check-and-add-custom-project`
- **Project Configuration**: `POST /api/v1/watch-tower-setting`
- **ServiceNow Integration**: `POST /api/v1/service-integration`
- **JWT Configuration**: `POST /api/v2/systemframework`
- **System Resolution**: `GET /api/v2/systemframework`
- **Error Handling**: Robust validation and meaningful error messages

## 📄 License

See [LICENSE](LICENSE) file for details.