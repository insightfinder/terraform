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

variable "license_key" {
  description = "InsightFinder license key"
  type        = string
  sensitive   = true
}