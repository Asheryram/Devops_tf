variable "region" {
type = string
}


variable "environment" {
type = string
}


variable "project" {
type = string
}


variable "owner" {
type = string
}


variable "vpc_cidr" {
type = string
}


variable "public_subnet_cidrs" {
type = list(string)
}


variable "app_subnet_cidrs" {
type = list(string)
}


variable "db_subnet_cidrs" {
type = list(string)
}





variable "db_name" {
type = string
}


variable "db_username" {
type = string
}


variable "db_password" {
type = string
sensitive = true
}