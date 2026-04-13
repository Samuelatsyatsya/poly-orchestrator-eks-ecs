# EKS cluster name output for kubectl config.
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.eks_cluster_name
}

# EKS API endpoint output for reference.
output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.eks_cluster_endpoint
}

# Helper command to configure kubectl for this cluster.
output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.eks_cluster_name}"
}
