variable "private_subnets" {
  type = list(string)
}


variable "app_sg_id" {
  type = string
}


variable "target_group_arn" {
  type = string
}


variable "instance_type" {
  type    = string
  default = "t3.micro"
}


variable "min_size" {
  type    = number
  default = 1
}


variable "max_size" {
  type    = number
  default = 2
}


variable "desired_capacity" {
  type    = number
  default = 1
}


variable "project" {
  type = string
}


variable "tags" {
  type = map(string)
}


variable "db_host" {
  description = "RDS endpoint"
  type        = string
}

variable "db_user" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_port" {
  description = "Database port"
  type        = number
  default     = 3306
}
