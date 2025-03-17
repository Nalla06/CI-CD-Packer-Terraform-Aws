output "rds_endpoint" {
  description = "Endpoint of the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "rds_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.this.id
}