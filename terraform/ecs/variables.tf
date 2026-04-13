# AWS region for the ECS stack.
variable "region" {
  description = "AWS region"
  type        = string
}

# Common prefix for all ECS resources.
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "poly-orchestrator"
}

# VPC CIDR range for ECS networking.
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# CIDR allowed to reach the public ALB.
variable "allowed_cidr" {
  description = "CIDR range allowed to access the ALB"
  type        = string
  default     = "0.0.0.0/0"
}

# Container port exposed by the app.
variable "container_port" {
  description = "Container port for the app"
  type        = number
  default     = 3000
}

# Optional image override (defaults to module ECR repo if blank).
variable "app_image" {
  description = "Container image URI for the app (ECR recommended). Leave blank to use the module ECR repo."
  type        = string
  default     = ""
}

# Desired task count for the ECS service.
variable "desired_count" {
  description = "Desired ECS task count"
  type        = number
  default     = 2
}

# Minimum task count for autoscaling.
variable "min_count" {
  description = "Minimum ECS task count"
  type        = number
  default     = 2
}

# Maximum task count for autoscaling.
variable "max_count" {
  description = "Maximum ECS task count"
  type        = number
  default     = 4
}

# Task CPU units.
variable "task_cpu" {
  description = "Task CPU units"
  type        = number
  default     = 256
}

# Task memory in MiB.
variable "task_memory" {
  description = "Task memory (MiB)"
  type        = number
  default     = 512
}
