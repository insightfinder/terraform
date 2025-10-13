# InsightFinder Terraform Configuration Module

This Terraform module provides a clean, flexible way to manage InsightFinder project configurations using Infrastructure as Code (IaC) principles.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration Methods](#configuration-methods)
- [Step-by-Step Guide](#step-by-step-guide)
- [Configuration Examples](#configuration-examples)
- [Variables Reference](#variables-reference)
- [Files Structure](#files-structure)
- [Troubleshooting](#troubleshooting)

## Features

- **Flexible Configuration**: Use simple individual variables or the comprehensive `project_config` object
- **Future-Proof**: Automatically supports any new configuration fields added to InsightFinder
- **Type Safety**: Terraform validates configuration before deployment
- **Environment Management**: Easy management across different environments (dev, staging, prod)
- **Conditional Fields**: Only sends non-null values to avoid overriding defaults
- **Clean & Maintainable**: Well-structured code that's easy to understand and modify

## Prerequisites

1. **Terraform**: Version >= 1.0
   ```bash
   terraform --version
   ```

2. **InsightFinder Account**: Active account with project creation permissions

3. **Network Access**: Connectivity to InsightFinder API (`https://app.insightfinder.com`)

4. **Required Tools**: `curl` (used by the apply-config.sh script)

## Quick Start

1. **Clone or download this module**
2. **Set your password as environment variable**:
   ```bash
   export TF_VAR_password="your_insightfinder_password"
   ```
3. **Run with minimal configuration**:
   ```bash
   terraform init
   terraform plan -var-file="examples/minimal.tfvars"
   terraform apply -var-file="examples/minimal.tfvars"
   ```

## Configuration Methods

### Method 1: Individual Variables (Simple)
Best for basic configurations with standard fields:

```hcl
# Connection settings
username = "your_username"
project_name = "my-project"

# Configuration using individual variables
cValue = 3
pValue = 0.95
projectDisplayName = "My Project"
retentionTime = 90
samplingInterval = 600
showInstanceDown = false
```

### Method 2: Project Config Object (Recommended)
Best for complex configurations and future-proofing:

```hcl
# Connection settings
username = "your_username"
project_name = "my-project"

# All configuration in one flexible object
project_config = {
  # Core fields
  cValue = 3
  pValue = 0.95
  projectDisplayName = "My Project"
  retentionTime = 90
  
  # Advanced fields
  UBLRetentionTime = 8
  enableUBLDetect = true
  dynamicBaselineDetectionFlag = true
  
  # Any future fields work automatically without code changes
  # newFeature = "enabled"
}
```

## Step-by-Step Guide

### 1. Initial Setup

```bash
# Navigate to the terraform directory
cd /path/to/terraform

# Initialize Terraform (downloads required providers)
terraform init
```

### 2. Set Authentication

```bash
# Set your InsightFinder password as environment variable
export TF_VAR_password="your_password_here"

# Verify it's set (should show your password)
echo $TF_VAR_password
```

### 3. Choose Configuration Method

**Option A: Use existing example file**
```bash
# Copy an example file and modify it
cp examples/minimal.tfvars my-config.tfvars
# Edit my-config.tfvars with your details
```

**Option B: Create custom configuration file**
```bash
# Create your own .tfvars file
cat > my-config.tfvars << EOF
username = "your_username"
project_name = "my-project-name"
base_url = "https://app.insightfinder.com"

cValue = 3
pValue = 0.95
projectDisplayName = "My Custom Project"
retentionTime = 90
samplingInterval = 600
showInstanceDown = false
EOF
```

### 4. Plan and Apply

```bash
# Plan - shows what will be created/changed
terraform plan -var-file="my-config.tfvars"

# Apply - actually creates/updates the configuration
terraform apply -var-file="my-config.tfvars"

# Auto-approve to skip confirmation (use with caution)
terraform apply -var-file="my-config.tfvars" -auto-approve
```

### 5. Verify Configuration

```bash
# Check the generated configuration file
cat generated-config.json

# View Terraform outputs
terraform output
```

### 6. Managing Changes

```bash
# Make changes to your .tfvars file, then:
terraform plan -var-file="my-config.tfvars"   # Review changes
terraform apply -var-file="my-config.tfvars"  # Apply changes
```

### 7. Cleanup (if needed)

```bash
# Remove all resources created by this module
terraform destroy -var-file="my-config.tfvars"
```

## Configuration Examples

### Minimal Configuration
File: `examples/minimal.tfvars`
```bash
terraform apply -var-file="examples/minimal.tfvars"
```

### Basic Configuration with Individual Variables
File: `examples/basic.tfvars`
```bash
terraform apply -var-file="examples/basic.tfvars"
```

### Flexible Configuration with project_config
File: `examples/flexible.tfvars`
```bash
terraform apply -var-file="examples/flexible.tfvars"
```

### Advanced Configuration with Complex Settings
File: `examples/advanced.tfvars`
```bash
terraform apply -var-file="examples/advanced.tfvars"
```

## Variables Reference

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `username` | string | Your InsightFinder username |
| `password` | string | Your InsightFinder password (set via `TF_VAR_password`) |
| `project_name` | string | Target project name in InsightFinder |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `base_url` | string | `"https://app.insightfinder.com"` | InsightFinder API base URL |
| `project_config` | object | `{}` | Flexible configuration object supporting any field |

### Individual Configuration Variables (Optional)

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `cValue` | number | `null` | Continues value for project (count) |
| `pValue` | number | `null` | Probability threshold value for UBL |
| `showInstanceDown` | bool | `null` | Show instance down incidents |
| `retentionTime` | number | `null` | Data retention time in days |
| `projectDisplayName` | string | `null` | Display name of the project |
| `samplingInterval` | number | `null` | Sampling interval in seconds |
| `UBLRetentionTime` | number | `null` | UBL retention time in days |
| `highRatioCValue` | number | `null` | High ratio C value |
| `dynamicBaselineDetectionFlag` | bool | `null` | Enable dynamic baseline detection |
| `enableUBLDetect` | bool | `null` | Enable UBL detection |
| `enableCumulativeDetect` | bool | `null` | Enable cumulative detection |

## Files Structure

```
terraform/
├── main.tf                    # Main Terraform configuration
├── apply-config.sh           # Script for applying config via API
├── README.md                 # This documentation
├── VERSION                   # Version information
├── CHANGELOG.md             # Change history
├── LICENSE                  # License information
└── examples/
    ├── minimal.tfvars       # Simple example with essential fields
    ├── basic.tfvars         # Basic example with additional fields
    ├── flexible.tfvars      # Flexible approach using project_config
    └── advanced.tfvars      # Complex configuration with metric settings
```

## Troubleshooting

### Common Issues and Solutions

**1. Authentication Errors**
```bash
# Ensure password is set correctly
export TF_VAR_password="your_actual_password"

# Verify username and base_url are correct
```

**2. Variable Not Declared Errors**
```
Error: Value for undeclared variable
```
Solution: Make sure all variables in your .tfvars file are declared in main.tf

**3. Connection Errors**
```bash
# Check network connectivity
curl -I https://app.insightfinder.com

# Verify base_url is correct in your configuration
```

**4. Project Not Found**
- Ensure the project exists in InsightFinder
- Verify project_name matches exactly (case-sensitive)

**5. Permission Denied**
- Verify your user has permission to modify the project
- Check if you need admin privileges for certain configuration changes

### Debug Mode

Enable detailed logging:
```bash
# Set Terraform log level
export TF_LOG=DEBUG

# Run terraform with verbose output
terraform apply -var-file="my-config.tfvars" -auto-approve
```

### Getting Help

1. **Check Terraform plan output**: `terraform plan -var-file="your-config.tfvars"`
2. **Validate configuration**: `terraform validate`
3. **Check generated config**: `cat generated-config.json`
4. **Review apply-config.sh logs**: Check terminal output during apply

## How It Works

1. **Configuration Merging**: Individual variables are merged with `project_config` (project_config takes precedence)
2. **Null Filtering**: Only non-null values are included in the final JSON configuration
3. **File Generation**: Creates `generated-config.json` with the final configuration
4. **API Application**: Uses `apply-config.sh` script to apply configuration via InsightFinder API
5. **State Management**: Terraform tracks the configuration state for future updates

This module is designed to be production-ready, maintainable, and future-proof for all your InsightFinder project configuration needs.