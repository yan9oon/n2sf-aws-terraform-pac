data "aws_iam_policy_document" "payment_app_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "payment_app_role" {
  name               = "${local.name_prefix}-payment-app-role"
  assume_role_policy = data.aws_iam_policy_document.payment_app_assume_role.json

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-payment-app-role"
    N2SF_Control = "LP,AC,IM"
  })
}

data "aws_iam_policy_document" "payment_app_policy_doc" {
  statement {
    sid    = "DynamoDBLeastPrivilege"
    effect = "Allow"

    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]

    resources = [
      aws_dynamodb_table.payment_transactions.arn
    ]
  }

  statement {
    sid    = "ReadApplicationSecret"
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = [
      aws_secretsmanager_secret.payment_app_secret.arn
    ]
  }

  statement {
    sid    = "UseKMSForPaymentData"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]

    resources = [
      aws_kms_key.payment_key.arn
    ]
  }
}

resource "aws_iam_policy" "payment_app_policy" {
  name        = "${local.name_prefix}-payment-app-policy"
  description = "Least privilege policy for payment application PoC"
  policy      = data.aws_iam_policy_document.payment_app_policy_doc.json

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-payment-app-policy"
    N2SF_Control = "LP,AC"
  })
}

resource "aws_iam_role_policy_attachment" "payment_app_policy_attach" {
  role       = aws_iam_role.payment_app_role.name
  policy_arn = aws_iam_policy.payment_app_policy.arn
}

data "aws_iam_policy_document" "api_gateway_cloudwatch_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "api_gateway_cloudwatch_role" {
  name               = "${local.name_prefix}-api-gw-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.api_gateway_cloudwatch_assume.json

  tags = merge(local.common_tags, {
    Name         = "${local.name_prefix}-api-gw-cloudwatch-role"
    N2SF_Control = "AuditLog"
  })
}

resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch_attach" {
  role       = aws_iam_role.api_gateway_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}