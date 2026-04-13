# EKS stack entry point (single environment) using the reusable module.
module "eks" {
  source = "../modules/eks"

  name_prefix        = var.name_prefix
  vpc_cidr           = var.vpc_cidr
  allowed_cidr       = var.allowed_cidr
  kubernetes_version = var.kubernetes_version

  node_instance_types = var.node_instance_types
  node_desired        = var.node_desired
  node_min            = var.node_min
  node_max            = var.node_max
}
