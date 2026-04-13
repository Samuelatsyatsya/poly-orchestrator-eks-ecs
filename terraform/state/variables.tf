# AWS region for the state resources.
variable "region" {
  description = "AWS region"
  type        = string
}

# Prefix for naming the state resources.
variable "name_prefix" {
  description = "Prefix for state resources"
  type        = string
  default     = "poly-orchestrator"
}

# S3 bucket name for Terraform state.
variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
}
