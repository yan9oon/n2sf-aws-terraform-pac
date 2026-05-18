resource "aws_cloudwatch_log_group" "api_access_logs" {
  name              = "/aws/apigateway/${local.name_prefix}/access"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.log_key.arn

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-api-access-logs"
    N2SF_Control = "AuditLog,LI,SN"
  })
}

resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  name              = "/aws/cloudtrail/${local.name_prefix}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.log_key.arn

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-cloudtrail-logs"
    N2SF_Control = "AuditLog"
  })
}