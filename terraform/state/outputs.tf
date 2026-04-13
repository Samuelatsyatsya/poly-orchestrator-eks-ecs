# S3 bucket name for remote state.
output "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.state.bucket
}
