output "project" {
  description = "Project Name"
  value       = var.project
}

output "env" {
  description = "Environment"
  value       = var.env
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "bucket_arn" {
  description = "ARN of the Terraform remote state S3 bucket"
  value       = module.s3.bucket_arn
}

output "bucket_id" {
  description = "Bucket ID (same as name) for Terraform state"
  value       = module.s3.bucket_id
}
