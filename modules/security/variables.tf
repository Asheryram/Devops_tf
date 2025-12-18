variable "vpc_id" {
type = string
}


variable "db_port" {
type = number
default = 3306
}


variable "tags" {
type = map(string)
}