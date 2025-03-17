output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = module.rds.rds_endpoint
}