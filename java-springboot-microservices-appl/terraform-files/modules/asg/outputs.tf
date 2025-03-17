output "asg_id" {
  description = "ID of the ASG"
  value       = aws_autoscaling_group.this.id
}

output "asg_name" {
  description = "Name of the ASG"
  value       = aws_autoscaling_group.this.name
}