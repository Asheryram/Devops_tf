resource "aws_iam_role" "ec2_role" {
  name_prefix = "${var.project}-ec2-role-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "secrets_manager_policy" {
  name_prefix = "${var.project}-secrets-policy-"
  role        = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.db_credentials_secret_arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name_prefix = "${var.project}-ec2-profile-"
  role        = aws_iam_role.ec2_role.name
}

resource "aws_launch_template" "this" {
  name_prefix            = "${var.project}-lt-"
  image_id               = data.aws_ami.ubuntu.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.app_sg_id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_profile.arn
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_credentials_secret_id = var.db_credentials_secret_id
    aws_region              = data.aws_region.current.region
    db_host                 = var.db_host
    db_name                 = var.db_name
    db_port                 = var.db_port
  }))

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.project}-app"
    })
  }
}


resource "aws_autoscaling_group" "this" {
  name                = "${var.project}-asg"
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.private_subnets
  health_check_type   = "ELB"
  health_check_grace_period = 600


  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }


  target_group_arns = [var.target_group_arn]


  tag {
    key                 = "Environment"
    value               = var.tags["Environment"]
    propagate_at_launch = true
  }


  tag {
    key                 = "Project"
    value               = var.tags["Project"]
    propagate_at_launch = true
  }


  tag {
    key                 = "Owner"
    value               = var.tags["Owner"]
    propagate_at_launch = true
  }
}
