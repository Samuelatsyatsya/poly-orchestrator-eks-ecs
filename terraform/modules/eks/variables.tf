# Common prefix for EKS module resources.
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

# VPC CIDR range for EKS networking.
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# CIDR allowed to reach the EKS API endpoint.
variable "allowed_cidr" {
  description = "CIDR range allowed to access the EKS API"
  type        = string
}

# Optional Kubernetes version for the control plane.
variable "kubernetes_version" {
  description = "Optional Kubernetes version for the EKS cluster"
  type        = string
  default     = null
}

# EC2 instance types for worker nodes.
variable "node_instance_types" {
  description = "EC2 instance types for EKS worker nodes"
  type        = list(string)
}

# Desired worker node count.
variable "node_desired" {
  description = "Desired number of worker nodes"
  type        = number
}

# Minimum worker node count.
variable "node_min" {
  description = "Minimum number of worker nodes"
  type        = number
}

# Maximum worker node count.
variable "node_max" {
  description = "Maximum number of worker nodes"
  type        = number
}
