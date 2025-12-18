variable "db_subnets" {
type = list(string)
}


variable "db_sg_id" {
type = string
}


variable "engine" {
type = string
default = "mysql"
}


variable "engine_version" {
type = string
default = "8.0"
}


variable "instance_class" {
type = string
default = "db.t3.micro"
}


variable "allocated_storage" {
type = number
default = 20
}


variable "db_name" {
type = string
}


variable "username" {
type = string
}


variable "password" {
type = string
sensitive = true
}


variable "project" {
type = string
}


variable "tags" {
type = map(string)
}