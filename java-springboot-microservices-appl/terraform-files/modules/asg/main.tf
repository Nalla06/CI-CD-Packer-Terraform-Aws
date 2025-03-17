resource "aws_launch_template" "this" {
  name_prefix   = "app-launch-template-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  # Add IAM instance profile
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    # Include both your existing security group and the new one for EC2 Instance Connect
    security_groups = [
      var.ec2_sg_id,
      var.ec2_instance_connect_sg_id
    ]
  }

  user_data = base64encode(var.user_data)

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "app-instance"
    }
  }
}

resource "aws_autoscaling_group" "this" {
  name                = "app-asg"
  vpc_zone_identifier = var.private_subnet_ids
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = [var.alb_tg_arn]

  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "app-asg-instance"
    propagate_at_launch = true
  }
  # Add tag for EC2 Instance Connect Endpoint
  tag {
  key                 = "ConnectVia"
  value               = var.ec2_instance_connect_endpoint_id
  propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high-cpu-usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_description = "Scale up if CPU usage is above 80% for 4 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "low-cpu-usage"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 20

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_description = "Scale down if CPU usage is below 20% for 4 minutes"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}