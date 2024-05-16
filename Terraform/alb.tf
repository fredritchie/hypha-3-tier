resource "aws_lb" "webapp-ALB" {
  name               = "webapp-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ALB-SG.id]
  subnets            = [aws_subnet.subnet-public-1.id, aws_subnet.subnet-public-2.id]

  tags = {
    application = "webapp"
  }
}

# Create the target group
resource "aws_lb_target_group" "webapp-TG" {
  name        = "webapp-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.webapp_VPC.id
  target_type = "instance"
}

# Create the listener
resource "aws_lb_listener" "webapp_listener" {
  load_balancer_arn = aws_lb.webapp-ALB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp-TG.arn
  }
}

# Create the Auto Scaling group
resource "aws_autoscaling_group" "webapp_asg" {
  name                = "webapp-asg"
  desired_capacity    = 2
  max_size            = 5
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.webapp-TG.arn]
  vpc_zone_identifier = [aws_subnet.subnet-public-1.id, aws_subnet.subnet-public-2.id]

  launch_template {
    id      = aws_launch_template.webapp-template.id
    version = "$Latest"
  }
}