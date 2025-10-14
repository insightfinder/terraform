# InsightFinder Terraform Module

A production-ready Terraform module for managing InsightFinder projects using Infrastructure as Code (IaC) principles.

## ✨ Features

- **Project Creation**: Create new InsightFinder projects with proper configuration
- **Project Configuration**: Configure existing projects with advanced monitoring settings
- **Flexible Deployment**: Support for different environments (dev/staging/production)
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

Pick the example that matches your needs:

- **Create a new project only**: `examples/create-project.tfvars`
- **Configure existing project**: `examples/configure-project.tfvars`  
- **Create and configure together**: `examples/create-and-configure.tfvars`

### 3. Deploy

```bash
# Copy and modify the appropriate example
cp examples/create-project.tfvars my-config.tfvars
# Edit my-config.tfvars with your settings

# Deploy
terraform init
terraform plan -var-file="my-config.tfvars"
terraform apply -var-file="my-config.tfvars"
```

## 📋 Configuration Examples

### 1. Create New Project Only

Use this when you only want to create a project without configuring it:

```hcl
# examples/create-project.tfvars
base_url = "https://stg.insightfinder.com"
username = "your_username"

enable_project_creation      = true
enable_project_configuration = false

create_project = {
  project_name         = "my-new-metrics-project"
  system_name          = "production-monitoring-cluster"
  data_type           = "Metric"
  instance_type       = "OnPremise"
  project_cloud_type  = "OnPremise"
  insight_agent_type  = "collectd"
}
```

### 2. Configure Existing Project

Use this when you want to configure an existing project:

```hcl
# examples/configure-project.tfvars
base_url = "https://stg.insightfinder.com"
username = "your_username"

enable_project_creation      = false
enable_project_configuration = true

project_config = {
  project_name       = "existing-project-name"
  projectDisplayName = "Production Monitoring"
  cValue             = 3
  pValue             = 0.95
  retentionTime      = 90
  samplingInterval   = 600
  
  # Advanced settings
  dynamicBaselineDetectionFlag = true
  enableUBLDetect = true
  
  # Instance grouping
  instanceGroupingData = [
    {
      instanceName        = "web-server-01"
      instanceDisplayName = "Web Server 1"
      appName            = "frontend"
      ignoreFlag         = false
    }
  ]
}
```

### 3. Create and Configure Together

Use this for end-to-end project setup:

```hcl
# examples/create-and-configure.tfvars
base_url = "https://stg.insightfinder.com"
username = "your_username"

enable_project_creation      = true
enable_project_configuration = true
create_if_not_exists         = true

create_project = {
  project_name         = "web-app-monitoring"
  system_name          = "production-web-cluster"
  data_type           = "Metric"
  insight_agent_type  = "collectd"
}

project_config = {
  project_name       = "web-app-monitoring"  # Same as above
  projectDisplayName = "Web Application Monitoring"
  # ... configuration settings
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

### Control Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `enable_project_creation` | bool | `false` | Enable project creation |
| `enable_project_configuration` | bool | `true` | Enable project configuration |
| `create_if_not_exists` | bool | `false` | Create project if it doesn't exist during configuration |

### Configuration Objects

| Variable | Type | Description |
|----------|------|-------------|
| `create_project` | object | Project creation settings (required if `enable_project_creation = true`) |
| `project_config` | object | Project configuration settings (required if `enable_project_configuration = true`) |

## 📁 Examples

The module includes three focused example files:

- **`examples/create-project.tfvars`**: Create new project only
- **`examples/configure-project.tfvars`**: Configure existing project only  
- **`examples/create-and-configure.tfvars`**: Create and configure in one step
- **`external-usage-example/`**: Complete external module usage example

## 🏗️ Module Structure

```
terraform/
├── main.tf                           # Main module orchestration
├── variables.tf                      # Variable definitions
├── outputs.tf                        # Module outputs
├── examples/
│   ├── create-project.tfvars         # Create project only
│   ├── configure-project.tfvars      # Configure existing project
│   └── create-and-configure.tfvars   # Create and configure together
├── modules/
│   ├── api_client/                   # Shared authentication
│   ├── project_creation/             # Project creation logic
│   └── project_config/               # Project configuration
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

### .gitignore

```gitignore
# Terraform
*.tfstate
*.tfstate.*
*.tfvars
.terraform/
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

- Ensure the project name exists if `enable_project_creation = false`
- Set `create_if_not_exists = true` to create missing projects automatically
- Use staging URL for testing: `base_url = "https://stg.insightfinder.com"`

### Rate Limiting

- The API has rate limiting protection
- Add delays between successive deployments during testing
- Use proper credentials to avoid authentication failures

### Configuration Not Applied

- Ensure `enable_project_configuration = true`
- Check that the project name matches exactly
- Verify the API returns HTTP 200 status

## 🔗 API Integration

- **Authentication**: `POST /api/v1/login-check`
- **Project Creation**: `POST /api/v1/check-and-add-custom-project`
- **Project Configuration**: `POST /api/v1/watch-tower-setting`
- **Error Handling**: Robust validation and meaningful error messages

## 📄 License

See [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test your changes with the provided examples
4. Ensure all three example use cases work
5. Submit a pull request

## 📞 Support

For issues and questions:
- Create an issue in this repository
- Contact InsightFinder support
- Check the example files for usage patterns
- Review the troubleshooting section