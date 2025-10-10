# InsightFinder Terraform Module

This Terraform module allows you to manage InsightFinder configurations using Infrastructure as Code principles.

**Repository**: https://github.com/insightfinder/terraform.git

## Features

- **Infrastructure as Code**: Manage configurations using Terraform's declarative approach
- **State Management**: Track and version your configuration changes
- **Validation**: Built-in validation for configuration parameters
- **API Integration**: Direct integration with InsightFinder API for configuration deployment

## Usage

### Basic Example

```hcl
module "my_project" {
  source = "git::https://github.com/insightfinder/terraform.git?ref=v1.0.0"

  insightfinder_base_url = "https://app.insightfinder.com"
  insightfinder_username = var.username
  insightfinder_password = var.password

  project_config = {
    project            = "my-project"
    userName          = var.username
    projectDisplayName = "My Production Project"
    cValue            = 3
    pValue            = 0.95
    showInstanceDown  = false
    retentionTime     = 90

    instances = [
      {
        instanceName        = "web-server-1"
        instanceDisplayName = "Web Server 1"
        containerName       = "web-container"
        appName            = "web-app"
        ignoreFlag         = false
      }
    ]

    metrics = [
      {
        metricName                     = "CPU_Usage"
        escalateIncidentAll            = true
        thresholdAlertLowerBound       = 10
        thresholdAlertUpperBound       = 90
        thresholdNoAlertLowerBound     = 30
        thresholdNoAlertUpperBound     = 70
      }
    ]
  }
}
```

### Advanced Example with Email Settings

```hcl
module "production_monitoring" {
  source = "git::https://github.com/insightfinder/terraform.git?ref=v1.0.0"

  insightfinder_base_url = "https://app.insightfinder.com"
  insightfinder_username = var.username
  insightfinder_password = var.password

  project_config = {
    project                = "production-monitoring"
    userName              = var.username
    projectDisplayName    = "Production System Monitoring"
    
    # Advanced settings
    dynamicBaselineDetectionFlag = true
    enableUBLDetect             = true
    enableKPIPrediction         = true
    
    # Email configuration
    emailSetting = {
      enableAlertsEmail                  = true
      enableIncidentPredictionEmailAlert = true
      enableRootCauseEmailAlert          = true
      alertEmail                        = "alerts@company.com"
      predictionEmail                   = "predictions@company.com"
      rootCauseEmail                    = "rca@company.com"
      emailDampeningPeriod              = 3600000
    }

    # Webhook configuration
    webhookUrl = "https://company.com/webhook"
    webhookHeaderList = ["Authorization: Bearer ${var.webhook_token}"]
    
    instances = [
      {
        instanceName        = "prod-web-1"
        instanceDisplayName = "Production Web Server 1"
        containerName       = "nginx"
        appName            = "web-frontend"
        ignoreFlag         = false
      },
      {
        instanceName        = "prod-db-1"
        instanceDisplayName = "Production Database 1"
        containerName       = "postgres"
        appName            = "database"
        ignoreFlag         = false
      }
    ]

    metrics = [
      {
        metricName                     = "response_time"
        escalateIncidentAll            = true
        thresholdAlertLowerBound       = 100
        thresholdAlertUpperBound       = 5000
        thresholdNoAlertLowerBound     = 200
        thresholdNoAlertUpperBound     = 3000
      },
      {
        metricName                     = "error_rate"
        escalateIncidentAll            = true
        thresholdAlertLowerBound       = 0.1
        thresholdAlertUpperBound       = 10.0
        thresholdNoAlertLowerBound     = 0.5
        thresholdNoAlertUpperBound     = 5.0
      }
    ]
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| local | ~> 2.0 |
| null | ~> 3.0 |
| time | ~> 0.9 |

## Providers

| Name | Version |
|------|---------|
| local | ~> 2.0 |
| null | ~> 3.0 |
| time | ~> 0.9 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| insightfinder_base_url | Base URL for InsightFinder deployment | `string` | `"https://app.insightfinder.com"` | no |
| insightfinder_username | InsightFinder username | `string` | n/a | yes |
| insightfinder_password | InsightFinder password | `string` | n/a | yes |
| project_config | Complete InsightFinder project configuration | `object({...})` | n/a | yes |

### Project Configuration Object

The `project_config` object supports the following attributes:

#### Required Fields
- `project` (string): Project identifier
- `userName` (string): Project owner username

#### Basic Settings
- `projectDisplayName` (string): Human-readable project name
- `cValue` (number): C-value for anomaly detection (default: 1)
- `pValue` (number): P-value threshold (default: 0.95)
- `showInstanceDown` (bool): Show instance down alerts (default: false)
- `retentionTime` (number): Data retention time in days (default: 90)
- `UBLRetentionTime` (number): UBL retention time in days (default: 8)

#### Advanced Detection Settings
- `highRatioCValue` (number): High ratio C-value (default: 3)
- `dynamicBaselineDetectionFlag` (bool): Enable dynamic baseline detection
- `enableUBLDetect` (bool): Enable UBL detection
- `enableKPIPrediction` (bool): Enable KPI prediction
- `enableMetricDataPrediction` (bool): Enable metric data prediction

#### Email Settings Object
```hcl
emailSetting = {
  enableAlertsEmail                  = bool
  enableIncidentPredictionEmailAlert = bool
  enableIncidentDetectionEmailAlert  = bool
  enableRootCauseEmailAlert          = bool
  alertEmail                        = string
  predictionEmail                   = string
  rootCauseEmail                    = string
  emailDampeningPeriod              = number
  alertsEmailDampeningPeriod        = number
  predictionEmailDampeningPeriod    = number
}
```

#### Instance Configuration Array
```hcl
instances = [
  {
    instanceName        = string
    instanceDisplayName = string (optional)
    containerName       = string (optional)
    appName            = string (optional)
    metricInstanceName = string (optional)
    ignoreFlag         = bool (default: false)
  }
]
```

#### Metric Configuration Array
```hcl
metrics = [
  {
    metricName                     = string
    escalateIncidentAll            = bool (default: true)
    thresholdAlertLowerBound       = number (default: 15)
    thresholdAlertUpperBound       = number (default: 105)
    thresholdAlertUpperBoundNegative = number (default: -20)
    thresholdAlertLowerBoundNegative = number (default: -5)
    thresholdNoAlertLowerBound     = number (default: 50)
    thresholdNoAlertUpperBound     = number (default: 75)
    thresholdNoAlertLowerBoundNegative = number (default: 20)
    thresholdNoAlertUpperBoundNegative = number (default: 40)
  }
]
```

## Outputs

| Name | Description |
|------|-------------|
| project_configuration | Status and details of the project configuration |

## Environment Variables

Set the following environment variable for sensitive data:

```bash
export TF_VAR_insightfinder_password="your-password"
```

## Module Development

### Local Development

```bash
git clone https://github.com/insightfinder/terraform.git
cd terraform-insightfinder
```

### Testing

```bash
terraform init
terraform validate
terraform plan -var-file="examples/basic.tfvars"
```

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## Versioning

This module follows [Semantic Versioning](https://semver.org/). Use specific version tags in production:

```hcl
module "my_project" {
  source = "git::https://github.com/insightfinder/terraform.git?ref=v1.2.3"
  # ... configuration
}
```

## License

This module is licensed under the MIT License. See LICENSE file for details.

## Support

For issues and questions:
- Create an issue in this repository
- Contact InsightFinder support
- Check the documentation at https://docs.insightfinder.com