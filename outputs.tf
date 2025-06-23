output "rds_endpoint" {
  description = "The endpoint of the RDS instance."
  value       = module.rds.db_endpoint
}
output "sqs_queue_url" {
  description = "The URL of the SQS queue."
  value       = aws_sqs_queue.message_queue.id
}
output "dynamodb_table_name" {
  description = "The name of the DynamoDB table."
  value       = aws_dynamodb_table.metadata_storage.name
}