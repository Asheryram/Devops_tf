variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "db_username" {
  type        = string
  description = "Database username"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password"
}

variable "db_host" {
  type        = string
  description = "Database host endpoint"
}

variable "db_port" {
  type        = number
  description = "Database port"
  default     = 3306
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
  default     = {}
}
