resource "aws_db_subnet_group" "this" {
name = "${var.project}-db-subnet-group"
subnet_ids = var.db_subnets


tags = merge(var.tags, {
Name = "${var.project}-db-subnet-group"
})
}


resource "aws_db_instance" "this" {
identifier = "${var.project}-db"
engine = var.engine
engine_version = var.engine_version
instance_class = var.instance_class
allocated_storage = var.allocated_storage


db_name = var.db_name
username = var.username
password = var.password


db_subnet_group_name = aws_db_subnet_group.this.name
vpc_security_group_ids = [var.db_sg_id]


skip_final_snapshot = true
publicly_accessible = true
multi_az = false


tags = merge(var.tags, {
Name = "${var.project}-rds"
})
}