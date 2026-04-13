# ECS stack entry point (single environment) using the reusable module.
module "ecs" {
  source = "../modules/ecs"

  name_prefix    = var.name_prefix
  vpc_cidr       = var.vpc_cidr
  allowed_cidr   = var.allowed_cidr
  container_port = var.container_port
  app_image      = var.app_image

  desired_count = var.desired_count
  min_count     = var.min_count
  max_count     = var.max_count

  task_cpu    = var.task_cpu
  task_memory = var.task_memory
}
