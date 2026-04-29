# --- Terraform Configuration & Provider ---
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {}

# --- Resource 1: PostgreSQL Image ---
# Tells Terraform to pull this image from Docker Hub
resource "docker_image" "postgres_image" {
  name         = "postgres:latest"
  keep_locally = true  # Don't delete the image on terraform destroy
}

# --- Resource 2: PostgreSQL Container ---
resource "docker_container" "db_container" {
  name  = "tp-db-postgres"
  image = docker_image.postgres_image.image_id

  ports {
  internal = 5432
  external = var.db_port_external
  }

  # Injecting our variables.tf values as environment variables
  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}",
  ]
}

# --- Resource 3: Web App Image ---
# Terraform will run docker build using our Dockerfile_app
resource "docker_image" "app_image" {
  name         = "tp-web-app:latest"
  keep_locally = true
}

# --- Resource 4: Web App Container ---
resource "docker_container" "app_container" {
  name  = "tp-app-web"
  image = docker_image.app_image.image_id

  # This tells Terraform: create the DB container BEFORE this one
  depends_on = [docker_container.db_container]

  ports {
    internal = 80
    external = var.app_port_external  # References our variable → 8080
  }
}