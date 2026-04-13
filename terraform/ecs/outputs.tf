# Public DNS name for the ECS ALB.
output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = module.ecs.alb_dns_name
}

# ECR repository URL used for the app image.
output "ecr_repository_url" {
  description = "ECR repository URL for the app image"
  value       = module.ecs.ecr_repository_url
}

# ECS cluster name.
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.ecs_cluster_name
}

# ECS service name.
output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.ecs_service_name
}
