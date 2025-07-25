output "rds_endpoint" {
  description = "Postgres RDS endpoint"
  value       = aws_db_instance.postgres.address
}

output "sns_topic_arn" {
  description = "SNS Topic ARN"
  value       = aws_sns_topic.order_notifications.arn
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.order_notifier.function_name
}
