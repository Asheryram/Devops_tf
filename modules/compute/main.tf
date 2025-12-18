resource "aws_launch_template" "this" {
  name_prefix   = "${var.project}-lt-"
  image_id      = data.aws_ami.ubuntu.image_id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.app_sg_id]

  user_data = base64encode(<<-EOF
#!/bin/bash
set -e

############################
# SYSTEM SETUP
############################
apt-get update -y
apt-get install -y curl git

############################
# INSTALL NODE.JS 18
############################
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

############################
# APP DIRECTORY
############################
mkdir -p /opt/todo-app
cd /opt/todo-app

############################
# CLONE APP FROM GITHUB
############################
git clone https://github.com/Asheryram/todo-app.git .
npm install

############################
# ENVIRONMENT VARIABLES
############################
cat <<ENV > /etc/profile.d/todo-env.sh
export PORT=3000
export DB_HOST="${var.db_host}"
export DB_USER="${var.db_user}"
export DB_PASSWORD="${var.db_password}"
export DB_NAME="${var.db_name}"
export DB_PORT="${var.db_port}"
ENV

source /etc/profile.d/todo-env.sh

############################
# START APPLICATION
############################
nohup node server.js > app.log 2>&1 &

EOF
  )

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
