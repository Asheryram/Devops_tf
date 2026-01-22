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
  name_prefix   = "${var.project}-lt-"
  image_id      = data.aws_ami.ubuntu.image_id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.app_sg_id]
  iam_instance_profile {
    arn = aws_iam_instance_profile.ec2_profile.arn
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
set -e

############################
# SYSTEM SETUP
############################
apt-get update -y
apt-get install -y curl git awscli jq netcat

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
# RETRIEVE CREDENTIALS FROM SECRETS MANAGER
############################
CREDENTIALS=$(
  aws secretsmanager get-secret-value \
    --secret-id ${var.db_credentials_secret_id} \
    --region ${data.aws_region.current.region} \
    --query SecretString \
    --output text
)

DB_USER=$(echo $CREDENTIALS | jq -r '.username')
DB_PASSWORD=$(echo $CREDENTIALS | jq -r '.password')

############################
# EXPORT ENV VARIABLES
############################
cat <<ENV > /etc/profile.d/todo-env.sh
export PORT=3000
export DB_HOST="${var.db_host}"
export DB_USER="$DB_USER"
export DB_PASSWORD="$DB_PASSWORD"
export DB_NAME="${var.db_name}"
export DB_PORT="${var.db_port}"
ENV

source /etc/profile.d/todo-env.sh

############################
# WAIT FOR DATABASE TO BE READY
############################
echo "⏳ Waiting for database to be reachable..."
until nc -z ${var.db_host} ${var.db_port}; do
  echo "Waiting for DB at ${var.db_host}:${var.db_port}..."
  sleep 5
done
echo "✅ Database reachable!"

############################
# START APPLICATION
############################
cd /opt/todo-app
nohup node server.js > app.log 2>&1 &

############################
# CONFIRM APP IS RUNNING
############################
sleep 5
if curl -s http://localhost:3000/health | grep -q "OK"; then
  echo "✅ App started successfully"
else
  echo "❌ App failed to start. Check app.log"
fi



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
