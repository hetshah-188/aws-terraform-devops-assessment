
# Find the latest Amazon Linux 2023 AMI through AWS Systems Manager.
data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# Launch template for the web application instances.
resource "aws_launch_template" "app" {
  name_prefix   = "devops-app-"
  image_id      = data.aws_ssm_parameter.al2023_ami.value
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(<<-USERDATA
    #!/bin/bash
    set -eux
    dnf install -y nginx
    systemctl enable --now nginx

    cat > /usr/share/nginx/html/index.html <<'HTML'
    ${file("${path.module}/../app/index.html")}
    HTML
    USERDATA
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "devops-assessment-web"
      Tier = "application"
    }
  }

  tags = {
    Name = "devops-assessment-launch-template"
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.app.name
  }
}

# Keep one instance running to limit costs while testing.
# The Auto Scaling Group can use either private application subnet.
resource "aws_autoscaling_group" "app" {
  name                = "devops-assessment-asg"
  min_size            = 1
  desired_capacity    = 1
  max_size            = 2
  vpc_zone_identifier = aws_subnet.private_app[*].id

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 180

  tag {
    key                 = "Name"
    value               = "devops-assessment-web"
    propagate_at_launch = true
  }
}
