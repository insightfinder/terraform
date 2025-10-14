# API Client Module
# This module provides shared API client configuration for InsightFinder

terraform {
  required_version = ">= 1.0"
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# No resources in this module - it's just for configuration sharing
# Authentication validation could be added here in the future