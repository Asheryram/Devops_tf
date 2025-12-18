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




variable "project" {
type = string
}


variable "tags" {
type = map(string)
}