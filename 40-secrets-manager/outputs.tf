output "db_secret_name" {
  description = "Name of the secret created"
  value       = module.secrets_manager.db_secret_name
}

output "db_secret_arn" {
  description = "ARN of the secret created"
  value       = module.secrets_manager.db_secret_arn
}
