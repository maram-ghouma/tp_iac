# --- Database Variables ---
variable "db_name" {
  description = "Name of the PostgreSQL database."
  type        = string
  default     = "devops_db"
}

variable "db_user" {
  description = "PostgreSQL username."
  type        = string
  default     = "devops_user"
}

variable "db_password" {
  description = "PostgreSQL password."
  type        = string
  default     = "strongpassword123"
}

# --- Application Variables ---
variable "app_port_external" {
  description = "External port to access the web app (maps to internal port 80)."
  type        = number
  default     = 8080
}
variable "db_port_external" {
  description = "External port for PostgreSQL."
  type        = number
  default     = 5434
}