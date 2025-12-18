resource "aws_launch_template" "this" {
  name_prefix   = "${var.project}-lt-"
  image_id      = data.aws_ami.ubuntu.image_id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.app_sg_id]

  user_data = base64encode(<<-EOF
#!/bin/bash
set -e

# Update system
apt update -y
apt install -y apache2 curl

# Enable Apache
systemctl start apache2
systemctl enable apache2

# Get instance metadata (IMDSv2)
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/instance-id)

PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-ipv4)

AZ=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)

# Create web page
cat <<HTML > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Application Server</title>
  <style>
    body { font-family: Arial; background: #f4f4f4; }
    .box { background: white; padding: 20px; margin: 50px auto; width: 400px; }
  </style>
</head>
<body>
  <div class="box">
    <h2>Application Server</h2>
    <p><strong>Instance ID:</strong> $INSTANCE_ID</p>
    <p><strong>Private IP:</strong> $PRIVATE_IP</p>
    <p><strong>Availability Zone:</strong> $AZ</p>
    <p><strong>Security Group:</strong> ${var.app_sg_id}</p>
  </div>
</body>
</html>
HTML

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
