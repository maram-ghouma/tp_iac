# --- Configuration Terraform et Provider ---

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# --- 1. Ressource : Base de Données PostgreSQL ---

resource "docker_image" "postgres_image" {
  name         = "postgres:latest"
  keep_locally = true
}

resource "docker_container" "db_container" {
  name  = "tp-db-postgres"
  image = docker_image.postgres_image.image_id

  ports {
    internal = 5432
    external = var.db_external_port
  }

  env = [
    "POSTGRES_USER=${var.db_user}",
    "POSTGRES_PASSWORD=${var.db_password}",
    "POSTGRES_DB=${var.db_name}",
  ]
}

# --- 2. Ressource : Application Web Nginx ---

# Workaround: the provider's build block fails on Windows (legacy build API bug).
# We call Docker directly via local-exec, which works identically to the manual command.
resource "null_resource" "build_app" {
  triggers = {
    dockerfile_hash = filemd5("${path.module}/Dockerfile_app")
  }

  provisioner "local-exec" {
    command     = "docker build -t tp-web-app:latest -f Dockerfile_app ."
    working_dir = path.module
  }
}

resource "docker_image" "app_image" {
  name = "tp-web-app:latest"

  build {
    context    = "."
    dockerfile = "Dockerfile_app"
  }
}

resource "docker_container" "app_container" {
  name  = "tp-app-web"
  image = docker_image.app_image.image_id

  depends_on = [docker_container.db_container]

  ports {
    internal = 80
    external = var.app_port_external
  }
}