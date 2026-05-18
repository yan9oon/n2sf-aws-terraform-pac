resource "aws_dynamodb_table" "payment_transactions" {
  name         = "${local.name_prefix}-transactions"
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = "transaction_id"
  range_key = "created_at"

  attribute {
    name = "transaction_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.payment_key.arn
  }

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-transactions"
    N2SF_Control = "DU,DT,EK"
  })
}