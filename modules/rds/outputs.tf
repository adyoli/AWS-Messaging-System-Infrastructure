output "db_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = aws_db_instance.default.endpoint
}

output "db_instance_id" {
  description = "The RDS instance identifier."
  value       = aws_db_instance.default.id
}