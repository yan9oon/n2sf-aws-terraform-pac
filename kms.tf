resource "aws_kms_key" "payment_key" {
  description             = "KMS key for payment data encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-payment-kms"
    N2SF_Control = "EK,EA,DT"
  })
}

resource "aws_kms_alias" "payment_key_alias" {
  name          = "alias/${local.name_prefix}-payment"
  target_key_id = aws_kms_key.payment_key.key_id
}

resource "aws_kms_key" "log_key" {
  description             = "KMS key for audit log encryption"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-log-kms"
    N2SF_Control = "EK,EA,AuditLog"
  })
}

resource "aws_kms_alias" "log_key_alias" {
  name          = "alias/${local.name_prefix}-logs"
  target_key_id = aws_kms_key.log_key.key_id
}