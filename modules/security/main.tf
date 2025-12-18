resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Web / ALB security group"
  vpc_id      = var.vpc_id


  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "ICMP from internet"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge(var.tags, {
    Name = "web-sg"
  })
}


resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Application security group"
  vpc_id      = var.vpc_id


  ingress {
    description     = "HTTP from web tier"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

   # Allow traffic from ALB on app port 3000
  ingress {
    description     = "App port 3000 from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }


  ingress {
    description     = "ICMP from web tier"
    from_port       = -1
    to_port         = -1
    protocol        = "icmp"
    security_groups = [aws_security_group.web.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge(var.tags, {
    Name = "app-sg"
  })
}

resource "aws_security_group" "db" {
  name        = "db-sg"
  description = "Database security group"
  vpc_id      = var.vpc_id


  ingress {
    description     = "DB access from app tier"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge(var.tags, {
    Name = "db-sg"
  })
}
