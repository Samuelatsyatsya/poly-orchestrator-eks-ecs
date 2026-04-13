# Common prefix for ECS module resources.
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

# VPC CIDR range for ECS networking.
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# CIDR allowed to reach the public ALB.
variable "allowed_cidr" {
  description = "CIDR range allowed to access the ALB"
  type        = string
}

# Container port exposed by the app.
variable "container_port" {
  description = "Container port for the app"
  type        = number
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
}

# Minimum task count for autoscaling.
variable "min_count" {
  description = "Minimum ECS task count"
  type        = number
}

# Maximum task count for autoscaling.
variable "max_count" {
  description = "Maximum ECS task count"
  type        = number
}

# Task CPU units.
variable "task_cpu" {
  description = "Task CPU units"
  type        = number
}

# Task memory in MiB.
variable "task_memory" {
  description = "Task memory (MiB)"
  type        = number
}
