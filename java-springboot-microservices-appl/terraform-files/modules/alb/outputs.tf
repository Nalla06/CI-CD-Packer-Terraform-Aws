output "alb_id" {
  description = "ID of the ALB"
  value       = aws_lb.this.id
}

output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "alb_tg_arn" {
  description = "ARN of the ALB target group"
  value       = aws_lb_target_group.this.arn
}