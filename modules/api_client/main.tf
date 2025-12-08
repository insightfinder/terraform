# API Client Module
# This module provides API client configuration for InsightFinder
# Uses header-based authentication with username and license key

terraform {
  required_version = ">= 1.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}