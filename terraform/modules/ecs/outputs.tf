# Public DNS name for the ECS ALB.
output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

# ECR repository URL used for the app image.
output "ecr_repository_url" {
  description = "ECR repository URL for the app image"
  value       = aws_ecr_repository.this.repository_url
}

# ECS cluster name.
output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

# ECS service name.
output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.this.name
}
