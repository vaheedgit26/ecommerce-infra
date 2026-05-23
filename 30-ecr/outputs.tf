output "repository_urls" {
  description = "Map of repository name to repository URL"
  value       = module.ecr.repository_urls
}
