# AWS region for the EKS stack.
variable "region" {
  description = "AWS region"
  type        = string
}

# Common prefix for all EKS resources.
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "poly-orchestrator"
}

# VPC CIDR range for EKS networking.
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

# CIDR allowed to reach the EKS API endpoint.
variable "allowed_cidr" {
  description = "CIDR range allowed to access the EKS API"
  type        = string
  default     = "0.0.0.0/0"
}

# Optional Kubernetes version for the EKS control plane.
variable "kubernetes_version" {
  description = "Optional Kubernetes version for the EKS cluster"
  type        = string
  default     = null
}

# EC2 instance types for worker nodes.
variable "node_instance_types" {
  description = "EC2 instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.small"]
}

# Desired worker node count.
variable "node_desired" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

# Minimum worker node count.
variable "node_min" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

# Maximum worker node count.
variable "node_max" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}
