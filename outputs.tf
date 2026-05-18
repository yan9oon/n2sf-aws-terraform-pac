output "vpc_id" {
  value       = aws_vpc.payments_vpc.id
  description = "VPC ID for N2SF Payments PoC"
}

output "log_bucket_name" {
  value       = aws_s3_bucket.log_bucket.id
  description = "S3 bucket used for audit logs"
}

output "cloudtrail_name" {
  value       = aws_cloudtrail.main.name
  description = "CloudTrail name"
}

output "api_gateway_id" {
  value       = aws_api_gateway_rest_api.payment_api.id
  description = "API Gateway REST API ID"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.payment_transactions.name
  description = "DynamoDB transaction table name"
}

output "guardduty_detector_id" {
  value       = aws_guardduty_detector.main.id
  description = "GuardDuty detector ID"
}