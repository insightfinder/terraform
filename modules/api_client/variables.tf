# API Client Module Variables
variable "base_url" {
  description = "InsightFinder API base URL"
  type        = string
  default     = "https://app.insightfinder.com"
}

variable "username" {
  description = "InsightFinder username"
  type        = string
}

variable "password" {
  description = "InsightFinder password"
  type        = string
  sensitive   = true
}

variable "license_key" {
  description = "InsightFinder license key (required for project creation)"
  type        = string
  sensitive   = true
}