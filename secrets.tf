resource "aws_secretsmanager_secret" "payment_app_secret" {
  name        = "${local.name_prefix}/payment-app"
  description = "Secret placeholder for payment application integration"
  kms_key_id  = aws_kms_key.payment_key.arn

  recovery_window_in_days = 30

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-payment-app-secret"
    N2SF_Control = "AC,DU,EK"
  })
}