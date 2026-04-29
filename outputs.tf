output "db_container_name" {
  description = "Name of the database container."
  value       = docker_container.db_container.name
}

output "app_access_url" {
  description = "URL to access the web application."
  value       = "http://localhost:${docker_container.app_container.ports[0].external}"
}